//
//  ProjectSelectionViewiOSView.swift
//  ProjectManager (iOS)
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI

struct ProjectSelectionViewiOSView: View {
    @StateObject var appState = AppState()
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) var openURL
    
    @State var showDeleteConfirmation = false
    @State var indexSetToDelete: IndexSet = []

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.updatedAt, ascending: true), NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    var body: some View {
        NavigationView {
            if projects.count > 0 {
                List {
                    ForEach(projects) { project in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(project.name!)
                                    .bold()
                                
                                let updatedAt = getLocalizedDateWithStyle(date: project.updatedAt!, style: DateFormatter.Style.long)
                                Text(updatedAt)
                                    .font(.system(size: 15))
                            }
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(7.0)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        .cornerRadius(5.0)
                        .onTapGesture {
                            openProject(project: project)
                        }
                        .contextMenu {
                            Button(action: {
                                openProject(project: project)
                            }) {
                                Text("Open Project")
                                Image(systemName: "doc")
                            }
                            
                            Button(action: addProject) {
                                Text("New Project")
                                Image(systemName: "plus")
                            }
                            
                            Divider()
                            
                            Button(action: {
                                if let index = self.projects.firstIndex(of: project) {
                                    self.confirmDeleteProject(offsets: IndexSet(integer: index))
                                }
                            }) {
                                Text("Delete Project")
                                Image(systemName: "trash")
                            }
                        }
                    }
                    .onDelete(perform: confirmDeleteProject)
                }
                .listStyle(InsetGroupedListStyle())
                .toolbar() {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addProject) {
                            Label("Add Project", systemImage: "plus")
                        }
                    }
                }
                .padding(.top)
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Delete project?"),
                        message: Text("Are you sure you want to delete this project? This action cannot be done."),
                        primaryButton: .default(Text("No")),
                        secondaryButton: .default(Text("Yes"), action: deleteProject)
                    )
                }
                .navigationTitle("Manage Projects")
            }
            else {
                VStack {
                    if let appIconImage = self.getAppIcon() {
                        Image(uiImage: appIconImage)
                    }
                    
                    Text("Welcome to ProjectManager!")
                        .font(.title)
                        .padding(.bottom, 10)
                    
                    Text("To get started, create a new project.")
                        .padding(.bottom, 30)
                    
                    Button("Create New Project", action: addProject)
                }
                .frame(minWidth: 500, minHeight: 400)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: addProject) {
                            Label("Add Project", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func openProject(project: Project) {
        appState.activeProjects.append(project)
        
        if let url = URL(string: "projectmanager://project") {
            openURL(url)
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
                appState.activeProjects.append(newProject)
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        
        if let url = URL(string: "projectmanager://project") {
            openURL(url)
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
    
    private func getAppIcon() -> UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }
}

struct ProjectSelectionViewiOSView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectSelectionViewiOSView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
