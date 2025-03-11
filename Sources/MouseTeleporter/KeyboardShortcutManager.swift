import Cocoa
import HotKey

class KeyboardShortcutManager {
  private let settingsManager: SettingsManager
  private var hotKey: HotKey?
  private var eventHandler: (() -> Void)?

  init(settingsManager: SettingsManager) {
    self.settingsManager = settingsManager

    // Listen for settings changes
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(settingsChanged),
      name: .settingsChanged,
      object: nil
    )
  }

  func registerShortcut(handler: @escaping () -> Void) {
    self.eventHandler = handler
    setupHotKey()
  }

  private func setupHotKey() {
    // Remove existing hotkey
    hotKey = nil

    // Check if we have a shortcut configured
    guard let shortcut = settingsManager.shortcut else {
      print("No keyboard shortcut configured")
      return
    }

    print("Setting up hotkey for: \(shortcut.description)")

    // Convert our custom shortcut to HotKey's Key and ModifierFlags
    if let key = keyForKeyCode(shortcut.keyCode),
      let modifiers = modifiersForFlags(shortcut.modifierFlags)
    {

      // Create the HotKey
      hotKey = HotKey(key: key, modifiers: modifiers)

      // Set the handler
      hotKey?.keyDownHandler = { [weak self] in
        guard let self = self, let handler = self.eventHandler else { return }
        print("Hotkey triggered: \(shortcut.description)")
        handler()
      }

      print("HotKey registered successfully")
    } else {
      print("Failed to create hotkey from shortcut: \(shortcut.description)")
    }
  }

  // Convert our keyCode to HotKey's Key
  private func keyForKeyCode(_ keyCode: UInt16) -> Key? {
    // This is a simplified conversion - extend for all keys as needed
    switch keyCode {
    case 0: return .a
    case 1: return .s
    case 2: return .d
    case 3: return .f
    case 4: return .h
    case 5: return .g
    case 6: return .z
    case 7: return .x
    case 8: return .c
    case 9: return .v
    case 11: return .b
    case 12: return .q
    case 13: return .w
    case 14: return .e
    case 15: return .r
    case 16: return .y
    case 17: return .t
    case 31: return .o
    case 32: return .u
    case 34: return .i
    case 35: return .p
    case 37: return .l
    case 38: return .j
    case 40: return .k
    case 45: return .n
    case 46: return .m
    case 122: return .f1
    case 123: return .f2
    case 124: return .f3
    case 125: return .f4
    case 126: return .f5
    case 127: return .f6
    case 128: return .f7
    case 129: return .f8
    case 130: return .f9
    case 131: return .f10
    case 132: return .f11
    case 133: return .f12
    // Add more key mappings as needed
    default: return nil
    }
  }

  // Convert NSEvent.ModifierFlags to HotKey's NSEvent.ModifierFlags
  private func modifiersForFlags(_ flags: NSEvent.ModifierFlags) -> NSEvent.ModifierFlags? {
    var hotKeyModifiers: NSEvent.ModifierFlags = []

    if flags.contains(.command) { hotKeyModifiers.insert(.command) }
    if flags.contains(.option) { hotKeyModifiers.insert(.option) }
    if flags.contains(.shift) { hotKeyModifiers.insert(.shift) }
    if flags.contains(.control) { hotKeyModifiers.insert(.control) }

    return hotKeyModifiers
  }

  @objc private func settingsChanged() {
    // Update shortcut when settings change
    print("Settings changed - updating keyboard shortcut")
    setupHotKey()
  }

  deinit {
    hotKey = nil
    NotificationCenter.default.removeObserver(self)
  }
}
