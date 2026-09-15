import AppKit
import SwiftUI

@MainActor
public final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    
    public func applicationDidFinishLaunching(_ notification: Notification) {
        // Set accessory activation policy so it doesn't clutter Dock unless desired
        NSApp.setActivationPolicy(.accessory)
        
        // Setup notch window
        NotchWindowController.shared.setup()
        
        // Setup status bar menu item
        setupStatusItem()
        
        // Listen for screen resolution / display change events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "music.note.house.fill", accessibilityDescription: "OpenNotch")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "OpenNotch v0.1", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Toggle Notch Tray", action: #selector(toggleNotch), keyEquivalent: "n"))
        menu.addItem(NSMenuItem(title: "Refresh Music Status", action: #selector(refreshMusic), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit OpenNotch", action: #selector(quitApp), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func toggleNotch() {
        NotchWindowController.shared.toggleExpanded()
    }
    
    @objc private func refreshMusic() {
        MusicService.shared.updateNowPlaying()
    }
    
    @objc private func screenParametersChanged() {
        NotchWindowController.shared.updateGeometry()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
