import Cocoa

// Configure the application
let app = NSApplication.shared
app.setActivationPolicy(.accessory)  // Start as an accessory app (no dock icon)

// Initialize app delegate and start the application
let delegate = AppDelegate()
app.delegate = delegate

// Run the application
app.run()
