//
//  ProjectManagerApp.swift
//  Shared
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI

@main
struct ProjectManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ProjectSelectionView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        
        WindowGroup("Project") {
            ProjectView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
}
