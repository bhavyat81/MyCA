import SwiftUI

@main
struct MyCAApp: App {
    @State private var store = Store()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(store)
                .onAppear {
                    let now = Date()
                    let cal = Calendar.current
                    let y = cal.component(.year, from: now)
                    let m = cal.component(.month, from: now)
                    store.materializeRecurring(year: y, month: m)
                }
        }
    }
}
