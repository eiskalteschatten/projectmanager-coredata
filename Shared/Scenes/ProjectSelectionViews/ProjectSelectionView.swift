//
//  ProjectSelectionView.swift
//  Shared
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI
import CoreData

struct ProjectSelectionView: View {
    @StateObject var appState = AppState()
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) var openURL
    
    @State var showDeleteConfirmation = false
    @State var indexSetToDelete: IndexSet = []
    @State var selectKeeper: ObjectIdentifier?

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.updatedAt, ascending: true), NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    var body: some View {
        ProjectSelectionViewWrapper {
            if projects.count > 0 {
                #if os(macOS)
                let listStyle = DefaultListStyle()
                #else
                let listStyle = InsetGroupedListStyle()
                #endif
                
                List {
                    ForEach(projects) { project in
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(project.name!)
                                    .bold()
                                    .macOS() { $0.font(.system(size: 15)) }
                                
                                let updatedAt = getLocalizedDateWithStyle(date: project.updatedAt!, style: DateFormatter.Style.long)
                                Text(updatedAt)
                                    .if (selectKeeper != project.id) { $0.opacity(0.5) }
                                    .notMacOS() { $0.font(.system(size: 15)) }
                            }
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .padding(7.0)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
                        .background(selectKeeper == project.id ? Color.accentColor : Color.clear)
                        .cornerRadius(5.0)
                        .onTapGesture(count: 2) {
                            selectKeeper = project.id
                            openProject(project: project)
                        }
                        .onTapGesture {
                            selectKeeper = project.id
                        }
                        .contextMenu {
                            Button(action: {
                                openProject(project: project)
                            }) {
                                Text("Open Project")
                                
                                #if !os(macOS)
                                Image(systemName: "doc")
                                #endif
                            }
                            
                            Button(action: addProject) {
                                Text("New Project")
                                
                                #if !os(macOS)
                                Image(systemName: "plus")
                                #endif
                            }
                            
                            Divider()
                            
                            Button(action: {
                                if let index = self.projects.firstIndex(of: project) {
                                    self.confirmDeleteProject(offsets: IndexSet(integer: index))
                                }
                            }) {
                                Text("Delete Project")
                                
                                #if !os(macOS)
                                Image(systemName: "trash")
                                #endif
                            }
                        }
                    }
                    .onDelete(perform: confirmDeleteProject)
                }
                .listStyle(listStyle)
                .toolbar() {
                    #if os(macOS)
                    let toolbarItemPlacement = ToolbarItemPlacement.automatic
                    #else
                    let toolbarItemPlacement = ToolbarItemPlacement.navigationBarTrailing
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    #endif

                    ToolbarItem(placement: toolbarItemPlacement) {
                        Button(action: addProject) {
                            Label("Add Project", systemImage: "plus")
                        }
                    }
                }
                .notMacOS() { $0.padding(.top) }
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
                    #if os(macOS)
                    Image(nsImage: NSApplication.shared.applicationIconImage)
                    #else
                    if let appIconImage = self.getAppIcon() {
                        Image(uiImage: appIconImage)
                    }
                    #endif
                    
                    Text("Welcome to ProjectManager!")
                        .font(.title)
                        .padding(.bottom, 10)
                    
                    Text("To get started, create a new project.")
                        .padding(.bottom, 30)
                    
                    Button("Create New Project", action: addProject)
                }
                .frame(minWidth: 500, minHeight: 400)
                .notMacOS() {
                    $0.toolbar {
                        #if !os(macOS)
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: addProject) {
                                Label("Add Project", systemImage: "plus")
                            }
                        }
                        #endif
                    }
                }
            }
        }
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
            newProject.name = "Untitled Project"

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
    
    #if !os(macOS)
    private func getAppIcon() -> UIImage? {
        guard let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String:Any],
              let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String:Any],
              let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
              let lastIcon = iconFiles.last else { return nil }
        return UIImage(named: lastIcon)
    }
    #endif
}

fileprivate struct ProjectSelectionViewWrapper<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        #if os(macOS)
        Group {
            content()
        }
        #else
        NavigationView {
            content()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

struct ProjectSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectSelectionView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
