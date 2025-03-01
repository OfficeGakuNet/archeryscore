import SwiftUI
import CoreData

struct SettingsDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest private var settings: FetchedResults<Settings>

    let masterID: Int16
    let title: String

    @State private var newContent = ""
    @State private var showAddContentAlert = false

    init(masterID: Int16, title: String) {
        self.masterID = masterID
        self.title = title

        // ✅ `masterID` に基づいたデータ取得 (`no=0` を除外)
        _settings = FetchRequest(
            entity: Settings.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Settings.no, ascending: true)],
            predicate: NSPredicate(format: "masterID == %d", masterID) // ← `masterID` のデータを全取得
        )
    }

    var body: some View {
        List {
            ForEach(settings.filter { $0.no != 0 }, id: \.objectID) { item in // ← `no=0` だけをここで除外
                HStack {
                    Text(item.content ?? "不明")
                    Spacer()
                    if item.isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue) // ✅ 選択された項目にチェックマークを表示
                    }
                }
                .contentShape(Rectangle()) // ✅ タップ範囲を広げる
                .onTapGesture {
                    updateSelection(for: item)
                }
            }
            .onDelete(perform: deleteItem)

            // ✅ 新規追加ボタン
            Button(action: { showAddContentAlert = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("新規追加")
                }
                .foregroundColor(.blue)
            }
            .alert("新規追加", isPresented: $showAddContentAlert) {
                TextField("内容", text: $newContent)
                Button("追加", action: addContent)
                Button("キャンセル", role: .cancel) {}
            }
        }
        .navigationTitle(title) // ✅ 画面のタイトルに `title` を表示
    }

    // ✅ `masterID` 内で `1 つのみ isSelected` にする
    private func updateSelection(for selectedItem: Settings) {
        for item in settings where item.masterID == selectedItem.masterID {
            item.isSelected = (item == selectedItem)
        }
        saveContext()
    }

    // ✅ 新しいコンテンツを追加
    private func addContent() {
        guard !newContent.isEmpty else { return }

        let newEntry = Settings(context: viewContext)
        newEntry.masterID = masterID
        newEntry.no = (settings.map { $0.no }.max() ?? 0) + 1
        newEntry.content = newContent
        newEntry.isSelected = settings.isEmpty  // 最初の項目なら選択状態にする

        saveContext()
        newContent = ""
    }

    // ✅ 設定の削除
    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(settings[index])
        }
        saveContext()
    }

    // ✅ CoreData の保存処理
    private func saveContext() {
        do {
            try viewContext.save()
            print("✅ 設定を保存しました")
        } catch {
            print("❌ 保存エラー: \(error.localizedDescription)")
        }
    }
}
