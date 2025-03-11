import Cocoa

class WindowManager {
  private var windowControllers: [String: NSWindowController] = [:]

  enum WindowType: String {
    case preferences
    // Add other window types here as needed
  }

  func showWindow(ofType type: WindowType, withViewController viewController: NSViewController) {
    // Close existing window if it exists
    if let existingController = windowControllers[type.rawValue] {
      existingController.close()
      windowControllers[type.rawValue] = nil
    }

    // Create a panel instead of a standard window to avoid dock visibility
    let panel = NSPanel(
      contentRect: NSRect(x: 0, y: 0, width: 450, height: 300),
      styleMask: [.titled, .closable, .miniaturizable, .nonactivatingPanel],
      backing: .buffered,
      defer: false
    )

    // Configure based on window type
    switch type {
    case .preferences:
      panel.title = "Mouse Teleporter Preferences"
      // The next line ensures the panel behaves like a preferences window
      panel.isFloatingPanel = false
      panel.becomesKeyOnlyIfNeeded = false
      panel.level = .floating
    }

    panel.contentViewController = viewController
    panel.center()

    // Set panel behavior
    panel.hidesOnDeactivate = false

    // Prevent the panel from showing in the window menu
    panel.isExcludedFromWindowsMenu = true

    // Don't show miniaturize button since we're not in the dock
    panel.styleMask.remove(.miniaturizable)

    // Create and store window controller
    let windowController = NSWindowController(window: panel)
    windowControllers[type.rawValue] = windowController

    // Show window and bring app to front
    windowController.showWindow(nil)
    panel.makeKeyAndOrderFront(nil)
  }

  func closeAllWindows() {
    for (_, controller) in windowControllers {
      controller.close()
    }
    windowControllers.removeAll()
  }
}
