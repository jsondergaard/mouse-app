import Cocoa
import HotKey

class AppDelegate: NSObject, NSApplicationDelegate, StatusBarDelegate {

  private var statusBarManager: StatusBarManager!
  private var settingsManager: SettingsManager!
  private var mouseManager: MouseManager!
  private var shortcutManager: KeyboardShortcutManager!
  private var windowManager: WindowManager!
  private var menuManager: AppMenuManager!

  func applicationDidFinishLaunching(_ notification: Notification) {
    // Set application to accessory mode (no dock icon)
    NSApp.setActivationPolicy(.accessory)

    // Set up the main menu
    menuManager = AppMenuManager()
    menuManager.setupMainMenu()

    // Initialize components
    setupComponents()

    // Check for accessibility permissions immediately
    checkAccessibilityPermissions()
  }

  private func setupComponents() {
    // Initialize core managers
    windowManager = WindowManager()
    settingsManager = SettingsManager()
    mouseManager = MouseManager()
    mouseManager.configure(with: settingsManager)

    // Initialize and configure shortcut manager with HotKey
    shortcutManager = KeyboardShortcutManager(settingsManager: settingsManager)

    // Register shortcut for teleporting the mouse
    shortcutManager.registerShortcut { [weak self] in
      guard let self = self else { return }
      print("🎯 Teleporting mouse now")
      self.mouseManager.teleportMouseToSavedPosition()
    }

    // Initialize status bar with delegate
    statusBarManager = StatusBarManager(mouseManager: mouseManager)
    statusBarManager.delegate = self
  }

  // MARK: - StatusBarDelegate methods

  func didSelectPreferences() {
    openPreferences()
  }

  func didSelectQuit() {
    NSApplication.shared.terminate(nil)
  }

  // MARK: - Window handling

  private func openPreferences() {
    let prefsVC = PreferencesViewController(settingsManager: settingsManager)
    windowManager.showWindow(ofType: .preferences, withViewController: prefsVC)
    NSApp.activate(ignoringOtherApps: true)
  }

  // MARK: - App lifecycle

  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool
  {
    if !flag {
      openPreferences()
      return false
    }
    return true
  }

  func applicationWillTerminate(_ notification: Notification) {
    settingsManager.saveSettings()
    windowManager.closeAllWindows()
  }

  // MARK: - Permissions

  private func checkAccessibilityPermissions() {
    let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
    let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)

    if !accessEnabled {
      showAccessibilityPermissionsAlert()
    }
  }

  private func showAccessibilityPermissionsAlert() {
    let alert = NSAlert()
    alert.messageText = "Accessibility Permissions Required"
    alert.informativeText = """
      Mouse Teleporter needs accessibility permissions to control your mouse cursor.

      You'll be prompted to grant permissions in System Preferences. 
      Please check "Mouse Teleporter" in the list of apps.

      The app will not function properly without these permissions.
      """
    alert.addButton(withTitle: "Open System Preferences")
    alert.addButton(withTitle: "Later")

    if alert.runModal() == .alertFirstButtonReturn {
      let prefpaneURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
      NSWorkspace.shared.open(prefpaneURL)
    }
  }
}
