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
import SwiftUI

struct OnsetTotalTimeline: TimelineDrawable {

    let onset: FullDurationRange
    let total: FullDurationRange
    let onsetDelayInHours: Double
    let totalWeight: Double
    let verticalWeigth: Double
    let ingestionTimeRelativeToStartInSeconds: TimeInterval
    let percentSmoothness: Double = 0.5

    var endOfLineRelativeToStartInSeconds: TimeInterval {
        ingestionTimeRelativeToStartInSeconds + onsetDelayInSeconds + total.max
    }

    func draw(
        context: GraphicsContext,
        height: Double,
        pixelsPerSec: Double,
        color: Color,
        lineWidth: Double
    ) {
        let startX = ingestionTimeRelativeToStartInSeconds*pixelsPerSec
        var top = lineWidth/2
        if verticalWeigth < 1 {
            top = ((1-verticalWeigth)*height) + (lineWidth/2)
        }
        let bottom = height - lineWidth/2
        context.drawDot(startX: startX, bottomY: bottom, dotRadius: 1.5 * lineWidth, color: color)
        let onsetWeight = 0.5
        let onsetEndX = startX + (onsetDelayInSeconds + onset.interpolateLinearly(at: onsetWeight)) * pixelsPerSec
        var path0 = Path()
        path0.move(to: CGPoint(x: startX, y: bottom))
        path0.addLine(to: CGPoint(x: onsetEndX, y: bottom))
        context.stroke(path0, with: .color(color), style: StrokeStyle.getNormal(lineWidth: lineWidth))
        let totalX = total.interpolateLinearly(at: totalWeight) * pixelsPerSec
        let topPointX = onsetEndX + (total.interpolateLinearly(at: totalWeight) - onset.interpolateLinearly(at: onsetWeight))/2 * pixelsPerSec
        var path1 = Path()
        path1.move(to: CGPoint(x: onsetEndX, y: bottom))
        path1.endSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: onsetEndX,
            endX: topPointX,
            endY: top
        )
        path1.startSmoothLineTo(
            smoothnessBetween0And1: percentSmoothness,
            startX: topPointX,
            startY: top,
            endX: startX + onsetDelayInSeconds*pixelsPerSec + totalX,
            endY: bottom
        )
        context.stroke(
            path1,
            with: .color(color),
            style: StrokeStyle.getDotted(lineWidth: lineWidth)
        )
    }

    private var onsetDelayInSeconds: TimeInterval {
        onsetDelayInHours * 60 * 60
    }
}

extension RoaDuration {
    func toOnsetTotalTimeline(
        totalWeight: Double,
        verticalWeight: Double,
        onsetDelayInHours: Double,
        ingestionTimeRelativeToStartInSeconds: TimeInterval
    ) -> OnsetTotalTimeline? {
        if let fullTotal = total?.maybeFullDurationRange, let fullOnset = onset?.maybeFullDurationRange {
            return OnsetTotalTimeline(
                onset: fullOnset,
                total: fullTotal,
                onsetDelayInHours: onsetDelayInHours,
                totalWeight: totalWeight,
                verticalWeigth: verticalWeight,
                ingestionTimeRelativeToStartInSeconds: ingestionTimeRelativeToStartInSeconds
            )
        } else {
            return nil
        }
    }
}
