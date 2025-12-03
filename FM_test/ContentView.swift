import SwiftUI

import Foundation

struct ContentView: View {
    @StateObject var treeManager = TreeDataManager()
    var body: some View {
        MainMenuView(treeManager: treeManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
