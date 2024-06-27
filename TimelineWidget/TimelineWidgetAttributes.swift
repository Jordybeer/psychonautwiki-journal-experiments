// Copyright (c) 2022. Isaak Hanimann.
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

import ActivityKit

struct TimelineWidgetAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        static func == (lhs: TimelineWidgetAttributes.ContentState, rhs: TimelineWidgetAttributes.ContentState) -> Bool {
            lhs.substanceGroups == rhs.substanceGroups
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(substanceGroups.description)
        }

        // Dynamic stateful properties about your activity go here!
        var substanceGroups: [SubstanceIngestionGroup]
        var everythingForEachRating: [EverythingForOneRating]
        var everythingForEachTimedNote: [EverythingForOneTimedNote]
        var areRedosesDrawnIndividually: Bool
        var areSubstanceHeightsIndependent: Bool
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}
