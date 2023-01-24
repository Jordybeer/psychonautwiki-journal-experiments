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
import CoreData

extension FinishIngestionScreen {

    @MainActor
    class ViewModel: ObservableObject {

        @Published var selectedColor = SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
        @Published var selectedTime = Date()
        @Published var enteredNote = ""
        @Published var enteredTitle = ""
        @Published var alreadyUsedColors = Set<SubstanceColor>()
        @Published var otherColors = Set<SubstanceColor>()
        @Published var notesInOrder = [String]()
        private var foundCompanion: SubstanceCompanion? = nil
        @Published var isInitialized = false
        @Published var experiencesWithinLargerRange: [Experience] = []
        @Published var selectedExperience: Experience?

        func initializeColorCompanionAndNote(for substanceName: String, suggestedNote: String?) {
            if let suggestedNote {
                enteredNote = suggestedNote
            }
            let fetchRequest = SubstanceCompanion.fetchRequest()
            let companions = (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            alreadyUsedColors = Set(companions.map { $0.color })
            otherColors = Set(SubstanceColor.allCases).subtracting(alreadyUsedColors)
            let companionMatch = companions.first { comp in
                comp.substanceNameUnwrapped == substanceName
            }
            if let companionMatchUnwrap = companionMatch {
                foundCompanion = companionMatchUnwrap
                self.selectedColor = companionMatchUnwrap.color
            } else {
                self.selectedColor = otherColors.first ?? SubstanceColor.allCases.randomElement() ?? SubstanceColor.blue
            }
            isInitialized = true
        }

        func addIngestion(
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool,
            location: Location?
        ) async throws {
            let context = PersistenceController.shared.viewContext
            try await context.perform {
                let companion = self.createOrUpdateCompanion(with: context, substanceName: substanceName)
                if let existingExperience = self.selectedExperience {
                    self.createIngestion(
                        with: existingExperience,
                        and: context,
                        substanceName: substanceName,
                        administrationRoute: administrationRoute,
                        dose: dose,
                        units: units,
                        isEstimate: isEstimate,
                        substanceCompanion: companion
                    )
                    if #available(iOS 16.2, *) {
                        if existingExperience.isCurrent {
                            ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: existingExperience.sortedIngestionsUnwrapped))
                        }
                    }
                } else {
                    let newExperience = Experience(context: context)
                    newExperience.creationDate = Date()
                    newExperience.sortDate = self.selectedTime
                    var title = self.selectedTime.asDateString
                    if !self.enteredTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                        title = self.enteredTitle
                    }
                    newExperience.title = title
                    newExperience.text = ""
                    if let location {
                        let newLocation = ExperienceLocation(context: context)
                        newLocation.name = location.name
                        newLocation.latitude = location.latitude ?? 0
                        newLocation.longitude = location.longitude ?? 0
                        newLocation.experience = newExperience
                    }
                    self.createIngestion(
                        with: newExperience,
                        and: context,
                        substanceName: substanceName,
                        administrationRoute: administrationRoute,
                        dose: dose,
                        units: units,
                        isEstimate: isEstimate,
                        substanceCompanion: companion
                    )
                    if #available(iOS 16.2, *) {
                        if newExperience.isCurrent {
                            ActivityManager.shared.startOrUpdateActivity(everythingForEachLine: getEverythingForEachLine(from: newExperience.sortedIngestionsUnwrapped))
                        }
                    }
                }
                try context.save()
            }
        }


        private func createOrUpdateCompanion(with context: NSManagedObjectContext, substanceName: String) -> SubstanceCompanion {
            if let foundCompanion {
                foundCompanion.colorAsText = selectedColor.rawValue
                return foundCompanion
            } else {
                let companion = SubstanceCompanion(context: context)
                companion.substanceName = substanceName
                companion.colorAsText = selectedColor.rawValue
                return companion
            }
        }

        private func createIngestion(
            with experience: Experience,
            and context: NSManagedObjectContext,
            substanceName: String,
            administrationRoute: AdministrationRoute,
            dose: Double?,
            units: String?,
            isEstimate: Bool,
            substanceCompanion: SubstanceCompanion
        ) {
            let ingestion = Ingestion(context: context)
            ingestion.identifier = UUID()
            ingestion.time = selectedTime
            ingestion.creationDate = Date()
            ingestion.dose = dose ?? 0
            ingestion.units = units
            ingestion.isEstimate = isEstimate
            ingestion.note = enteredNote
            ingestion.administrationRoute = administrationRoute.rawValue
            ingestion.substanceName = substanceName
            ingestion.color = selectedColor.rawValue
            ingestion.experience = experience
            ingestion.substanceCompanion = substanceCompanion
        }

        init() {
            let ingestionFetchRequest = Ingestion.fetchRequest()
            ingestionFetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Ingestion.time, ascending: false) ]
            ingestionFetchRequest.predicate = NSPredicate(format: "note.length > 0")
            ingestionFetchRequest.fetchLimit = 15
            let sortedIngestions = (try? PersistenceController.shared.viewContext.fetch(ingestionFetchRequest)) ?? []
            notesInOrder = sortedIngestions.map { ing in
                ing.noteUnwrapped
            }.uniqued()
            $selectedTime.map({ date in
                let fetchRequest = Experience.fetchRequest()
                fetchRequest.sortDescriptors = [ NSSortDescriptor(keyPath: \Experience.sortDate, ascending: false) ]
                fetchRequest.predicate = FinishIngestionScreen.ViewModel.getPredicate(from: date)
                return (try? PersistenceController.shared.viewContext.fetch(fetchRequest)) ?? []
            }).assign(to: &$experiencesWithinLargerRange)
            $selectedTime.combineLatest($experiencesWithinLargerRange) { date, experiences in
                FinishIngestionScreen.ViewModel.getExperienceClosest(from: experiences, date: date)
            }.assign(to: &$selectedExperience)
        }

        private static func getExperienceClosest(from experiences: [Experience], date: Date) -> Experience? {
            let halfDay: TimeInterval = 12*60*60
            let startDate = date.addingTimeInterval(-halfDay)
            let endDate = date.addingTimeInterval(halfDay)
            return experiences.first { exp in
                startDate < exp.sortDateUnwrapped && exp.sortDateUnwrapped < endDate
            }
        }

        private static func getPredicate(from date: Date) -> NSCompoundPredicate {
            let twoDays: TimeInterval = 48*60*60
            let startDate = date.addingTimeInterval(-twoDays)
            let endDate = date.addingTimeInterval(twoDays)
            let laterThanStart = NSPredicate(format: "sortDate > %@", startDate as NSDate)
            let earlierThanEnd = NSPredicate(format: "sortDate < %@", endDate as NSDate)
            return NSCompoundPredicate(
                andPredicateWithSubpredicates: [laterThanStart, earlierThanEnd]
            )
        }
    }
}
