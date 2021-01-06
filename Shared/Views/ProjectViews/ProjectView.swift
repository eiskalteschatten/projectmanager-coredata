//
//  ProjectView.swift
//  ProjectManager
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI

fileprivate enum ProjectScreen: Int {
    case projectInfo
}

struct ProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var navSelection: ProjectScreen?
    
    var project: Project
    var isNewProject: Bool
    
    init (project: Project, isNewProject: Bool = false) {
        self.project = project
        self.isNewProject = isNewProject
        
        if isNewProject {
            self.navSelection = .projectInfo
        }
    }
    
    var body: some View {
        #if os(macOS)
        let listStyle = SidebarListStyle()
        #else
        let listStyle = InsetGroupedListStyle()
        #endif
        
        NavigationView {
            List {
                NavigationLink(
                    destination: ProjectInfoView(project: project),
                    tag: ProjectScreen.projectInfo,
                    selection: $navSelection,
                    label: {
                        Label("Project Info", systemImage: "info.circle")
                    }
                )
            }
            .listStyle(listStyle)
        }
        .navigationTitle(project.name ?? "Project View")
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(project: createMockProject(), isNewProject: false)
            .environment(\.managedObjectContext, mockViewContext)
    }
}
