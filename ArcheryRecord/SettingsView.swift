import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: Settings.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Settings.masterID, ascending: true)]
    ) private var settings: FetchedResults<Settings>

    var categories: [Settings] {
        settings.filter { $0.no == 0 } // ヘッダー情報のみ取得
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.objectID) { category in
                    NavigationLink(destination: SettingsDetailView(masterID: category.masterID, title: category.content ?? "未設定")) {
                        Text(category.content ?? "未設定")
                    }
                }
            }
            .navigationTitle("設定")
        }
    }
}
