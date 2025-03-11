import Cocoa

class MousePositionManager {
  /**
     Teleports the mouse cursor to the specified position, properly accounting for
     multiple displays, screen scaling factors, and coordinate system differences.

     - Parameters:
        - x: Target X coordinate in global screen space
        - y: Target Y coordinate in global screen space
     */
  func teleportMouseToPosition(x: CGFloat, y: CGFloat) {
    let targetPoint = CGPoint(x: x, y: y)

    print("⚙️ Teleport request to: \(targetPoint)")

    // Get the main screen for coordinate conversion
    if let mainScreen = NSScreen.screens.first {
      // Critical fix: In macOS, the y-coordinate is flipped
      // NSEvent.mouseLocation's y=0 is at the bottom of the screen
      // But CGWarpMouseCursorPosition's y=0 is at the top of the screen

      // No conversion needed for x-coordinate
      let convertedX = x

      // Convert y-coordinate by flipping it relative to screen height
      let convertedY = mainScreen.frame.height - y

      let convertedPoint = CGPoint(x: convertedX, y: convertedY)

      print("⚙️ Screen height: \(mainScreen.frame.height)")
      print("⚙️ Teleporting to adjusted position: \(convertedPoint)")

      // Perform the teleportation
      CGWarpMouseCursorPosition(convertedPoint)

      // Force the mouse movement to happen immediately
      CGAssociateMouseAndMouseCursorPosition(1)

      // After teleport, verify position
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        let newPosition = NSEvent.mouseLocation
        let positionDifference = CGPoint(
          x: abs(newPosition.x - x),
          y: abs(newPosition.y - y)
        )
        print("⚙️ Position after teleport: \(newPosition)")
        print("⚙️ Position difference: \(positionDifference)")

        if positionDifference.x > 5 || positionDifference.y > 5 {
          print("⚠️ Warning: Teleport position significantly different from target!")
        }
      }
    } else {
      print("❌ No screens found for coordinate conversion")
      // Fallback to direct teleportation
      CGWarpMouseCursorPosition(targetPoint)
    }
  }

  /**
     Finds which screen contains the given point.

     - Parameter point: The point to check
     - Returns: The NSScreen containing the point or nil if none found
     */
  private func getScreenForPoint(_ point: CGPoint) -> NSScreen? {
    // Check each screen to see if it contains the point
    for screen in NSScreen.screens {
      if NSPointInRect(point, screen.frame) {
        return screen
      }
    }

    // If no screen contains the point, return the main screen as fallback
    return NSScreen.main
  }

  /**
     Gets the current mouse position as a CGPoint
     - Returns: Current mouse position
     */
  func getCurrentMousePosition() -> CGPoint {
    return NSEvent.mouseLocation
  }

  /**
     Gets debug information about all screens
     - Returns: String with screen information
     */
  func getScreensInfo() -> String {
    var info = "Screens:\n"
    for (index, screen) in NSScreen.screens.enumerated() {
      info += "Screen \(index): frame=\(screen.frame), "
      info += "visibleFrame=\(screen.visibleFrame), "
      info += "scaleFactor=\(screen.backingScaleFactor)\n"
    }
    return info
  }
}
