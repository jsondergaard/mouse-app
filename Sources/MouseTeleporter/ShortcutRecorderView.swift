import Cocoa

struct KeyboardShortcut {
  var keyCode: UInt16
  var modifierFlags: NSEvent.ModifierFlags

  var description: String {
    var desc = ""

    if modifierFlags.contains(.command) { desc += "⌘" }
    if modifierFlags.contains(.option) { desc += "⌥" }
    if modifierFlags.contains(.shift) { desc += "⇧" }
    if modifierFlags.contains(.control) { desc += "⌃" }

    // Add the key character
    let chars = ["F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12"]
    if keyCode >= 122 && keyCode <= 133 {
      desc += chars[Int(keyCode - 122)]
    } else {
      // Use a simple mapping for common keys
      let keyMap: [UInt16: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
        8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
        23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
        30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 36: "Return",
        37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",",
        44: "/", 45: "N", 46: "M", 47: ".", 48: "Tab", 49: "Space", 50: "`",
      ]

      desc += keyMap[keyCode] ?? "Key\(keyCode)"
    }

    return desc
  }
}

protocol ShortcutRecorderDelegate: AnyObject {
  func shortcutRecorderDidChangeShortcut(_ recorder: ShortcutRecorderView)
}

class ShortcutRecorderView: NSView {
  weak var delegate: ShortcutRecorderDelegate?
  var currentShortcut: KeyboardShortcut?

  private var isRecording = false
  private let textField = NSTextField()
  private var localEventMonitor: Any?

  override init(frame: NSRect) {
    super.init(frame: frame)
    setupView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }

  private func setupView() {
    self.wantsLayer = true
    self.layer?.cornerRadius = 6
    self.layer?.borderWidth = 1
    self.layer?.borderColor = NSColor.lightGray.cgColor

    // Make the text field more visible
    textField.isEditable = false
    textField.isSelectable = false
    textField.isBordered = false
    textField.backgroundColor = NSColor.clear
    textField.alignment = .center
    textField.stringValue = currentShortcut?.description ?? "Click to record shortcut"
    textField.frame = self.bounds.insetBy(dx: 10, dy: 0)

    self.addSubview(textField)

    // Add a click recognizer for the entire view
    let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(viewClicked(_:)))
    self.addGestureRecognizer(clickGesture)
  }

  @objc private func viewClicked(_ sender: NSClickGestureRecognizer) {
    if !isRecording {
      startRecording()
    } else {
      stopRecording()
    }
  }

  private func startRecording() {
    isRecording = true
    textField.stringValue = "Recording... Press key combination"
    self.layer?.borderColor = NSColor.systemBlue.cgColor

    // Make the view the first responder
    self.window?.makeFirstResponder(self)

    // Register for key events at the window level
    localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) {
      [weak self] event in
      guard let self = self, self.isRecording else {
        return event
      }

      // If this is a modifier key event (flagsChanged), just record the state
      if event.type == .flagsChanged {
        return event
      }

      // If this is a key down event, capture it
      if event.type == .keyDown {
        // Ignore if only modifiers were pressed
        if ![16, 17, 18, 19, 20].contains(event.keyCode) {
          self.currentShortcut = KeyboardShortcut(
            keyCode: event.keyCode,
            modifierFlags: event.modifierFlags.intersection(.deviceIndependentFlagsMask)
          )

          // Update UI
          self.textField.stringValue = self.currentShortcut?.description ?? "Invalid shortcut"
          print("Captured shortcut: \(self.currentShortcut?.description ?? "none")")

          // Notify delegate
          self.delegate?.shortcutRecorderDidChangeShortcut(self)
          self.stopRecording()

          // Consume the event
          return nil
        }
      }

      return event
    }

    print("Started recording keyboard shortcut")
  }

  private func stopRecording() {
    isRecording = false

    // Remove event monitor
    if let monitor = localEventMonitor {
      NSEvent.removeMonitor(monitor)
      localEventMonitor = nil
    }

    // Update UI
    textField.stringValue = currentShortcut?.description ?? "Click to record shortcut"
    self.layer?.borderColor = NSColor.lightGray.cgColor

    print("Stopped recording keyboard shortcut")
  }

  override var acceptsFirstResponder: Bool {
    return true
  }

  override func becomeFirstResponder() -> Bool {
    let result = super.becomeFirstResponder()
    print("ShortcutRecorderView became first responder: \(result)")
    return result
  }

  deinit {
    if let monitor = localEventMonitor {
      NSEvent.removeMonitor(monitor)
    }
  }
}
