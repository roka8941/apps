import AppKit
import SwiftUI

// Custom window that can accept keyboard input
class KeyableWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var statusItemMenu: NSMenu!
    private var popupWindow: NSWindow?
    private var hoverMonitor: HoverMonitor?
    private var popupHostingView: NSHostingView<PopupView>?
    private var mouseExitMonitor: Any?
    private var mouseClickMonitor: Any?
    private var keyMonitor: Any?
    private var hideTimer: Timer?

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
            // 좌클릭, 우클릭 모두 처리
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(statusItemClicked)
            button.target = self
        }

        // 우클릭 메뉴 설정
        setupStatusItemMenu()
    }

    private func setupStatusItemMenu() {
        statusItemMenu = NSMenu()

        let openItem = NSMenuItem(title: "Open JooDock", action: #selector(openFromMenu), keyEquivalent: "")
        openItem.target = self
        statusItemMenu.addItem(openItem)

        statusItemMenu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        statusItemMenu.addItem(quitItem)
    }

    @objc private func statusItemClicked() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            // 우클릭: 메뉴 표시
            statusItem.menu = statusItemMenu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil  // 다음 좌클릭을 위해 메뉴 해제
        } else {
            // 좌클릭: 팝업 토글
            togglePopup()
        }
    }

    @objc private func openFromMenu() {
        showPopup()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
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

        let window = KeyableWindow(
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
        window.acceptsMouseMovedEvents = true

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
        hideTimer?.invalidate()
        hideTimer = nil
        checkTimer?.invalidate()
        checkTimer = nil

        // Reset hover state so it can trigger again
        hoverMonitor?.resetHoverState()

        // Remove all monitors
        if let monitor = mouseExitMonitor {
            NSEvent.removeMonitor(monitor)
            mouseExitMonitor = nil
        }
        if let monitor = mouseClickMonitor {
            NSEvent.removeMonitor(monitor)
            mouseClickMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }

    private var checkTimer: Timer?

    private func setupMouseExitTracking() {
        // Remove existing monitors
        if let monitor = mouseExitMonitor {
            NSEvent.removeMonitor(monitor)
            mouseExitMonitor = nil
        }
        if let monitor = mouseClickMonitor {
            NSEvent.removeMonitor(monitor)
            mouseClickMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
        checkTimer?.invalidate()

        // Use a repeating timer to check mouse position every 0.5 seconds
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkMousePosition()
        }

        // ESC key to close
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC key
                self?.hidePopup()
                return nil
            }
            return event
        }

        // Click outside to close
        mouseClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let window = self?.popupWindow, window.isVisible else { return }
            let mouseLocation = NSEvent.mouseLocation
            let windowFrame = window.frame

            if !windowFrame.contains(mouseLocation) {
                self?.hidePopup()
            }
        }
    }

    private func checkMousePosition() {
        guard let window = popupWindow, window.isVisible else {
            hideTimer?.invalidate()
            hideTimer = nil
            return
        }

        let mouseLocation = NSEvent.mouseLocation
        let windowFrame = window.frame.insetBy(dx: -30, dy: -30) // Add tolerance

        // Check if mouse is in top area (hover zone) or popup
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let isInTopZone = mouseLocation.y > screenHeight - 50

        let isInsideArea = windowFrame.contains(mouseLocation) || isInTopZone

        if isInsideArea {
            // Mouse is inside - cancel hide timer
            hideTimer?.invalidate()
            hideTimer = nil
        } else {
            // Mouse is outside - start 2 second timer if not already running
            if hideTimer == nil {
                hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                    self?.hidePopup()
                }
            }
        }
    }
}