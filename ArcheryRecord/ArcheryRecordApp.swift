//
//  ArcheryRecordApp.swift
//  ArcheryRecord
//
//  Created by オフィス岳 on 2025/01/31.
//

import SwiftUI
import CoreData

@main
struct ArcheryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ScoreInputView()  // ✅ 初期画面を `ScoreInputView` に変更
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    initializeSettingsIfNeeded(context: persistenceController.container.viewContext)
                }
        }
    }
    
    private func initializeSettingsIfNeeded(context: NSManagedObjectContext) {
        let key = "isSettingsInitialized"
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: key) {
            SettingsInitializer.resetSettingsData(context: context)
            defaults.set(true, forKey: key)
            print("✅ Settings 初期化済み（1度だけ）")
        } else {
            print("ℹ️ Settings はすでに初期化済みです")
        }
    }
}

