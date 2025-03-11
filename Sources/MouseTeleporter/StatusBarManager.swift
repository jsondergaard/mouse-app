import Cocoa

protocol StatusBarDelegate: AnyObject {
  func didSelectPreferences()
  func didSelectQuit()
}

class StatusBarManager {
  private var statusItem: NSStatusItem!
  private let mouseManager: MouseManager
  weak var delegate: StatusBarDelegate?

  init(mouseManager: MouseManager) {
    self.mouseManager = mouseManager
    setupStatusBar()
  }

  private func setupStatusBar() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    if let button = statusItem.button {
      button.title = "🖱️"
      button.action = #selector(showMenu)
      button.target = self
    }
  }

  @objc private func showMenu() {
    let menu = NSMenu()

    // Current position
    let currentPos = NSEvent.mouseLocation
    menu.addItem(
      NSMenuItem(
        title: String(
          format: "Current position: (%.1f, %.1f)", currentPos.x, currentPos.y), action: nil,
        keyEquivalent: ""))

    // Screen dimensions
    if let mainScreen = NSScreen.main {
      menu.addItem(
        NSMenuItem(
          title: String(
            format: "Screen: %.1f x %.1f", mainScreen.frame.width, mainScreen.frame.height),
          action: nil, keyEquivalent: ""))
    }

    // Last saved position with status indicator
    if let lastPos = mouseManager.lastSavedPosition {
      let savedPosItem = NSMenuItem(
        title: String(format: "✓ Saved position: (%.1f, %.1f)", lastPos.x, lastPos.y),
        action: nil, keyEquivalent: "")
      savedPosItem.attributedTitle = NSAttributedString(
        string: savedPosItem.title,
        attributes: [NSAttributedString.Key.foregroundColor: NSColor.systemGreen])
      menu.addItem(savedPosItem)
    } else {
      let noSavedPosItem = NSMenuItem(
        title: "❌ No position saved yet",
        action: nil, keyEquivalent: "")
      menu.addItem(noSavedPosItem)
    }

    menu.addItem(NSMenuItem.separator())

    // Save position option
    let saveItem = NSMenuItem(
      title: "Save Current Position", action: #selector(savePosition), keyEquivalent: "s")
    saveItem.target = self
    menu.addItem(saveItem)

    // Teleport to saved position option
    if mouseManager.lastSavedPosition != nil {
      let teleportItem = NSMenuItem(
        title: "Teleport to Saved Position", action: #selector(teleportToSaved), keyEquivalent: "t")
      teleportItem.target = self
      menu.addItem(teleportItem)
    }

    menu.addItem(NSMenuItem.separator())

    // Test options
    let testItem = NSMenuItem(
      title: "Teleport to Center", action: #selector(teleportToCenter), keyEquivalent: "t")
    testItem.target = self
    menu.addItem(testItem)

    let testBottomLeftItem = NSMenuItem(
      title: "Teleport to Bottom Left", action: #selector(teleportToBottomLeft), keyEquivalent: "b")
    testBottomLeftItem.target = self
    menu.addItem(testBottomLeftItem)

    let testTopRightItem = NSMenuItem(
      title: "Teleport to Top Right", action: #selector(teleportToTopRight), keyEquivalent: "r")
    testTopRightItem.target = self
    menu.addItem(testTopRightItem)

    menu.addItem(NSMenuItem.separator())

    // Add diagnostics menu item
    menu.addItem(NSMenuItem.separator())
    let diagnosticsItem = NSMenuItem(
      title: "Run Diagnostics", action: #selector(runDiagnostics), keyEquivalent: "d")
    diagnosticsItem.target = self
    menu.addItem(diagnosticsItem)

    // Preferences option
    let prefsItem = NSMenuItem(
      title: "Preferences...", action: #selector(openPreferences), keyEquivalent: ",")
    prefsItem.target = self
    menu.addItem(prefsItem)

    // Quit option
    menu.addItem(NSMenuItem.separator())
    let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
    quitItem.target = self
    menu.addItem(quitItem)

    statusItem.menu = menu
    statusItem.button?.performClick(nil)
    statusItem.menu = nil
  }

  @objc private func teleportToSaved() {
    mouseManager.teleportMouseToSavedPosition()
  }

  @objc private func savePosition() {
    mouseManager.saveMousePosition()
    // Notification removed
    print("Position Saved: Current mouse position has been saved.")
  }

  @objc private func teleportToCenter() {
    if let mainScreen = NSScreen.main {
      mouseManager.teleportToAbsolutePosition(x: mainScreen.frame.midX, y: mainScreen.frame.midY)
    }
  }

  @objc private func teleportToBottomLeft() {
    if let mainScreen = NSScreen.main {
      mouseManager.teleportToAbsolutePosition(
        x: mainScreen.frame.minX + 50, y: mainScreen.frame.minY + 50)
    }
  }

  @objc private func teleportToTopRight() {
    if let mainScreen = NSScreen.main {
      mouseManager.teleportToAbsolutePosition(
        x: mainScreen.frame.maxX - 50, y: mainScreen.frame.maxY - 50)
    }
  }

  @objc private func openPreferences() {
    delegate?.didSelectPreferences()
  }

  @objc private func quit() {
    delegate?.didSelectQuit()
  }

  @objc private func runDiagnostics() {
    mouseManager.runDiagnostics()
  }
}
