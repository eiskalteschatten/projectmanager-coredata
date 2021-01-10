//
//  ProjectStore.swift
//  ProjectManager
//
//  Created by Alex Seifert on 07.01.21.
//

import SwiftUI

enum ProjectNavStatus {
    case noProjects, manager, openProject
}

class ProjectStore: ObservableObject {
    @Published var activeProject: Project?
    @Published var projectNavStatus: ProjectNavStatus = .noProjects
    
    init(activeProject: Project? = nil) {
        self.activeProject = activeProject
    }
}
