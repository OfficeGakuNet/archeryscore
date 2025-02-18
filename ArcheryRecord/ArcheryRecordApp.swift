//
//  ArcheryRecordApp.swift
//  ArcheryRecord
//
//  Created by オフィス岳 on 2025/01/31.
//

import SwiftUI

@main
struct ArcheryScoreApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ScoreInputView()
                .environment(\.managedObjectContext, persistenceController.context)
                .onAppear {
                    // 初期データを挿入
//                    SettingsInitializer.insertDefaultSettings(context: persistenceController.container.viewContext)
                }
        }
    }
}

