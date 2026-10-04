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
        // The Dock menu is built synchronously, so keep the recent peers
        // cached and refresh them whenever the app gains or loses focus.
        for name in [NSApplication.didBecomeActiveNotification, NSApplication.didResignActiveNotification] {
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                self?.refreshDockRecentPeers()
            }
        }
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

    // Dock menu: New Connection, then up to 5 recent peers.
    private var dockRecentPeers: [[String: String]] = []

    override func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let menu = NSMenu()
        let newConnection = NSMenuItem(title: "New Connection", action: #selector(dockNewConnection(_:)), keyEquivalent: "")
        newConnection.target = self
        menu.addItem(newConnection)
        if !dockRecentPeers.isEmpty {
            menu.addItem(NSMenuItem.separator())
            for peer in dockRecentPeers {
                guard let id = peer["id"], !id.isEmpty else { continue }
                let name = peer["name"] ?? ""
                let item = NSMenuItem(title: name.isEmpty ? id : "\(name) (\(id))", action: #selector(dockConnectPeer(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = id
                menu.addItem(item)
            }
        }
        refreshDockRecentPeers()
        return menu
    }

    @objc private func dockNewConnection(_ sender: Any?) {
        callMainWindow("newConnection")
    }

    @objc private func dockConnectPeer(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        callMainWindow("connectPeer", arguments: ["id": id])
    }

    private func refreshDockRecentPeers() {
        MainFlutterWindow.mainHostChannel?.invokeMethod("getRecentPeers", arguments: nil) { [weak self] result in
            if let peers = result as? [[String: String]] {
                self?.dockRecentPeers = Array(peers.prefix(5))
            }
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
