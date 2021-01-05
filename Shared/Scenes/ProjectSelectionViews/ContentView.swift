//
//  ContentView.swift
//  Shared
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.updatedAt, ascending: true), NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>

    var body: some View {
        List {
            ForEach(projects) { project in
                Text(project.name!)
            }
            .onDelete(perform: deleteProject)
        }
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif

            Button(action: addProject) {
                Label("Add Project", systemImage: "plus")
            }
        }
    }

    private func addProject() {
        withAnimation {
            let newProject = Project(context: viewContext)
            newProject.createdAt = Date()
            newProject.updatedAt = Date()
            newProject.name = "Test Project"

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteProject(offsets: IndexSet) {
        withAnimation {
            offsets.map { projects[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
