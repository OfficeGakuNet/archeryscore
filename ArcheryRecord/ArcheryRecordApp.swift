//
//  ArcheryRecordApp.swift
//  ArcheryRecord
//
//  Created by オフィス岳 on 2025/01/31.
//

import SwiftUI

@main
struct ArcheryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ScoreInputView()  // ✅ 初期画面を `ScoreInputView` に変更
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
//                    SettingsInitializer.resetSettingsData(context: persistenceController.container.viewContext)
                }
        }
    }
}
