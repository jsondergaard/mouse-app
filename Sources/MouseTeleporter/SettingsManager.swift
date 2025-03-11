import Cocoa

class SettingsManager {
  private let defaults = UserDefaults.standard

  // Keys for user defaults
  private enum Keys {
    static let saveInterval = "saveInterval"
    static let shortcutKeyCode = "shortcutKeyCode"
    static let shortcutModifiers = "shortcutModifiers"
  }

  // Default values
  private enum DefaultValues {
    static let saveInterval: TimeInterval = 5.0
    static let shortcutKeyCode: UInt16 = 122  // F1
    static let shortcutModifiers: UInt = NSEvent.ModifierFlags([.command, .shift]).rawValue
  }

  var saveInterval: TimeInterval {
    get {
      let savedValue = defaults.double(forKey: Keys.saveInterval)
      return savedValue > 0 ? savedValue : DefaultValues.saveInterval
    }
    set {
      defaults.set(newValue, forKey: Keys.saveInterval)
      notifySettingsChanged()
    }
  }

  var shortcut: KeyboardShortcut? {
    get {
      if let keyCode = defaults.object(forKey: Keys.shortcutKeyCode) as? UInt16,
        let modifierRaw = defaults.object(forKey: Keys.shortcutModifiers) as? UInt
      {
        return KeyboardShortcut(
          keyCode: keyCode, modifierFlags: NSEvent.ModifierFlags(rawValue: modifierRaw))
      }

      // Return default shortcut if none is saved
      return KeyboardShortcut(
        keyCode: DefaultValues.shortcutKeyCode,
        modifierFlags: NSEvent.ModifierFlags(rawValue: DefaultValues.shortcutModifiers))
    }
    set {
      if let shortcut = newValue {
        defaults.set(shortcut.keyCode, forKey: Keys.shortcutKeyCode)
        defaults.set(shortcut.modifierFlags.rawValue, forKey: Keys.shortcutModifiers)
        notifySettingsChanged()
      }
    }
  }

  func saveSettings() {
    defaults.synchronize()
  }

  func notifySettingsChanged() {
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: .settingsChanged, object: self)
    }
  }
}

extension Notification.Name {
  static let settingsChanged = Notification.Name("com.mouseteleporter.settingsChanged")
}
