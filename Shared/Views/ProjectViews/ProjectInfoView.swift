//
//  ProjectInfoView.swift
//  ProjectManager
//
//  Created by Alex Seifert on 06/01/2021.
//

import SwiftUI

struct ProjectInfoView: View {
    @EnvironmentObject private var projectStore: ProjectStore
    
    private var projectNameBinding: Binding<String> {
        Binding<String>(
            get: {
                return self.projectStore.activeProject?.name ?? ""
        },
            set: { newString in
                self.projectStore.activeProject!.name = newString
        })
    }
    
    private var projectDescriptionBinding: Binding<String> {
        Binding<String>(
            get: {
                return self.projectStore.activeProject?.projectDescription ?? ""
        },
            set: { newString in
                self.projectStore.activeProject!.projectDescription = newString
        })
    }
    
    var body: some View {
        VStack {
            TextField("Project Name", text: projectNameBinding)
                .frame(maxWidth: 300)
            
            TextField("Project Description", text: projectDescriptionBinding)
                .frame(maxWidth: 300)
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}

struct ProjectInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectInfoView().environment(\.managedObjectContext, mockViewContext)
    }
}
