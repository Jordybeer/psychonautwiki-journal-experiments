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

import CoreData

extension Ingestion: Comparable {
    public static func < (lhs: Ingestion, rhs: Ingestion) -> Bool {
        lhs.timeUnwrapped < rhs.timeUnwrapped
    }

    var timeUnwrapped: Date {
        time ?? Date()
    }

    var noteUnwrapped: String {
        note ?? ""
    }

    var substanceNameUnwrapped: String {
        substanceName ?? "Unknown"
    }

    var administrationRouteUnwrapped: AdministrationRoute {
        AdministrationRoute(rawValue: administrationRoute ?? "oral") ?? .oral
    }

    var stomachFullnessUnwrapped: StomachFullness? {
        StomachFullness(rawValue: stomachFullness ?? "")
    }

    var doseUnwrapped: Double? {
        if dose == 0 {
            return nil
        } else {
            return dose
        }
    }

    var pureSubstanceDose: Double? {
        doseUnwrapped ?? calculatedDose
    }

    var calculatedDose: Double? {
        guard let customDose = customUnitDoseUnwrapped, let dosePerUnit = customUnit?.doseUnwrapped else { return nil }
        return customDose * dosePerUnit
    }

    var customUnitDoseUnwrapped: Double? {
        if customUnitDose == 0 {
            return nil
        } else {
            return customUnitDose
        }
    }

    var substance: Substance? {
        SubstanceRepo.shared.getSubstance(name: substanceNameUnwrapped)
    }

    var numberOfDots: Int? {
        substance?.getDose(for: administrationRouteUnwrapped)?.getNumDots(
            ingestionDose: pureSubstanceDose,
            ingestionUnits: unitsUnwrapped
        )
    }

    var unitsUnwrapped: String {
        if let units {
            return units
        } else {
            return ""
        }
    }

    var substanceColor: SubstanceColor {
        substanceCompanion?.color ?? .red
    }

    static var knownDosePreviewSample: Ingestion {
        let ingestion = Ingestion(context: PersistenceController.preview.viewContext)
        ingestion.substanceName = "MDMA"
        ingestion.dose = 50
        ingestion.units = "mg"
        ingestion.isEstimate = false
        ingestion.administrationRoute = AdministrationRoute.oral.rawValue
        ingestion.time = .now
        ingestion.note = ""
        ingestion.stomachFullness = StomachFullness.full.rawValue
        return ingestion
    }

    static var estimatedDosePreviewSample: Ingestion {
        let ingestion = Ingestion(context: PersistenceController.preview.viewContext)
        ingestion.substanceName = "Cocaine"
        ingestion.dose = 30
        ingestion.units = "mg"
        ingestion.isEstimate = true
        ingestion.administrationRoute = AdministrationRoute.insufflated.rawValue
        ingestion.time = .now
        ingestion.note = ""
        ingestion.stomachFullness = nil
        return ingestion
    }

    static var unknownDosePreviewSample: Ingestion {
        let ingestion = Ingestion(context: PersistenceController.preview.viewContext)
        ingestion.substanceName = "Cocaine"
        ingestion.dose = 0
        ingestion.units = "mg"
        ingestion.isEstimate = true
        ingestion.administrationRoute = AdministrationRoute.insufflated.rawValue
        ingestion.time = .now
        ingestion.note = ""
        ingestion.stomachFullness = nil
        return ingestion
    }

    static var notePreviewSample: Ingestion {
        let ingestion = Ingestion(context: PersistenceController.preview.viewContext)
        ingestion.substanceName = "Cocaine"
        ingestion.dose = 30
        ingestion.units = "mg"
        ingestion.isEstimate = true
        ingestion.administrationRoute = AdministrationRoute.insufflated.rawValue
        ingestion.time = .now
        ingestion.note = "This is a longer note that might not fit on one line and it needs to be able to handle this"
        ingestion.stomachFullness = nil
        return ingestion
    }

    static var customSubstancePreviewSample: Ingestion {
        let ingestion = Ingestion(context: PersistenceController.preview.viewContext)
        ingestion.substanceName = "Customsubstance"
        ingestion.dose = 50
        ingestion.units = "mg"
        ingestion.isEstimate = false
        ingestion.administrationRoute = AdministrationRoute.oral.rawValue
        ingestion.time = .now
        ingestion.note = ""
        ingestion.stomachFullness = StomachFullness.full.rawValue
        return ingestion
    }

    static var customUnitPreviewSample: Ingestion {
        let ingestion = Ingestion(context: PersistenceController.preview.viewContext)
        ingestion.substanceName = "Ketamine"
        ingestion.dose = 0
        ingestion.customUnitDose = 2
        ingestion.customUnit = CustomUnit.previewSample
        ingestion.units = "mg"
        ingestion.isEstimate = false
        ingestion.administrationRoute = AdministrationRoute.insufflated.rawValue
        ingestion.time = .now
        ingestion.note = ""
        ingestion.stomachFullness = nil
        return ingestion
    }
}
