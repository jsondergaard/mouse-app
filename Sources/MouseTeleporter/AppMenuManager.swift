import Cocoa

class AppMenuManager {

  func setupMainMenu() {
    // Set up the main menu
    let mainMenu = NSMenu()
    NSApplication.shared.mainMenu = mainMenu

    // Application menu
    let appMenu = NSMenu()
    let appName = ProcessInfo.processInfo.processName
    let appMenuItem = NSMenuItem()
    mainMenu.addItem(appMenuItem)
    appMenuItem.submenu = appMenu

    // Add standard menu items
    appMenu.addItem(
      NSMenuItem(
        title: "About \(appName)",
        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
        keyEquivalent: ""))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(NSMenuItem(title: "Preferences...", action: nil, keyEquivalent: ","))
    appMenu.addItem(NSMenuItem.separator())
    appMenu.addItem(
      NSMenuItem(
        title: "Quit \(appName)",
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"))

    // Add Edit menu
    let editMenu = NSMenu(title: "Edit")
    let editMenuItem = NSMenuItem(title: "Edit", action: nil, keyEquivalent: "")
    editMenuItem.submenu = editMenu
    mainMenu.addItem(editMenuItem)

    // Standard edit menu items
    editMenu.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
    editMenu.addItem(NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "Z"))
    editMenu.addItem(NSMenuItem.separator())
    editMenu.addItem(
      NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
    editMenu.addItem(
      NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
    editMenu.addItem(
      NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
    editMenu.addItem(
      NSMenuItem(title: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a"))
  }
}
