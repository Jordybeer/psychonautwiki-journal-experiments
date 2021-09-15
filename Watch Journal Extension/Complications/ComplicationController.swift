import ClockKit
import SwiftUI

class ComplicationController: NSObject, CLKComplicationDataSource {

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(
                identifier: "complication",
                displayName: "PsychonautWiki Journal",
                supportedFamilies: [.extraLarge, .modularLarge, .graphicExtraLarge]
            )
            // Multiple complication support can be added here with more descriptors
        ]

        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }

    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Do any necessary work to support these newly shared complication descriptors
    }

    // MARK: - Timeline Configuration

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // swiftlint:disable line_length
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        let endDate = Date().addingTimeInterval(86400)
        handler(endDate)
    }

    func getPrivacyBehavior(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationPrivacyBehavior
        ) -> Void) {
        // Call the handler with your desired behavior when the device is locked
        handler(.hideOnLockScreen)
    }

    // MARK: - Timeline Population

    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void
    ) {
        // Call the handler with the current timeline entry
        let ingestions = PersistenceController.shared.getLatestExperience()?.sortedIngestionsUnwrapped ?? []
        let now = Date()
        let predictionTemplate = createTemplate(for: complication.family, date: now, ingestions: ingestions)
        let entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: predictionTemplate)
        handler(entry)
    }

    func getTimelineEntries(
        for complication: CLKComplication,
        after date: Date,
        limit: Int,
        withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void
    ) {
        // Call the handler with the timeline entries after the given date
        var entries = [CLKComplicationTimelineEntry]()
        let ingestions = PersistenceController.shared.getLatestExperience()?.sortedIngestionsUnwrapped ?? []

        for index in 0 ..< limit {
            let predictionDate = date.addingTimeInterval(Double(60 * 5 * index))

            let predictionTemplate = createTemplate(for: complication.family, date: predictionDate, ingestions: ingestions)

            let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)

            entries.append(entry)
        }

        handler(entries)
    }

    // MARK: - Sample Templates

    func getLocalizableSampleTemplate(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTemplate?) -> Void
    ) {
        // This method will be called once per supported complication, and the results will be cached

        let helper = PersistenceController.preview.createPreviewHelper()
        var components = DateComponents()
        components.year = 2021
        components.month = 8
        components.day = 18
        components.hour = 10
        components.minute = 10
        let sampleDate = Calendar.current.date(from: components) ?? Date()

        let template = createTemplate(for: complication.family, date: sampleDate, ingestions: helper.experiences.first!.sortedIngestionsUnwrapped)
        handler(template)
    }

    func createTemplate(
        for family: CLKComplicationFamily,
        date: Date,
        ingestions: [Ingestion]
    ) -> CLKComplicationTemplate {

        switch family {
        case .extraLarge:
            let ingestion = ingestions.first
            let line1Long = ingestion?.substanceCopy?.nameUnwrapped ?? "No ingestion"
            let line1Short = ingestion?.substanceCopy?.nameUnwrapped.prefix(3) ?? "-"

            let template = CLKComplicationTemplateExtraLargeStackText(
                line1TextProvider: CLKSimpleTextProvider(text: line1Long, shortText: String(line1Short)),
                line2TextProvider: ingestion == nil ?
                    CLKSimpleTextProvider(text: "-") :
                    CLKRelativeDateTextProvider(date: ingestion!.timeUnwrapped, style: CLKRelativeDateStyle.timer, units: [.hour, .minute, .second])
            )
            return template
        case .modularLarge:
            let first3Ingestions = ingestions.prefix(3)

            let template = CLKComplicationTemplateModularLargeColumns(
                row1Column1TextProvider: getSubstanceTitle(substanceName: first3Ingestions[safe: 0]?.substanceCopy?.nameUnwrapped),
                row1Column2TextProvider: getTimeIntervalProvider(for: first3Ingestions[safe: 0]),
                row2Column1TextProvider: getSubstanceTitle(substanceName: first3Ingestions[safe: 1]?.substanceCopy?.nameUnwrapped),
                row2Column2TextProvider: getTimeIntervalProvider(for: first3Ingestions[safe: 1]),
                row3Column1TextProvider: getSubstanceTitle(substanceName: first3Ingestions[safe: 2]?.substanceCopy?.nameUnwrapped),
                row3Column2TextProvider: getTimeIntervalProvider(for: first3Ingestions[safe: 2])
            )
            return template
        default: // .graphicExtraLarge
            let template = CLKComplicationTemplateGraphicExtraLargeCircularView(
                ComplicationView(ingestions: ingestions, timeToDisplay: date)
            )
            return template
        }
    }

    private func getSubstanceTitle(substanceName: String?) -> CLKTextProvider {
        guard let substanceNameUnwrapped = substanceName else {return CLKSimpleTextProvider(text: "")}

        let long = substanceNameUnwrapped
        let short = substanceNameUnwrapped.prefix(3)

        return CLKSimpleTextProvider(text: long, shortText: String(short))
    }

    private func getTimeIntervalProvider(for ingestion: Ingestion?) -> CLKTextProvider {
        guard let ingestionUnwrapped = ingestion else {return CLKSimpleTextProvider(text: "")}

        return CLKTimeIntervalTextProvider(
            start: ingestionUnwrapped.timeUnwrapped,
            end: ingestionUnwrapped.endTime
        )
    }
}
