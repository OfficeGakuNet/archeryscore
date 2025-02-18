import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var selectedMasterID: Int16 = 1
    @State private var newContent = ""
    @State private var showAddContentAlert = false

    @FetchRequest(entity: Settings.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Settings.masterID, ascending: true)])
    private var settings: FetchedResults<Settings>

    var categories: [Settings] {
        settings.filter { $0.no == 0 }
    }

    var filteredSettings: [Settings] {
        settings.filter { $0.masterID == selectedMasterID && $0.no != 0 }
    }

    var body: some View {
        NavigationView {
            VStack {
                // ✅ カテゴリリスト（ボタン形式）
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.masterID) { category in
                            Button(action: {
                                selectedMasterID = category.masterID
                            }) {
                                Text(category.content ?? "不明")
                                    .padding()
                                    .background(selectedMasterID == category.masterID ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }

                // ✅ 新しいコンテンツ追加ボタン
                Button(action: {
                    showAddContentAlert = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("新規追加")
                    }
                    .padding()
                    .background(Color.green.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .alert("新規追加", isPresented: $showAddContentAlert) {
                    TextField("内容", text: $newContent)
                    Button("追加", action: addContent)
                    Button("キャンセル", role: .cancel) {}
                }
                .padding()

                // ✅ 選択肢リスト（ラジオボタン）
                List {
                    ForEach(filteredSettings, id: \.self) { item in
                        HStack {
                            Text(item.content ?? "不明")

                            Spacer()

                            // ✅ ラジオボタン（1つのみ選択）
                            Button(action: {
                                updateSelection(for: item)
                            }) {
                                Image(systemName: item.isSelected ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
            }
            .navigationTitle("設定")
        }
    }

    // ✅ 新しいコンテンツを追加
    private func addContent() {
        guard !newContent.isEmpty else { return }

        let newEntry = Settings(context: viewContext)
        newEntry.masterID = selectedMasterID
        newEntry.no = (filteredSettings.map { $0.no }.max() ?? 0) + 1
        newEntry.content = newContent
        newEntry.isSelected = filteredSettings.isEmpty  // 最初の項目なら選択状態にする

        saveContext()
        newContent = ""
    }

    // ✅ `masterID` 内で `1 つのみ isSelected` にする
    private func updateSelection(for selectedItem: Settings) {
        for item in settings where item.masterID == selectedItem.masterID {
            item.isSelected = (item == selectedItem)
        }
        saveContext()
    }

    // ✅ 設定の削除
    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(filteredSettings[index])
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
