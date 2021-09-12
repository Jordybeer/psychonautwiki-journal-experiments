import SwiftUI

struct IngestionRow: View {

    let ingestion: Ingestion
    let minValue = 0.0
    let maxValue = 1.0
    var currentValue: Double {
        guard currentTime >= startTime else {return 0}
        guard currentTime <= endTime else {return 1}
        let total = startTime.distance(to: endTime)
        let distanceFromStart = startTime.distance(to: currentTime)
        return distanceFromStart / total
    }
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    let startTime: Date
    let endTime: Date
    @State private var currentTime: Date

    let gradientStops: Gradient

    init(ingestion: Ingestion) {
        self.ingestion = ingestion
        self.startTime = ingestion.timeUnwrapped
        let durations = ingestion.substanceCopy!.getDuration(for: ingestion.administrationRouteUnwrapped)!

        let onsetDuration = durations.onset!.oneValue(at: 0.5)
        let comeupDuration = durations.comeup!.oneValue(at: 0.5)
        let peakDuration = durations.peak!.oneValue(at: ingestion.horizontalWeight)
        let offsetDuration = durations.offset!.oneValue(at: ingestion.horizontalWeight)

        let totalTime = onsetDuration + comeupDuration + peakDuration + offsetDuration

        self.endTime = ingestion.timeUnwrapped.addingTimeInterval(totalTime)

        let onsetStartLocation = CGFloat(onsetDuration / totalTime)
        let peakStartLocation = CGFloat((onsetDuration + comeupDuration) / totalTime)
        let peakEndLocation = CGFloat((onsetDuration + comeupDuration + peakDuration) / totalTime)

        self.gradientStops = Gradient(
            stops: [
                .init(color: .white.opacity(0.2), location: onsetStartLocation),
                .init(color: ingestion.swiftUIColorUnwrapped, location: peakStartLocation),
                .init(color: ingestion.swiftUIColorUnwrapped, location: peakEndLocation),
                .init(color: .white.opacity(0.2), location: 1)
        ])

        self._currentTime = State(wrappedValue: Date())
    }

    var body: some View {
        Group {
            if let substanceCopyUnwrapped = ingestion.substanceCopy {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.headline)
                            .foregroundColor(ingestion.swiftUIColorUnwrapped)
                        VStack(alignment: .leading) {
                            Text(substanceCopyUnwrapped.nameUnwrapped).font(.headline)
                            Text("\(ingestion.doseInfoString) \(ingestion.administrationRouteUnwrapped.rawValue)")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    }
                    Gauge(value: currentValue, in: minValue...maxValue) {
                        Text(substanceCopyUnwrapped.nameUnwrapped)
                    } currentValueLabel: {
                        Text(currentTime.asTimeString)
                    } minimumValueLabel: {
                        Text(startTime.asTimeString)
                    } maximumValueLabel: {
                        Text(endTime.asTimeString)
                    }
                    .gaugeStyle(LinearGaugeStyle(tint: gradientStops))
                    .onReceive(timer) { _ in
                        withAnimation {
                            currentTime = Date()
                        }
                    }
                }
            }
        }
    }
}

struct IngestionRow_Previews: PreviewProvider {
    static var previews: some View {
        let helper = PersistenceController.preview.createPreviewHelper()
        List {
            IngestionRow(ingestion: helper.experiences.first!.sortedIngestionsUnwrapped.first!)
        }
    }
}
