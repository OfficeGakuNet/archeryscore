import SwiftUI
import CoreData

struct SettingsInitializer {
    static func insertDefaultSettings(context: NSManagedObjectContext) {
        // 既存データがあるか確認
        let fetchRequest: NSFetchRequest<Settings> = Settings.fetchRequest()
        do {
            let count = try context.count(for: fetchRequest)
            if count > 0 {
                print("✅ 既に初期データが存在するため、挿入をスキップ")
                return
            }
        } catch {
            print("❌ データのチェックに失敗: \(error.localizedDescription)")
        }

        // ✅ 初期データの定義
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

        // ✅ CoreData にデータを挿入
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
            print("✅ 初期データの挿入が完了しました")
        } catch {
            print("❌ データの挿入に失敗: \(error.localizedDescription)")
        }
    }
}
