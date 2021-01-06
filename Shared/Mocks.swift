//
//  Mocks.swift
//  ProjectManager
//
//  Created by Alex Seifert on 06/01/2021.
//

import Foundation

let mockViewContext = PersistenceController.preview.container.viewContext

func createMockProject() -> Project {
    let project = Project(context: mockViewContext)
    project.createdAt = Date()
    project.updatedAt = Date()
    project.name = "Test Project"
    project.projectDescription = "This is a test project"
    
    return project
}
