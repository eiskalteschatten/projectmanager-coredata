//
//  ProjectView.swift
//  ProjectManager
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI

fileprivate let testViewContext = PersistenceController.preview.container.viewContext

fileprivate func createTestProject() -> Project {
    let project = Project(context: testViewContext)
    project.createdAt = Date()
    project.updatedAt = Date()
    project.name = "Test Project"
    project.projectDescription = "This is a test project"
    
    return project
}

struct ProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var project: Project
    
    var body: some View {
        Text(project.name ?? "No project name????")
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectView(project: createTestProject()).environment(\.managedObjectContext, testViewContext)
    }
}
