//
//  GlobalExtensions.swift
//  ProjectManager
//
//  Created by Alex Seifert on 05/01/2021.
//

import SwiftUI

extension View {
    @ViewBuilder
    // Add support for conditional modifiers on views
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
          transform(self)
        }
        else {
          self
        }
    }
}

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

