import AppKit
import Foundation

class HoverMonitor {
    private var eventMonitor: Any?
    private var hoverTimer: Timer?
    private var isHovering = false
    private let onHover: (Bool) -> Void

    // Settings
    @AppStorage("hoverZoneWidth") private var zoneWidth: Double = 200
    @AppStorage("hoverZoneHeight") private var zoneHeight: Double = 30
    @AppStorage("hoverDelay") private var hoverDelay: Double = 0.3

    init(onHover: @escaping (Bool) -> Void) {
        self.onHover = onHover
    }

    deinit {
        stop()
    }

    func start() {
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.handleMouseMove(event)
        }
    }

    func stop() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        hoverTimer?.invalidate()
        hoverTimer = nil
    }

    private func handleMouseMove(_ event: NSEvent) {
        guard let screen = NSScreen.main else { return }

        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = screen.frame

        // Calculate hover zone at top center
        let zoneX = screenFrame.midX - CGFloat(zoneWidth / 2)
        let zoneY = screenFrame.maxY - CGFloat(zoneHeight)
        let hoverZone = NSRect(
            x: zoneX,
            y: zoneY,
            width: CGFloat(zoneWidth),
            height: CGFloat(zoneHeight)
        )

        let isInZone = hoverZone.contains(mouseLocation)

        if isInZone && !isHovering {
            // Start hover timer
            hoverTimer?.invalidate()
            hoverTimer = Timer.scheduledTimer(withTimeInterval: hoverDelay, repeats: false) { [weak self] _ in
                self?.isHovering = true
                self?.onHover(true)
            }
        } else if !isInZone && isHovering {
            // Reset hover state (popup will handle its own dismissal)
            isHovering = false
            hoverTimer?.invalidate()
            hoverTimer = nil
        } else if !isInZone {
            // Cancel pending hover
            hoverTimer?.invalidate()
            hoverTimer = nil
        }
    }
}

// AppStorage wrapper for non-SwiftUI context
@propertyWrapper
struct AppStorage<Value> {
    let key: String
    let defaultValue: Value
    let store: UserDefaults

    init(wrappedValue: Value, _ key: String, store: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = wrappedValue
        self.store = store
    }

    var wrappedValue: Value {
        get {
            store.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            store.set(newValue, forKey: key)
        }
    }
}