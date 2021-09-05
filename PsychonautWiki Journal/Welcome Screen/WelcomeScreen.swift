import SwiftUI

struct WelcomeScreen: View {

    @Environment(\.managedObjectContext) var moc

    @FetchRequest(
        entity: SubstancesFile.entity(),
        sortDescriptors: []
    ) var storedFile: FetchedResults<SubstancesFile>

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    Image(decorative: "AppIconCopy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 130, height: 130, alignment: .center)
                        .cornerRadius(10)
                        .accessibilityHidden(true)
                    VStack(spacing: 20) {
                        (Text("Welcome to ") + Text("PsychonautWiki Journal").foregroundColor(.accentColor))
                            .multilineTextAlignment(.center)
                            .font(.largeTitle.bold())

                        ForEach(features) { feature in
                            HStack {
                                Image(systemName: feature.image)
                                    .frame(width: 44)
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                                    .accessibilityHidden(true)

                                VStack(alignment: .leading) {
                                    Text(feature.title)
                                        .font(.headline)

                                    Text(feature.description)
                                        .foregroundColor(.secondary)
                                }
                                .accessibilityElement(children: .combine)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }

                Text("More info in Settings")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                NavigationLink(
                    destination: CalendarScreen(),
                    label: {
                        Text("Continue")
                            .primaryButtonText()
                    }
                )
            }
            .padding()
            .navigationBarHidden(true)
        }
        .onAppear {
            if storedFile.first == nil {
                addInitialSubstances()
            }
        }
    }

    private func addInitialSubstances() {
        let fileName = "InitialSubstances"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            fatalError("Failed to locate \(fileName) in bundle.")
        }

        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(fileName) from bundle.")
        }

        do {
            let dateString = "2021/08/25 00:30"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            let creationDate = formatter.date(from: dateString)!

            try SubstanceDecoder.decodeAndSaveFile(
                from: data,
                creationDate: creationDate,
                earlierFileToDelete: nil
            )
        } catch {
            fatalError("Failed to decode \(fileName) from bundle: \(error.localizedDescription)")
        }
    }

    let features = [
        Feature(
            title: "Keep Track",
            description: "Have an overview of your substance experiences. During and after the experience.",
            image: "binoculars"
        ),
        Feature(
            title: "Be Safe",
            description: "Get notified of dangerous interactions. Add ingestions before you actually take them.",
            image: "checkmark.shield"
        ),
        Feature(
            title: "Privacy",
            description: "Your data belongs to you and will never be shared.",
            image: "lock.shield"
        )
    ]
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen()
            .preferredColorScheme(.dark)
            .accentColor(Color.blue)
    }
}
