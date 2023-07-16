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

import SwiftUI

struct DurationScreen: View {
    let substanceName: String
    let durationInfos: [DurationInfo]
    @State private var selectedTime = Date()
    @State private var timelineModel: TimelineModel?
    @State private var stomachFullness = StomachFullness.empty
    @State private var hiddenRoutes: [AdministrationRoute] = []

    var body: some View {
        List {
            Section {
                HStack {
                    DatePicker(
                        "Start Time",
                        selection: $selectedTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    Button("Now") {
                        selectedTime = .now
                    }
                    .buttonStyle(.bordered)
                }
                VStack(alignment: .leading) {
                    if let timelineModel {
                        EffectTimeline(timelineModel: timelineModel)
                    }
                    Text(TimelineDisclaimers.heavyDose).font(.footnote)
                }
                ForEach(durationInfos, id: \.route) { info in
                    let isRouteHidden = hiddenRoutes.contains(info.route)
                    HStack(alignment: .center, spacing: 8) {
                        if isRouteHidden {
                            Label("Hidden", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                        }
                        ColorRectangle(color: info.route.color.swiftUIColor)
                        VStack(alignment: .leading) {
                            Text(info.route.rawValue.localizedCapitalized).font(.headline)
                            OneRoaDurationRow(duration: info.roaDuration, color: info.route.color)
                            if info.route == .oral {
                                Spacer().frame(height: 5)
                                VStack(alignment: .leading) {
                                    Text("Stomach Fullness Delay").font(.footnote.weight(.medium))
                                    Picker("Stomach Fullness", selection: $stomachFullness) {
                                        ForEach(StomachFullness.allCases) { option in
                                            Text(option.text)
                                        }
                                    }.pickerStyle(.segmented)
                                    Text("Onset delayed by ~\(stomachFullness.onsetDelayForOralInHours.asTextWithoutTrailingZeros(maxNumberOfFractionDigits: 1)) hours.").font(.footnote)
                                }
                                .padding(.vertical, 10)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(uiColor: UIColor.systemGray6))
                                )
                            }
                            Text(TimelineDisclaimers.capsule).font(.footnote)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggle(route: info.route)
                        } label: {
                            if isRouteHidden {
                                Label("Show", systemImage: "eye.fill").labelStyle(.iconOnly)
                            } else {
                                Label("Hide", systemImage: "eye.slash.fill").labelStyle(.iconOnly)
                            }
                        }
                    }
                }
            }
        }.onAppear {
            updateModel()
        }
        .onChange(of: selectedTime) { _ in
            updateModel()
        }
        .onChange(of: hiddenRoutes) { _ in
            updateModel()
        }
        .onChange(of: stomachFullness) { _ in
            updateModel()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    List {
                        TimelineExplanationTexts()
                    }.navigationTitle("Timeline Info")
                } label: {
                    Label("Info", systemImage: "info.circle")
                }
            }
        }
        .navigationTitle("\(substanceName) Duration")
        .dismissWhenTabTapped()
    }

    private func updateModel() {
        let durationsToShow = durationInfos.filter { info in
            !hiddenRoutes.contains(info.route)
        }
        timelineModel = TimelineModel(
            everythingForEachLine: durationsToShow.map({ info in
                EverythingForOneLine(
                    roaDuration: info.roaDuration,
                    onsetDelayInHours: info.route == .oral ? stomachFullness.onsetDelayForOralInHours : 0,
                    startTime: selectedTime,
                    horizontalWeight: 0.5,
                    verticalWeight: 1,
                    color: info.route.color
                )
            }),
            everythingForEachRating: []
        )
    }

    private func toggle(route: AdministrationRoute) {
        if hiddenRoutes.contains(route) {
            hiddenRoutes.removeAll { sel in
                sel == route
            }
        } else {
            hiddenRoutes.append(route)
        }
    }
}




struct DurationScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            let substance = SubstanceRepo.shared.getSubstance(name: "4-HO-MET")!
            DurationScreen(substanceName: substance.name, durationInfos: substance.durationInfos).environmentObject(TabBarObserver())
        }
    }
}
