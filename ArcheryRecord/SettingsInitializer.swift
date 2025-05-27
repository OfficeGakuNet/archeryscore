// SettingsInitializer.swift
import CoreData

struct SettingsInitializer {

    static func resetSettingsData(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Settings.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(deleteRequest)
        try? context.save()
        insertNewSettingsData(context: context)
    }

    static func insertNewSettingsData(context: NSManagedObjectContext) {
        let defaultData: [(Int16, Int16, String, Bool)] = [
            (1, 0, "場所",   false),
            (2, 0, "タイトル", false),
            (2, 1, "練習",    true),
            (3, 0, "距離",   false),
            (3, 1, "18m",   false),
            (3, 2, "30m",   true),
            (3, 3, "50m",   false),
            (3, 4, "70m",   false),
            (3, 5, "90m",   false),
            (4, 0, "的",     false),
            (4, 1, "大的",   true),
            (4, 2, "40cm",  false),
            (4, 3, "三つ目的", false)
        ]

        defaultData.forEach { mID, no, content, sel in
            let item = Settings(context: context)
            item.masterID  = mID
            item.no        = no
            item.content   = content
            item.isSelected = sel
        }
        try? context.save()
    }

    // 見出し行を必ず存在させる
    static func ensureHeadersExist(context: NSManagedObjectContext) {
        context.performAndWait {
            let headers: [Int16: String] = [
                1: "場所",
                2: "タイトル",
                3: "距離",
                4: "的"
            ]

            for (id, text) in headers {
                let req: NSFetchRequest<Settings> = Settings.fetchRequest()
                req.fetchLimit = 1
                req.predicate  = NSPredicate(format: "masterID == %d AND no == 0", id)

                let header = (try? context.fetch(req))?.first

                switch header {
                case .none:
                    let h = Settings(context: context)
                    h.masterID  = id
                    h.no        = 0
                    h.content   = text
                    h.isSelected = false
                case .some(let h) where (h.content ?? "").isEmpty:
                    h.content = text
                default:
                    break
                }
            }
            try? context.save()
        }
    }
}
