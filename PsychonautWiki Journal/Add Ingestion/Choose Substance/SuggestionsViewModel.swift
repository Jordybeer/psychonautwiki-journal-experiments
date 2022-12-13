//
//  SuggestionsViewModel.swift
//  PsychonautWiki Journal
//
//  Created by Isaak Hanimann on 13.12.22.
//

import Foundation

class SuggestionsViewModel: ObservableObject {

    let suggestions: [Suggestion]

    init() {
        let ingestionFetchRequest = Ingestion.fetchRequest()
        ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
        ingestionFetchRequest.fetchLimit = 100
        let ingestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
        let groupedBySubstance = Dictionary(grouping: ingestions, by: { $0.substanceNameUnwrapped })
        suggestions = groupedBySubstance.map { (substanceName: String, ingestionsWithSameSubstance: [Ingestion]) in
            let groupedByRoute = Dictionary(grouping: ingestionsWithSameSubstance, by: { $0.administrationRouteUnwrapped })
            let isCustom = SubstanceRepo.shared.getSubstance(name: substanceName) == nil
            let substanceColor = ingestionsWithSameSubstance.first?.substanceColor ?? .red
            let routesAndDoses = groupedByRoute.map { (route: AdministrationRoute, ingestions: [Ingestion]) in
                RouteAndDoses(
                    route: route,
                    doses: ingestions.map { ing in
                        DoseAndUnit(dose: ing.doseUnwrapped, units: ing.unitsUnwrapped)
                    }.uniqued()
                )
            }
            return Suggestion(
                substanceName: substanceName,
                isCustom: isCustom,
                substanceColor: substanceColor,
                routesAndDoses: routesAndDoses
            )

        }
    }
}

struct Suggestion: Identifiable {
    var id: String {
        substanceName
    }
    let substanceName: String
    let isCustom: Bool
    let substanceColor: SubstanceColor
    let routesAndDoses: [RouteAndDoses]
}

struct RouteAndDoses: Identifiable {
    var id: AdministrationRoute {
        route
    }
    let route: AdministrationRoute
    let doses: [DoseAndUnit]
}

struct DoseAndUnit: Hashable, Identifiable {
    var id: String {
        (dose?.description ?? "") + (units ?? "")
    }
    let dose: Double?
    let units: String?
}

