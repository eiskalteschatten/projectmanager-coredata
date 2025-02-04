//
//  ProjectSelectionMacOSView.swift
//  ProjectManager (macOS)
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI

struct ProjectSelectionMacOSView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var projectStore: ProjectStore
    
    @State private var showDeleteConfirmation = false
    @State private var indexSetToDelete: IndexSet = []
    @State private var selectKeeper: ObjectIdentifier?
    @State private var showProject: Bool? = false
    @State private var isNewProject = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.updatedAt, ascending: false), NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    var body: some View {
        if showProject! && projectStore.activeProject != nil {
            ProjectView(isNewProject: isNewProject, showProject: $showProject)
        }
        else {
            if projects.count > 0 {
                List {
                    ForEach(projects) { project in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(project.name!)
                                    .font(.system(size: 15))
                                
                                HStack {
                                    let updatedAt = getLocalizedDateWithStyle(date: project.updatedAt!, style: DateFormatter.Style.short)
                                    Text(updatedAt)
                                    Text(project.projectDescription ?? "")
                                }
                                .if (selectKeeper != project.id) { $0.opacity(0.5) }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                        }
                        .contentShape(Rectangle())
                        .padding(.vertical, 10)
                        .padding(.horizontal, 15)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        .background(selectKeeper == project.id ? Color.accentColor : Color.clear)
                        .cornerRadius(5.0)
                        .onTapGesture {
                            selectKeeper = project.id
                            self.projectStore.activeProject = project
                            self.showProject = true
                        }
                        .contextMenu {
                            Button(action: {
                                self.projectStore.activeProject = project
                            }) {
                                Text("Open Project")
                            }
                            
                            Button(action: addProject) {
                                Text("New Project")
                            }
                            
                            Divider()
                            
                            Button(action: {
                                if let index = self.projects.firstIndex(of: project) {
                                    self.confirmDeleteProject(offsets: IndexSet(integer: index))
                                }
                            }) {
                                Text("Delete Project")
                            }
                        }
                    }
                    .onDelete(perform: confirmDeleteProject)
                }
                .toolbar() {
                    ToolbarItem(placement: .automatic) {
                        Button(action: addProject) {
                            Label("Add Project", systemImage: "plus")
                        }
                    }
                }
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete project?"),
                        message: Text("Are you sure you want to delete this project? This action cannot be done."),
                        primaryButton: .default(Text("No")),
                        secondaryButton: .default(Text("Yes"), action: deleteProject)
                    )
                }
                .navigationTitle("Manage Projects")
                .onAppear() {
                    projectStore.projectNavStatus = .manager
                }
            }
            else {
                VStack {
                    Image(nsImage: NSApplication.shared.applicationIconImage)
                    
                    Text("Welcome to ProjectManager!")
                        .font(.title)
                        .padding(.bottom, 10)
                    
                    Text("To get started, create a new project.")
                        .padding(.bottom, 30)
                    
                    Button("Create New Project", action: addProject)
                }
                .frame(minWidth: 500, minHeight: 400)
                .onAppear() {
                    projectStore.projectNavStatus = .noProjects
                }
            }
        }
    }
    
    private func addProject() {
        withAnimation {
            let newProject = Project(context: viewContext)
            newProject.createdAt = Date()
            newProject.updatedAt = Date()
            newProject.name = DEFAULT_NEW_PROJECT_NAME

            do {
                try viewContext.save()
                self.projectStore.activeProject = newProject
                self.isNewProject = true
                self.showProject = true
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func confirmDeleteProject(offsets: IndexSet) {
        self.indexSetToDelete = offsets
        self.showDeleteConfirmation = true
    }

    private func deleteProject() {
        withAnimation {
            self.indexSetToDelete.map { projects[$0] }.forEach(viewContext.delete)

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

struct ProjectSelectionMacOSView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectSelectionMacOSView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
