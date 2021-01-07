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
    @Binding private var showProject: Bool?
    
    private var project: Project
    private var isNewProject: Bool
    
    init (project: Project, isNewProject: Bool = false, showProject: Binding<Bool?> = .constant(false)) {
        self.project = project
        self.isNewProject = isNewProject
        self._showProject = showProject
        
        if isNewProject {
            self._navSelection = State(initialValue: .projectInfo)
        }
    }
    
    var body: some View {
        ProjectViewWrapper {
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
                            self.showProject = false
                        }) {
                            Label("Back to the Project Manager", systemImage: "chevron.left")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(DefaultNavigationViewStyle())
        .navigationTitle(project.name ?? "Project View")
    }
}

fileprivate struct ProjectViewWrapper<Content>: View where Content: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }


    var body: some View {
        #if os(macOS)
        NavigationView {
            content()
        }
        #else
        Group {
            content()
        }
        #endif
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(project: createMockProject(), isNewProject: false)
            .environment(\.managedObjectContext, mockViewContext)
    }
}
