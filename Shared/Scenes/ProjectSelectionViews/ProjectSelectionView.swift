//
//  ProjectSelectionView.swift
//  Shared
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI
import CoreData

struct ProjectSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext

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
                        VStack(alignment: .leading, spacing: 3) {
                            Text(project.name!)
                                .bold()
                                .macOS() { $0.font(.system(size: 15)) }
                            
                            let updatedAt = getLocalizedDateWithStyle(date: project.updatedAt!, style: DateFormatter.Style.long)
                            Text(updatedAt)
                                .opacity(0.5)
                                .notMacOS() { $0.font(.system(size: 15)) }
                            
                        }
                        .padding(5.0)
                        .contextMenu {
                            Button("Delete Project") {
                                if let index = self.projects.firstIndex(of: project) {
                                    self.deleteProject(offsets: IndexSet(integer: index))
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteProject)
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

    private func addProject() {
        withAnimation {
            let newProject = Project(context: viewContext)
            newProject.createdAt = Date()
            newProject.updatedAt = Date()
            newProject.name = "Untitled Project"

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
