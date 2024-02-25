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

import Foundation

class SuggestionsCreator {
    init(sortedIngestions: [Ingestion], customUnits: [CustomUnit]) {
        let bySubstance = Dictionary(grouping: sortedIngestions, by: { ingestion in
            ingestion.substanceNameUnwrapped
        })
        suggestions = bySubstance.flatMap { (substanceName: String, value: [Ingestion]) in
            Dictionary(grouping: value, by: { ingestion in
                ingestion.administrationRouteUnwrapped
            }).map { (route: AdministrationRoute, groupedBySubstanceAndRoute: [Ingestion]) in
                let firstIngestion = groupedBySubstanceAndRoute.first
                let filteredCustomUnits = customUnits.filter { customUnit in
                    customUnit.substanceNameUnwrapped == substanceName && customUnit.administrationRouteUnwrapped == route
                }
                let dosesAndUnits: [RegularDoseAndUnit] = Array(
                    groupedBySubstanceAndRoute
                        .filter { ing in
                            ing.customUnit == nil
                        }
                        .map { ing in
                            RegularDoseAndUnit(
                                dose: ing.doseUnwrapped,
                                units: ing.unitsUnwrapped,
                                isEstimate: ing.isEstimate,
                                estimatedDoseVariance: ing.estimatedDoseVarianceUnwrapped
                            )
                        }
                        .uniqued()
                        .prefix(maxNumberOfSuggestions))
                let customUnits: [CustomUnitDose] = Array(
                    groupedBySubstanceAndRoute
                        .compactMap { ing in
                            if let customUnit = ing.customUnit, let dose = ing.doseUnwrapped {
                                CustomUnitDose(
                                    dose: dose,
                                    isEstimate: ing.isEstimate,
                                    estimatedDoseVariance: ing.estimatedDoseVarianceUnwrapped,
                                    customUnit: customUnit)
                            } else {
                                nil
                            }
                        }
                        .uniqued()
                        .prefix(maxNumberOfSuggestions))
                return Suggestion(
                    substanceName: substanceName,
                    substance: SubstanceRepo.shared.getSubstance(name: substanceName),
                    route: firstIngestion?.administrationRouteUnwrapped ?? .oral,
                    substanceColor: firstIngestion?.substanceColor ?? .red,
                    dosesAndUnit: dosesAndUnits,
                    customUnitDoses: customUnits,
                    customUnits: filteredCustomUnits,
                    lastTimeUsed: groupedBySubstanceAndRoute.map { $0.timeUnwrapped }.max() ?? .now)
            }
        }.sorted { sug1, sug2 in
            sug1.lastTimeUsed > sug2.lastTimeUsed
        }
    }

    var suggestions: [Suggestion] = []

    private let maxNumberOfSuggestions = 5

}
