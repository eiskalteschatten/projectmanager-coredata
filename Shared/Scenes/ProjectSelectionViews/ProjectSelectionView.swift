//
//  ProjectSelectionView.swift
//  Shared
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI
import CoreData

struct ProjectSelectionView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        #if os(macOS)
        ProjectSelectionMacOSView()
        #else
        ProjectSelectionViewiOSView()
        #endif
    }
}

struct ProjectSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectSelectionView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
