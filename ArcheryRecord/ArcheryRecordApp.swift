// ArcheryRecordApp.swift
import SwiftUI
import CoreData

@main
struct ArcheryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ScoreInputView()
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
                .onAppear {
                    initializeSettingsIfNeeded(
                        context: persistenceController.container.viewContext
                    )
                    SettingsInitializer.ensureHeadersExist(
                        context: persistenceController.container.viewContext
                    )
                }
        }
    }

    private func initializeSettingsIfNeeded(context: NSManagedObjectContext) {
        let key = "isSettingsInitialized"
        let ud  = UserDefaults.standard

        if !ud.bool(forKey: key) {
            SettingsInitializer.resetSettingsData(context: context)
            ud.set(true, forKey: key)
        }
    }
}
