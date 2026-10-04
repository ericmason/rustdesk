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
        // FlutterAppDelegate replaces APP_NAME only in the app menu.
        replaceAppNamePlaceholder(in: NSApplication.shared.mainMenu)
    }

    private func replaceAppNamePlaceholder(in menu: NSMenu?) {
        guard let menu = menu else { return }
        let info = Bundle.main.infoDictionary
        let appName = info?["CFBundleDisplayName"] as? String ?? info?["CFBundleName"] as? String ?? "RustDesk"
        for item in menu.items {
            item.title = item.title.replacingOccurrences(of: "APP_NAME", with: appName)
            replaceAppNamePlaceholder(in: item.submenu)
        }
    }

    // App menu > Settings… (⌘,). The main window opens its Settings tab and
    // comes forward, even when only remote-session windows are open.
    @IBAction func showSettings(_ sender: Any?) {
        callMainWindow("showSettings")
    }

    // App menu > About RustDesk opens the About tab in Settings. A process
    // without the main window's handler shows the standard panel instead.
    @IBAction func showAbout(_ sender: Any?) {
        callMainWindow("showSettings", arguments: ["page": "about"]) {
            NSApplication.shared.orderFrontStandardAboutPanel(nil)
        }
    }

    // Window > RustDesk brings the main window back after it was closed.
    @IBAction func showMainWindow(_ sender: Any?) {
        callMainWindow("showMainWindow")
    }

    // Clicking the Dock icon with no visible windows shows the main window.
    // Return false then, so AppKit doesn't also restore a minimized window.
    // The --server, --cm and --tray processes keep the existing path through
    // applicationShouldOpenUntitledFile (handle_application_should_open_untitled_file).
    override func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        let arg = CommandLine.arguments.dropFirst().first ?? ""
        let isMainProcess = !["--server", "--cm", "--tray"].contains(arg)
        if !flag && isMainProcess && MainFlutterWindow.mainHostChannel != nil {
            showMainWindow(nil)
            return false
        }
        return true
    }

    // Help > RustDesk Help.
    @IBAction func openRustDeskHelp(_ sender: Any?) {
        if let url = URL(string: "https://rustdesk.com/docs/") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Calls `method` on the main window's host channel. `onUnhandled` runs
    /// when no Dart handler answers, such as in the --cm process.
    private func callMainWindow(_ method: String, arguments: Any? = nil, onUnhandled: (() -> Void)? = nil) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        guard let channel = MainFlutterWindow.mainHostChannel else {
            onUnhandled?()
            return
        }
        channel.invokeMethod(method, arguments: arguments) { result in
            if result is FlutterError || (result as AnyObject?) === FlutterMethodNotImplemented {
                onUnhandled?()
            }
        }
    }
}

extension AppDelegate: NSMenuItemValidation {
    // Settings… and About send ⌘, and friends to the main window. In a
    // remote-session window, disable them so the key goes to the peer.
    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(showSettings(_:)), #selector(showAbout(_:)):
            guard let keyWindow = NSApplication.shared.keyWindow else { return true }
            return keyWindow is MainFlutterWindow
        default:
            return true
        }
    }
}
