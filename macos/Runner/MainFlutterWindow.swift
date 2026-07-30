import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow, NSWindowDelegate {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    self.titleVisibility = .hidden
    self.titlebarAppearsTransparent = true
    self.title = ""
    self.delegate = self

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    self.orderOut(nil)
    return false
  }
}
