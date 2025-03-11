import Cocoa

class MouseManager {
  var lastSavedPosition: CGPoint?
  private var timer: Timer?
  private var settingsManager: SettingsManager?
  private var manualSavedPosition: CGPoint?
  private var screenDimensions: CGRect?
  private var mousePositionManager = MousePositionManager()

  // Variables to track mouse movement
  private var lastCheckedPosition: CGPoint?
  private var stationaryTime: TimeInterval = 0
  private var lastCheckTime: Date?

  init() {
    updateScreenInfo()
  }

  private func updateScreenInfo() {
    if let mainScreen = NSScreen.main {
      screenDimensions = mainScreen.frame
      print("Screen dimensions: \(mainScreen.frame)")
    }
  }

  func configure(with settingsManager: SettingsManager) {
    self.settingsManager = settingsManager
    setupTimer(interval: 0.5)  // Use a faster check interval to monitor mouse movement

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(settingsChanged),
      name: .settingsChanged,
      object: nil
    )
  }

  @objc private func settingsChanged() {
    guard let settingsManager = self.settingsManager else { return }
    // Keep using a fast check interval but use the settings for stationary detection
    setupTimer(interval: 0.5)
    print("Settings changed - Save interval: \(settingsManager.saveInterval) seconds")
  }

  private func setupTimer(interval: TimeInterval) {
    timer?.invalidate()

    timer = Timer.scheduledTimer(
      timeInterval: interval,
      target: self,
      selector: #selector(checkMouseMovement),
      userInfo: nil,
      repeats: true
    )

    RunLoop.main.add(timer!, forMode: .common)

    // Reset tracking variables
    lastCheckedPosition = nil
    stationaryTime = 0
    lastCheckTime = nil
  }

  @objc func checkMouseMovement() {
    let currentPosition = NSEvent.mouseLocation
    let currentTime = Date()

    // Initialize on first run
    if lastCheckedPosition == nil {
      lastCheckedPosition = currentPosition
      lastCheckTime = currentTime
      return
    }

    // Calculate time since last check
    guard let lastTime = lastCheckTime else { return }
    let elapsed = currentTime.timeIntervalSince(lastTime)

    // Check if mouse has moved (allowing for tiny movements)
    if distanceBetween(currentPosition, lastCheckedPosition!) < 2.0 {
      // Mouse hasn't moved significantly
      stationaryTime += elapsed

      // If stationary for the set interval, save the position
      if let saveInterval = settingsManager?.saveInterval, stationaryTime >= saveInterval {
        savePosition(currentPosition)
        stationaryTime = 0  // Reset timer after saving
        print(
          "🔵 Mouse stationary for \(saveInterval)s - Position saved: \(currentPosition.x), \(currentPosition.y)"
        )
      }
    } else {
      // Mouse has moved, reset stationary time
      stationaryTime = 0
      lastCheckedPosition = currentPosition
    }

    lastCheckTime = currentTime
  }

  private func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
    let dx = point1.x - point2.x
    let dy = point1.y - point2.y
    return sqrt(dx * dx + dy * dy)
  }

  private func savePosition(_ position: CGPoint) {
    lastSavedPosition = position
  }

  @objc func autoSaveMousePosition() {
    // This is now handled by checkMouseMovement
  }

  @objc func saveMousePosition() {
    let mouseLocation = NSEvent.mouseLocation
    lastSavedPosition = mouseLocation
    print("📍 Manual save - Position saved: \(mouseLocation.x), \(mouseLocation.y)")
  }

  func saveCurrentPosition() -> CGPoint {
    saveMousePosition()
    return lastSavedPosition!
  }

  func teleportMouseToSavedPosition() {
    guard let savedPosition = self.lastSavedPosition else {
      print("No Saved Position: No mouse position has been saved yet.")
      return
    }

    print("🎯 Teleporting to saved position: \(savedPosition.x), \(savedPosition.y)")
    print(mousePositionManager.getScreensInfo())

    // Use MousePositionManager for accurate coordinate conversion
    mousePositionManager.teleportMouseToPosition(x: savedPosition.x, y: savedPosition.y)

    print("✅ Mouse teleported to saved position")
  }

  func teleportToAbsolutePosition(x: CGFloat, y: CGFloat) {
    // Use MousePositionManager for accurate coordinate conversion
    print("🎯 Teleporting to absolute position: \(x), \(y)")
    mousePositionManager.teleportMouseToPosition(x: x, y: y)
  }

  func testCoordinateSystem() {
    guard let mainScreen = NSScreen.main else { return }

    // Try teleporting to bottom-left corner with offset
    let bottomLeft = CGPoint(x: mainScreen.frame.minX + 50, y: mainScreen.frame.minY + 50)
    CGWarpMouseCursorPosition(bottomLeft)
  }

  func runDiagnostics() {
    print("🔍 Running mouse teleportation diagnostics")
    print(mousePositionManager.getScreensInfo())

    // Get current position
    let currentPos = NSEvent.mouseLocation
    print("Current position: \(currentPos)")

    // Test teleportation to the same position
    print("Testing teleportation to current position")
    mousePositionManager.teleportMouseToPosition(x: currentPos.x, y: currentPos.y)

    // Check if we need to flip the y-coordinate
    if let mainScreen = NSScreen.main {
      let flippedY = mainScreen.frame.height - currentPos.y
      print("Testing teleportation with flipped Y: \(currentPos.x), \(flippedY)")
      mousePositionManager.teleportMouseToPosition(x: currentPos.x, y: flippedY)
    }
  }

  deinit {
    timer?.invalidate()
    NotificationCenter.default.removeObserver(self)
  }
}
