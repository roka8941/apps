import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var popupWindow: NSWindow?
    private var hoverMonitor: HoverMonitor?
    private var popupHostingView: NSHostingView<PopupView>?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupHoverMonitor()
        setupPopupWindow()
    }

    // MARK: - Status Item (Menu Bar Icon)
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "JooDock")
            button.action = #selector(togglePopup)
            button.target = self
        }
    }

    // MARK: - Hover Monitor
    private func setupHoverMonitor() {
        hoverMonitor = HoverMonitor { [weak self] isHovering in
            if isHovering {
                self?.showPopup()
            }
        }
        hoverMonitor?.start()
    }

    // MARK: - Popup Window
    private func setupPopupWindow() {
        let popupView = PopupView(
            onDismiss: { [weak self] in
                self?.hidePopup()
            }
        )

        let hostingView = NSHostingView(rootView: popupView)
        popupHostingView = hostingView

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 450),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.contentView = hostingView
        window.backgroundColor = .clear
        window.isOpaque = false
        window.level = .floating
        window.hasShadow = true
        window.collectionBehavior = [.canJoinAllSpaces, .stationary]

        popupWindow = window
    }

    @objc private func togglePopup() {
        if popupWindow?.isVisible == true {
            hidePopup()
        } else {
            showPopup()
        }
    }

    func showPopup() {
        guard let window = popupWindow else { return }

        // Position at top center of main screen
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let windowWidth = window.frame.width
            let x = screenFrame.midX - windowWidth / 2
            let y = screenFrame.maxY - window.frame.height - 5 // 5px from top

            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Add mouse exit tracking
        setupMouseExitTracking()
    }

    func hidePopup() {
        popupWindow?.orderOut(nil)
    }

    private func setupMouseExitTracking() {
        // Track when mouse leaves the popup area
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            guard let window = self?.popupWindow, window.isVisible else {
                return event
            }

            let mouseLocation = NSEvent.mouseLocation
            let windowFrame = window.frame.insetBy(dx: -20, dy: -20) // Add tolerance

            // Check if mouse is in top area (hover zone) or popup
            let screenHeight = NSScreen.main?.frame.height ?? 0
            let isInTopZone = mouseLocation.y > screenHeight - 40

            if !windowFrame.contains(mouseLocation) && !isInTopZone {
                self?.hidePopup()
            }

            return event
        }
    }
}