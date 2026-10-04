import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
    var launched = false;
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      dummy_method_to_enforce_bundling()
    // https://github.com/leanflutter/window_manager/issues/214
    return false
  }
    
    override func applicationShouldOpenUntitledFile(_ sender: NSApplication) -> Bool {
        if (launched) {
            handle_applicationShouldOpenUntitledFile();
        }
        return true
    }
    
    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        launched = true;
        NSApplication.shared.activate(ignoringOtherApps: true);
    }

    // App menu > Settings… (⌘,). The main window opens its Settings tab and
    // comes forward, even when only remote-session windows are open.
    @IBAction func showSettings(_ sender: Any?) {
        callMainWindow("showSettings")
    }

    // App menu > About RustDesk opens the About tab in Settings.
    @IBAction func showAbout(_ sender: Any?) {
        callMainWindow("showSettings", arguments: ["page": "about"])
    }

    // Help > RustDesk Help.
    @IBAction func openRustDeskHelp(_ sender: Any?) {
        if let url = URL(string: "https://rustdesk.com/docs/") {
            NSWorkspace.shared.open(url)
        }
    }

    private func callMainWindow(_ method: String, arguments: Any? = nil) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        MainFlutterWindow.mainHostChannel?.invokeMethod(method, arguments: arguments)
    }
}
