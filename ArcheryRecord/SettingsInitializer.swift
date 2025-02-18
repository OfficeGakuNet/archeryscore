import SwiftUI
import CoreData

struct SettingsInitializer {
    
    static func resetSettingsData(context: NSManagedObjectContext) {
        // ✅ 既存の `Settings` データをすべて削除
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Settings.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
            try context.save()
            print("✅ 既存の設定データを削除しました")
        } catch {
            print("❌ 設定データの削除に失敗: \(error.localizedDescription)")
        }

        // ✅ 新しい初期データを挿入
        insertNewSettingsData(context: context)
    }

    static func insertNewSettingsData(context: NSManagedObjectContext) {
        let defaultData: [(Int16, Int16, String, Bool)] = [
            (1, 0, "場所", false),
            (1, 1, "大沼田", true),
            (1, 2, "プラザ", false),
            (1, 3, "ふれあい", false),
            (1, 4, "渋谷", false),
            (2, 0, "タイトル", false),
            (2, 1, "練習", true),
            (2, 2, "記録会", false),
            (3, 0, "距離", false),
            (3, 1, "18m", false),
            (3, 2, "30m", true),
            (3, 3, "50m", false),
            (3, 4, "70m", false),
            (3, 5, "90m", false),
            (4, 0, "的", false),
            (4, 1, "大的", true),
            (4, 2, "40cm", false),
            (4, 3, "三つ目的", false)
        ]

        for (masterID, no, content, isSelected) in defaultData {
            let newItem = Settings(context: context)
            newItem.masterID = masterID
            newItem.no = no
            newItem.content = content
            newItem.isSelected = isSelected
        }

        // ✅ 保存処理
        do {
            try context.save()
            print("✅ 新しい初期データを挿入しました")
        } catch {
            print("❌ 新しい設定データの挿入に失敗: \(error.localizedDescription)")
        }
    }
}
