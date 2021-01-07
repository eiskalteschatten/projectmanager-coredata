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
    @EnvironmentObject private var projectStore: ProjectStore
    
    @State private var navSelection: ProjectScreen?
    @Binding private var showProject: Bool?
    
    private var isNewProject: Bool
    
    init (isNewProject: Bool = false, showProject: Binding<Bool?> = .constant(false)) {
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
                    destination: ProjectInfoView(),
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
        .navigationTitle(projectStore.activeProject?.name ?? "Project View")
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
        ProjectView(isNewProject: false)
            .environment(\.managedObjectContext, mockViewContext)
            .environmentObject(ProjectStore(activeProject: createMockProject()))
    }
}
