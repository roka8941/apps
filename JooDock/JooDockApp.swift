import SwiftUI

@main
struct JooDockApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @AppStorage("hoverZoneWidth") private var hoverZoneWidth: Double = 200
    @AppStorage("hoverZoneHeight") private var hoverZoneHeight: Double = 30
    @AppStorage("hoverDelay") private var hoverDelay: Double = 0.3

    var body: some View {
        Form {
            Section("Hover Zone Settings") {
                HStack {
                    Text("Width:")
                    Slider(value: $hoverZoneWidth, in: 100...400, step: 10)
                    Text("\(Int(hoverZoneWidth))px")
                        .frame(width: 50)
                }

                HStack {
                    Text("Height:")
                    Slider(value: $hoverZoneHeight, in: 10...50, step: 5)
                    Text("\(Int(hoverZoneHeight))px")
                        .frame(width: 50)
                }

                HStack {
                    Text("Delay:")
                    Slider(value: $hoverDelay, in: 0.1...1.0, step: 0.1)
                    Text("\(String(format: "%.1f", hoverDelay))s")
                        .frame(width: 50)
                }
            }

            Section("About") {
                Text("JooDock v1.0")
                    .font(.headline)
                Text("Quick access to your favorite files")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}