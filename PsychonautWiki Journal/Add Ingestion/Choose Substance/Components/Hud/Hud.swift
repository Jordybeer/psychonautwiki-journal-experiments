// Copyright (c) 2023. Isaak Hanimann.
// This file is part of PsychonautWiki Journal.
//
// PsychonautWiki Journal is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public Licence as published by
// the Free Software Foundation, either version 3 of the License, or (at 
// your option) any later version.
//
// PsychonautWiki Journal is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with PsychonautWiki Journal. If not, see https://www.gnu.org/licenses/gpl-3.0.en.html.

import SwiftUI

struct Hud<Content: View>: View {
    @ViewBuilder let content: Content
    let dismiss: () -> Void
    @State private var swipeStart: CGFloat = 0
    @State private var swipeEnd: CGFloat = 0

    var body: some View {
        content
            .padding(.horizontal, 12)
            .padding(10)
            .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
            .padding(.horizontal, 20)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.swipeStart = gesture.startLocation.y
                        self.swipeEnd = gesture.location.y
                    }
                    .onEnded { _ in
                        if self.swipeStart > self.swipeEnd {
                            dismiss()
                        }
                    }
            )
    }
}
