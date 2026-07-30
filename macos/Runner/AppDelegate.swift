import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  var statusItem: NSStatusItem?

  override func applicationDidFinishLaunching(_ aNotification: Notification) {
    super.applicationDidFinishLaunching(aNotification)

    // Set Dock Icon dynamically to Task Flow App Icon
    if let iconPath = Bundle.main.path(forResource: "app_icon", ofType: "png", inDirectory: "flutter_assets/assets/icon"),
       let image = NSImage(contentsOfFile: iconPath) {
      NSApp.applicationIconImage = image
    }

    // Create Apple Top Menu Bar Status Item
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    if let button = statusItem?.button {
      if #available(macOS 11.0, *) {
        button.image = NSImage(systemSymbolName: "checkmark.square.fill", accessibilityDescription: "Task Flow")
      } else {
        button.image = NSImage(named: NSImage.menuOnStateTemplateName)
      }
      button.action = #selector(showWindow)
      button.target = self
    }

    // Create Menu Bar Context Menu
    let menu = NSMenu()
    let titleItem = NSMenuItem(title: "Task Flow v1.0.30", action: nil, keyEquivalent: "")
    titleItem.isEnabled = false
    menu.addItem(titleItem)
    menu.addItem(NSMenuItem.separator())

    menu.addItem(NSMenuItem(title: "Open Task Flow", action: #selector(showWindow), keyEquivalent: "o"))
    menu.addItem(NSMenuItem(title: "Hide to Background", action: #selector(hideWindow), keyEquivalent: "h"))
    menu.addItem(NSMenuItem.separator())
    menu.addItem(NSMenuItem(title: "Quit Task Flow", action: #selector(quitApp), keyEquivalent: "q"))

    statusItem?.menu = menu
  }

  @objc func showWindow() {
    if let window = mainFlutterWindow {
      window.makeKeyAndOrderFront(nil)
      NSApp.activate(ignoringOtherApps: true)
    }
  }

  @objc func hideWindow() {
    if let window = mainFlutterWindow {
      window.orderOut(nil)
    }
  }

  @objc func quitApp() {
    NSApp.terminate(nil)
  }

  // Keep app running in the background when the main window is closed
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
