import SwiftUI

struct ChooseSubstanceList: View {

    @ObservedObject var sectionedViewModel: SectionedSubstancesViewModel
    let experience: Experience
    let dismiss: (AddResult) -> Void
    @StateObject var recentsViewModel = RecentSubstancesViewModel()
    @StateObject var presetsViewModel = PresetsViewModel()
    @StateObject var customsViewModel = CustomSubstancesViewModel()
    @AppStorage(PersistenceController.isEyeOpenKey) var isEyeOpen: Bool = false
    @Environment(\.isSearching) var isSearching

    var body: some View {
        ZStack {
            List {
                if !isSearching {
                    if !recentsViewModel.recentSubstances.isEmpty {
                        Section("Recently Used") {
                            ForEach(recentsViewModel.recentSubstances) { sub in
                                NavigationLink(sub.nameUnwrapped) {
                                    if sub.hasAnyInteractions {
                                        AcknowledgeInteractionsView(
                                            substance: sub,
                                            dismiss: dismiss,
                                            experience: experience
                                        )
                                    } else {
                                        ChooseRouteView(
                                            substance: sub,
                                            dismiss: dismiss,
                                            experience: experience
                                        )
                                    }
                                }
                            }
                        }
                    }
                    if !presetsViewModel.presets.isEmpty {
                        Section(header: Text("Presets")) {
                            ForEach(presetsViewModel.presets) { pre in
                                let showInteractionSheet = pre.substances.contains(where: { sub in
                                    sub.hasAnyInteractions
                                }) || !pre.dangerousInteractions.isEmpty
                                || !pre.unsafeInteractions.isEmpty
                                || !pre.uncertainInteractions.isEmpty
                                if showInteractionSheet {
                                    NavigationLink(pre.nameUnwrapped) {
                                        PresetAcknowledgeInteractionsView(
                                            preset: pre,
                                            dismiss: dismiss,
                                            experience: experience
                                        )
                                    }
                                } else {
                                    NavigationLink(pre.nameUnwrapped) {
                                        PresetChooseDoseView(
                                            preset: pre,
                                            dismiss: dismiss,
                                            experience: experience
                                        )
                                    }
                                }

                            }
                        }
                    }
                    if !customsViewModel.customSubstances.isEmpty {
                        Section(header: Text("Custom Substances")) {
                            ForEach(customsViewModel.customSubstances) { cust in
                                NavigationLink(cust.nameUnwrapped) {
                                    AddCustomIngestionView(
                                        customSubstance: cust,
                                        dismiss: dismiss,
                                        experience: experience
                                    )
                                }
                            }
                        }
                    }
                }
                ForEach(sectionedViewModel.sections) { sec in
                    Section(sec.sectionName) {
                        ForEach(sec.substances) { sub in
                            NavigationLink(sub.nameUnwrapped) {
                                if sub.hasAnyInteractions {
                                    AcknowledgeInteractionsView(
                                        substance: sub,
                                        dismiss: dismiss,
                                        experience: experience
                                    )
                                } else {
                                    ChooseRouteView(
                                        substance: sub,
                                        dismiss: dismiss,
                                        experience: experience
                                    )
                                }
                            }
                        }
                    }
                }
                if isEyeOpen {
                    Section {
                        EmptyView()
                    } footer: {
                        Text(substancesDisclaimer)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            if isSearching && sectionedViewModel.sections.isEmpty {
                Text("No Results")
                    .foregroundColor(.secondary)
            }
        }
    }

    let substancesDisclaimer =
"""
This list is neither a suggestion nor an incitement to the consumption of these substances.
Using these substances always involves risks and can never be considered safe.

Consult a doctor before making medical decisions.
"""
}

struct ChooseSubstanceList_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSubstanceList(
            sectionedViewModel: SectionedSubstancesViewModel(isPreview: true),
            experience: PreviewHelper.shared.experiences.first!,
            dismiss: {_ in }
        )
    }
}
