import SwiftUI

struct ExperienceScreen: View {

    @ObservedObject var experience: Experience
    @State private var isShowingAddIngestionSheet = false

    var body: some View {
        return List {
            if !experience.sortedIngestionsUnwrapped.isEmpty {
                Section {
                    EffectTimeline(timelineModel: timelineModel)
                } header: {
                    Text("Effect Timeline")
                } footer: {
                    let firstDate = experience.sortedIngestionsUnwrapped.first?.time ?? experience.sortDateUnwrapped
                    Text(firstDate, style: .date)
                }
                Section("Ingestions") {
                    ForEach(experience.sortedIngestionsUnwrapped) { ing in
                        let route = ing.administrationRouteUnwrapped
                        let roaDose = ing.substance?.getDose(for: route)
                        NavigationLink {
                            EditIngestionScreen(
                                ingestion: ing,
                                substanceName: ing.substanceNameUnwrapped,
                                roaDose: roaDose,
                                route: route
                            )
                        } label: {
                            IngestionRow(ingestion: ing)
                        }
                    }
                    Button {
                        isShowingAddIngestionSheet.toggle()
                    } label: {
                        Label("Add Ingestion", systemImage: "plus")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            Section("Notes") {
                if let notes = experience.textUnwrapped, !notes.isEmpty {
                    Text(notes)
                        .padding(.vertical, 5)
                } else {
                    NavigationLink {
                        EditExperienceScreen(experience: experience)
                    } label: {
                        Label("Add Note", systemImage: "pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingAddIngestionSheet, content: {
            ChooseSubstanceScreen()
        })
        .navigationTitle(experience.titleUnwrapped)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("Edit") {
                    EditExperienceScreen(experience: experience)
                }
            }
        }
    }

    var timelineModel: TimelineModel {
        TimelineModel(everythingForEachLine: experience.sortedIngestionsUnwrapped.map { ingestion in
            let substance = SubstanceRepo.shared.getSubstance(name: ingestion.substanceNameUnwrapped)
            let roaDuration = substance?.getDuration(for: ingestion.administrationRouteUnwrapped)
            return EverythingForOneLine(
                roaDuration: roaDuration,
                startTime: ingestion.timeUnwrapped,
                horizontalWeight: 0.5,
                verticalWeight: 1,
                color: ingestion.substanceColor.swiftUIColor
            )
        })
    }
}
