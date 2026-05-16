import SwiftUI

struct ContentView: View {
    @Environment(Store.self) private var store

    var body: some View {
        RootTabView()
    }
}

#Preview {
    ContentView()
        .environment(Store())
}
