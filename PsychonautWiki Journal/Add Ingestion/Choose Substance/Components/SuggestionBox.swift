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
import WrappingHStack

struct SuggestionBox: View {
    let suggestion: Suggestion
    let dismiss: () -> Void
    let isEyeOpen: Bool

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                WrappingHStack(
                    alignment: .leading,
                    horizontalSpacing: horizontalSpacing,
                    verticalSpacing: verticalSpacing)
                {
                    ForEach(suggestion.dosesAndUnit) { dose in
                        if let doseUnwrap = dose.dose {
                            NavigationLink(
                                "\(dose.isEstimate ? "~" : "")\(doseUnwrap.formatted()) \(dose.units ?? "")",
                                value: FinishIngestionScreenArguments(
                                    substanceName: suggestion.substanceName,
                                    administrationRoute: suggestion.route,
                                    dose: doseUnwrap,
                                    units: dose.units,
                                    isEstimate: dose.isEstimate))
                                .buttonStyle(.bordered).fixedSize()
                        } else {
                            NavigationLink("Unknown", value: FinishIngestionScreenArguments(
                                substanceName: suggestion.substanceName,
                                administrationRoute: suggestion.route,
                                dose: dose.dose,
                                units: dose.units,
                                isEstimate: dose.isEstimate))
                                .buttonStyle(.bordered).fixedSize()
                        }
                    }
                    if let substance = suggestion.substance {
                        NavigationLink(
                            "Other",
                            value: SubstanceAndRoute(substance: substance, administrationRoute: suggestion.route))
                            .buttonStyle(.borderedProminent).fixedSize()
                    } else {
                        NavigationLink("Other", value: CustomChooseDoseScreenArguments(
                            substanceName: suggestion.substanceName,
                            units: suggestion.units,
                            administrationRoute: suggestion.route))
                            .buttonStyle(.borderedProminent).fixedSize()
                    }
                }
                if !suggestion.customUnitDoses.isEmpty {
                    WrappingHStack(
                        alignment: .leading,
                        horizontalSpacing: horizontalSpacing,
                        verticalSpacing: verticalSpacing)
                    {
                        ForEach(suggestion.customUnitDoses) { customUnitDose in
                            NavigationLink(
                                value: FinishIngestionScreenArguments(
                                    substanceName: suggestion.substanceName,
                                    administrationRoute: suggestion.route,
                                    dose: customUnitDose.dose,
                                    units: customUnitDose.customUnit.originalUnitUnwrapped,
                                    isEstimate: customUnitDose.isEstimate,
                                    customUnit: customUnitDose.customUnit))
                            {
                                CustomUnitDoseLabel(customUnitDose: customUnitDose)
                            }.buttonStyle(.bordered).fixedSize()
                        }
                    }
                }
                if !suggestion.customUnits.isEmpty {
                    WrappingHStack(
                        alignment: .leading,
                        horizontalSpacing: horizontalSpacing,
                        verticalSpacing: verticalSpacing)
                    {
                        ForEach(suggestion.customUnits) { customUnit in
                            NavigationLink("Enter \(customUnit.unitUnwrapped)", value: customUnit)
                                .buttonStyle(.borderedProminent).fixedSize()
                        }
                    }
                }
                Group {
                    Text("Last ingestion ") + Text(suggestion.lastTimeUsed, style: .relative) + Text(" ago")
                }.font(.footnote).foregroundColor(.secondary)
            }
        } label: {
            let route = isEyeOpen ? suggestion.route.rawValue.localizedCapitalized : ""
            Label(
                "\(suggestion.substanceName) \(route)",
                systemImage: "circle.fill")
                .foregroundColor(suggestion.substanceColor.swiftUIColor)
        }
    }

    private let horizontalSpacing: Double = 4
    private let verticalSpacing: Double = 5

}

#Preview {
    NavigationStack {
        LazyVStack {
            SuggestionBox(
                suggestion: Suggestion(
                    substanceName: "MDMA",
                    substance: SubstanceRepo.shared.getSubstance(name: "MDMA"),
                    units: "mg",
                    route: .insufflated,
                    substanceColor: .pink,
                    dosesAndUnit: [
                        RegularDoseAndUnit(
                            dose: 20,
                            units: "mg",
                            isEstimate: true),
                        RegularDoseAndUnit(
                            dose: nil,
                            units: "mg",
                            isEstimate: false),
                        RegularDoseAndUnit(
                            dose: 30,
                            units: "mg",
                            isEstimate: false),
                    ],
                    customUnitDoses: [],
                    customUnits: [],
                    lastTimeUsed: Date.now.addingTimeInterval(-2 * 60 * 60)),
                dismiss: { },
                isEyeOpen: true)
            SuggestionBox(
                suggestion: Suggestion(
                    substanceName: "Cannabis",
                    substance: SubstanceRepo.shared.getSubstance(name: "Cannabis"),
                    units: "mg",
                    route: .smoked,
                    substanceColor: .green,
                    dosesAndUnit: [
                        RegularDoseAndUnit(
                            dose: 3,
                            units: "mg",
                            isEstimate: false),
                        RegularDoseAndUnit(
                            dose: 6,
                            units: "mg",
                            isEstimate: true),
                        RegularDoseAndUnit(
                            dose: nil,
                            units: "mg",
                            isEstimate: false),
                        RegularDoseAndUnit(
                            dose: 2.5,
                            units: "mg",
                            isEstimate: false),
                    ],
                    customUnitDoses: [],
                    customUnits: [],
                    lastTimeUsed: Date.now.addingTimeInterval(-3 * 60 * 60)),
                dismiss: { },
                isEyeOpen: true)
        }.padding(.horizontal)
    }
}
