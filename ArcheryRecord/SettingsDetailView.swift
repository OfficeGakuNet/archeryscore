// SettingsDetailView.swift
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
        _settings = FetchRequest(
            entity: Settings.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Settings.no, ascending: true)],
            predicate: NSPredicate(format: "masterID == %d", masterID)
        )
    }

    // ※ 見出し(no == 0) を除外した配列
    private var listItems: [Settings] {
        settings.filter { $0.no != 0 }
    }

    var body: some View {
        List {
            ForEach(listItems, id: \.objectID) { item in
                HStack {
                    Text(item.content ?? "不明")
                    Spacer()
                    if item.isSelected {
                        Image(systemName: "checkmark").foregroundColor(.blue)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { updateSelection(for: item) }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        delete(item: item)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                }
            }
            .onDelete(perform: deleteItems)

            Button {
                showAddContentAlert = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("新規追加")
                }
                .foregroundColor(.blue)
            }
            .alert("新規追加", isPresented: $showAddContentAlert) {
                TextField("内容", text: $newContent)
                Button("追加", action: addContent)
                Button("キャンセル", role: .cancel) { }
            }
        }
        .navigationTitle(title)
    }

    private func updateSelection(for selectedItem: Settings) {
        for item in settings where item.masterID == selectedItem.masterID {
            item.isSelected = (item == selectedItem)
        }
        saveContext()
    }

    private func addContent() {
        guard !newContent.isEmpty else { return }
        let newEntry = Settings(context: viewContext)
        newEntry.masterID = masterID
        newEntry.no = (settings.map { $0.no }.max() ?? 0) + 1
        newEntry.content = newContent
        newEntry.isSelected = settings.isEmpty
        saveContext()
        newContent = ""
    }

    // swipeActions から呼ぶ単一削除
    private func delete(item: Settings) {
        viewContext.delete(item)
        saveContext()
    }

    // .onDelete 用（複数行対応）
    private func deleteItems(at offsets: IndexSet) {
        offsets.map { listItems[$0] }
               .forEach(viewContext.delete)
        saveContext()
    }

    private func saveContext() {
        try? viewContext.save()
    }
}
