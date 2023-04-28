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

struct ChooseAlcoholDoseScreen: View {
    let dismiss: () -> Void
    let alcohol = SubstanceRepo.shared.getSubstance(name: "Alcohol")!
    var oralDose: RoaDose {
        alcohol.getDose(for: .oral)!
    }
    @State private var drinkAmountInDL = 5.0
    @State private var drinkAmountInDLText = "5"
    @State private var alcoholContentInPercent = 5.0
    @State private var alcoholContentInPercentText = "5"
    @State private var isEstimate = true
    let units = "g"

    private var ingestedAlcoholDoseInMl: Double {
        drinkAmountInDL * alcoholContentInPercent
    }

    private var ingestedAlcoholDoseInGrams: Double {
        ingestedAlcoholDoseInMl * 0.8
    }

    private var doseRounded: Double {
        round(ingestedAlcoholDoseInGrams)
    }

    private var doseText: String {
        String(Int(doseRounded))
    }

    private var suggestedNote: String {
        "\(Int(drinkAmountInDL)) dL with \(Int(alcoholContentInPercent))% Alcohol"
    }

    var body: some View {
        if #available(iOS 16, *) {
            screen.toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HideKeyboardButton()
                    nextLink
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button("Cancel") {
                        dismiss()
                    }
                    nextLink
                }
            }
        } else {
            screen.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    nextLink
                }
            }
        }
    }

    private var nextLink: some View {
        NavigationLink {
            FinishIngestionScreen(
                substanceName: alcohol.name,
                administrationRoute: .oral,
                dose: doseRounded,
                units: units,
                isEstimate: isEstimate,
                dismiss: dismiss,
                suggestedNote: suggestedNote
            )
        } label: {
            NextLabel()
        }
    }

    private var unknownDoseLink: some View {
        NavigationLink("Unknown Dose") {
            FinishIngestionScreen(
                substanceName: alcohol.name,
                administrationRoute: .oral,
                dose: nil,
                units: units,
                isEstimate: false,
                dismiss: dismiss
            )
        }
    }

    private var screen: some View {
        Form {
            Section("Ingested Alcohol Amount") {
                VStack(spacing: 5) {
                    let doseType = oralDose.getRangeType(for: ingestedAlcoholDoseInGrams, with: units)
                    Text("\(doseText) \(units)")
                        .font(.title.bold())
                        .foregroundColor(doseType.color)
                    DoseRow(roaDose: oralDose)
                }
                Toggle("Is Estimate", isOn: $isEstimate).tint(.accentColor)
                unknownDoseLink
            }
            Section {
                VStack {
                    HStack {
                        TextField("Drink Size", text: $drinkAmountInDLText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: drinkAmountInDLText) { newValue in
                                if let convertedValue = getDouble(from: newValue) {
                                    drinkAmountInDL = convertedValue
                                }
                            }
                        Text("dL")
                    }.font(.title2.bold())
                    Slider(
                        value: $drinkAmountInDL,
                        in: 1...20,
                        step: 1
                    ) {
                        Text("Drink Size")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("20")
                    }
                    .onChange(of: drinkAmountInDL) { newValue in
                        drinkAmountInDLText = newValue.formatted()
                    }
                }
            } header: {
                Text("Drink Size")
            } footer: {
                Text("1 dL = 1/10 L = 100 mL")
            }
            Section("Alcohol Content") {
                VStack {
                    HStack {
                        TextField("Drink Size", text: $alcoholContentInPercentText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: alcoholContentInPercentText) { newValue in
                                if let convertedValue = getDouble(from: newValue) {
                                    alcoholContentInPercent = convertedValue
                                }
                            }
                        Text("%")
                    }.font(.title2.bold())
                    Slider(
                        value: $alcoholContentInPercent,
                        in: 1...80,
                        step: 1
                    ) {
                        Text("Alcohol Content")
                    } minimumValueLabel: {
                        Text("1")
                    } maximumValueLabel: {
                        Text("80")
                    }
                    .onChange(of: alcoholContentInPercent) { newValue in
                        alcoholContentInPercentText = newValue.formatted()
                    }
                }
                Button("Average Beer") {
                    alcoholContentInPercent = 5                }
                Button("Average Wine") {
                    alcoholContentInPercent = 12
                }
                Button("Average Spirit") {
                    alcoholContentInPercent = 40
                }
            }
            if let remark = alcohol.dosageRemark {
                Text(remark)
            }
        }
        .navigationTitle("Alcohol Dosage")
        .optionalScrollDismissesKeyboard()
    }
}

struct ChooseAlcoholDoseScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChooseAlcoholDoseScreen(dismiss: {})
        }
    }
}
