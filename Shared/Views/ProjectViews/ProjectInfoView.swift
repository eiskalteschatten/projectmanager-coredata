//
//  ProjectInfoView.swift
//  ProjectManager
//
//  Created by Alex Seifert on 06/01/2021.
//

import SwiftUI

struct ProjectInfoView: View {
    @State private var projectName: String = "";
    @State private var projectDescription: String = "";
    
    private var project: Project
    
    init(project: Project) {
        self.project = project
        _projectName = State(initialValue: project.name ?? "")
        _projectDescription = State(initialValue: project.projectDescription ?? "")
    }
    
    var body: some View {
        VStack {
            TextField("Project Name", text: $projectName)
                .frame(maxWidth: 300)
            
            TextField("Project Description", text: $projectDescription)
                .frame(maxWidth: 300)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct ProjectInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectInfoView(project: createMockProject()).environment(\.managedObjectContext, mockViewContext)
    }
}
