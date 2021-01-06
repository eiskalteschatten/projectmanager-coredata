//
//  ProjectInfoView.swift
//  ProjectManager
//
//  Created by Alex Seifert on 06/01/2021.
//

import SwiftUI

struct ProjectInfoView: View {
    var project: Project
    
    var body: some View {
        Text("Project Info")
//        TextField("Project Name", text: project.name)
    }
}

struct ProjectInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectInfoView(project: createMockProject()).environment(\.managedObjectContext, mockViewContext)
    }
}
