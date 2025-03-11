import Cocoa

class PreferencesViewController: NSViewController {
  private let settingsManager: SettingsManager
  private var intervalSlider: NSSlider!
  private var intervalValueLabel: NSTextField!
  private var shortcutRecorder: ShortcutRecorderView!

  init(settingsManager: SettingsManager) {
    self.settingsManager = settingsManager
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func loadView() {
    // Create a main view with a white background
    let mainView = NSView(frame: NSRect(x: 0, y: 0, width: 450, height: 300))
    mainView.wantsLayer = true
    mainView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
    self.view = mainView

    setupTabs()

    // Debug print to confirm view is loaded
    print("PreferencesViewController view loaded with size: \(mainView.frame.size)")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Set up UI based on current settings
    updateUIFromSettings()

    // Register for settings change notifications
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(settingsDidChange),
      name: .settingsChanged,
      object: nil
    )
  }

  private func setupTabs() {
    // Create tab view with a frame that fills the entire parent view
    let tabView = NSTabView(frame: NSRect(x: 10, y: 10, width: 430, height: 280))

    // General tab
    let generalTab = NSTabViewItem(identifier: NSUserInterfaceItemIdentifier("general"))
    generalTab.label = "General"
    let generalView = NSView()
    generalTab.view = generalView
    setupGeneralTab(generalView)

    // Shortcut tab
    let shortcutTab = NSTabViewItem(identifier: NSUserInterfaceItemIdentifier("shortcuts"))
    shortcutTab.label = "Shortcuts"
    let shortcutView = NSView()
    shortcutTab.view = shortcutView
    setupShortcutTab(shortcutView)

    tabView.addTabViewItem(generalTab)
    tabView.addTabViewItem(shortcutTab)

    // Ensure tabs are visible
    tabView.tabViewType = .topTabsBezelBorder

    self.view.addSubview(tabView)
    tabView.frame = self.view.bounds
  }

  private func setupGeneralTab(_ containerView: NSView) {
    // Title
    let titleLabel = NSTextField(labelWithString: "Mouse Position Save Interval")
    titleLabel.frame = NSRect(x: 20, y: 220, width: 400, height: 20)
    titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
    containerView.addSubview(titleLabel)

    // Description
    let descLabel = NSTextField(
      wrappingLabelWithString:
        "Adjust how frequently the mouse position is automatically saved (in seconds):")
    descLabel.frame = NSRect(x: 20, y: 180, width: 400, height: 40)
    containerView.addSubview(descLabel)

    // Slider
    intervalSlider = NSSlider(frame: NSRect(x: 20, y: 130, width: 320, height: 30))
    intervalSlider.minValue = 1
    intervalSlider.maxValue = 60
    intervalSlider.doubleValue = settingsManager.saveInterval
    intervalSlider.target = self
    intervalSlider.action = #selector(intervalChanged(_:))
    containerView.addSubview(intervalSlider)

    // Value label
    intervalValueLabel = NSTextField(labelWithString: "\(settingsManager.saveInterval) seconds")
    intervalValueLabel.frame = NSRect(x: 350, y: 130, width: 100, height: 20)
    containerView.addSubview(intervalValueLabel)

    // Apply button
    let applyButton = NSButton(title: "Apply", target: self, action: #selector(applySettings))
    applyButton.frame = NSRect(x: 330, y: 20, width: 100, height: 32)
    applyButton.bezelStyle = .rounded
    containerView.addSubview(applyButton)
  }

  private func setupShortcutTab(_ containerView: NSView) {
    // Title
    let titleLabel = NSTextField(labelWithString: "Keyboard Shortcuts")
    titleLabel.frame = NSRect(x: 20, y: 220, width: 400, height: 20)
    titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
    containerView.addSubview(titleLabel)

    // Description
    let descLabel = NSTextField(
      wrappingLabelWithString:
        "Press the key combination you want to use for teleporting the mouse to its saved position:"
    )
    descLabel.frame = NSRect(x: 20, y: 180, width: 400, height: 40)
    containerView.addSubview(descLabel)

    // Shortcut recorder
    shortcutRecorder = ShortcutRecorderView(frame: NSRect(x: 20, y: 130, width: 400, height: 30))
    shortcutRecorder.currentShortcut = settingsManager.shortcut
    shortcutRecorder.delegate = self
    containerView.addSubview(shortcutRecorder)

    // Current shortcut display
    if let shortcut = settingsManager.shortcut {
      let currentShortcutLabel = NSTextField(
        labelWithString: "Current shortcut: \(shortcut.description)")
      currentShortcutLabel.frame = NSRect(x: 20, y: 90, width: 400, height: 20)
      containerView.addSubview(currentShortcutLabel)
    }

    // Apply button
    let applyButton = NSButton(title: "Apply", target: self, action: #selector(applySettings))
    applyButton.frame = NSRect(x: 330, y: 20, width: 100, height: 32)
    applyButton.bezelStyle = .rounded
    containerView.addSubview(applyButton)
  }

  @objc private func intervalChanged(_ sender: NSSlider) {
    let value = sender.doubleValue.rounded()
    intervalValueLabel.stringValue = "\(value) seconds"
  }

  @objc private func applySettings() {
    // Save interval settings
    settingsManager.saveInterval = intervalSlider.doubleValue.rounded()

    // Save shortcut settings
    if let shortcut = shortcutRecorder.currentShortcut {
      settingsManager.shortcut = shortcut

      print("Saving shortcut: \(shortcut.description)")
      // Post notification that settings changed
      NotificationCenter.default.post(name: .settingsChanged, object: nil)
    }

    // Provide feedback
    let alert = NSAlert()
    alert.messageText = "Settings Saved"
    alert.informativeText = "Your preferences have been updated."
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }

  @objc private func settingsDidChange() {
    // Called when settings change, update UI to reflect new values
    print("Preferences UI: Detected settings change")
    updateUIFromSettings()
  }

  private func updateUIFromSettings() {
    // Update all UI elements based on current settings
    // This would update shortcut displays, checkboxes, etc.
    print("Updating preferences UI from settings")

    // Example: Update shortcut display if you have a shortcutTextField
    // if let shortcut = settingsManager.shortcut {
    //   shortcutTextField.stringValue = shortcut.description
    // } else {
    //   shortcutTextField.stringValue = "No shortcut set"
    // }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

extension PreferencesViewController: ShortcutRecorderDelegate {
  func shortcutRecorderDidChangeShortcut(_ recorder: ShortcutRecorderView) {
    print("Shortcut changed in recorder")
  }
}
