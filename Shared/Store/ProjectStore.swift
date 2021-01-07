//
//  ProjectStore.swift
//  ProjectManager
//
//  Created by Alex Seifert on 07.01.21.
//

import SwiftUI

class ProjectStore: ObservableObject {
    @Published var activeProject: Project?
    
    init(activeProject: Project? = nil) {
        self.activeProject = activeProject
    }
}
