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
    @Binding private var project: Project?
    
    private var isNewProject: Bool
    
    init (project: Binding<Project?>, isNewProject: Bool = false) {
        self._project = project
        self.isNewProject = isNewProject
        
        if isNewProject {
            self._navSelection = State(initialValue: .projectInfo)
        }
    }
    
    var body: some View {
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
            .listStyle(SidebarListStyle())
            .macOS() {
                $0.toolbar() {
                    ToolbarItem(placement: .automatic) {
                        Button(action: {
                            self.project = nil
                        }) {
                            Label("Back to the Project Manager", systemImage: "chevron.left")
                        }
                    }
                }
            }
        }
        .navigationTitle(project?.name ?? "Project View")
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(project: .constant(createMockProject()), isNewProject: false)
            .environment(\.managedObjectContext, mockViewContext)
    }
}
