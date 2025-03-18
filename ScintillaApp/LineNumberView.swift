//
//  LineNumberView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 3/18/25.
//

import AppKit

class LineNumberView: NSRulerView {
    var font: NSFont! {
        didSet {
            self.needsDisplay = true
        }
    }

    init(textView: NSTextView) {
        super.init(scrollView: textView.enclosingScrollView!,
                   orientation: NSRulerView.Orientation.verticalRuler)
        self.font = NSFont.systemFont(ofSize: NSFont.smallSystemFontSize)
        self.clientView = textView

        self.ruleThickness = 40

        self.clipsToBounds = true
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func drawHashMarksAndLabels(in rect: NSRect) {
        NSColor(named: "EditorBackground")!.setFill()
        self.bounds.fill()

        if let textView = self.clientView as? NSTextView {
            if let layoutManager = textView.layoutManager {
                let relativePoint = self.convert(NSZeroPoint, from: textView)
                let lineNumberAttributes = [
                    NSAttributedString.Key.font: textView.font!.withSize(10.0),
                    NSAttributedString.Key.foregroundColor: NSColor.lightGray]
                as [NSAttributedString.Key : Any]

                let drawLineNumber = { (lineNumberString:String, y:CGFloat) -> Void in
                    let attString = NSAttributedString(string: lineNumberString, attributes: lineNumberAttributes)
                    let x = 35 - attString.size().width
                    attString.draw(at: NSPoint(x: x, y: relativePoint.y + y + 3))
                }

                let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
                let firstVisibleGlyphCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)

                let newLineRegex = try! NSRegularExpression(pattern: "\n", options: [])
                // The line number for the first visible line
                var lineNumber = newLineRegex.numberOfMatches(in: textView.string, options: [], range: NSMakeRange(0, firstVisibleGlyphCharacterIndex)) + 1

                var glyphIndexForStringLine = visibleGlyphRange.location

                // Go through each line in the string.
                while glyphIndexForStringLine < NSMaxRange(visibleGlyphRange) {

                    // Range of current line in the string.
                    let characterRangeForStringLine = (textView.string as NSString).lineRange(
                        for: NSMakeRange( layoutManager.characterIndexForGlyph(at: glyphIndexForStringLine), 0 )
                    )
                    let glyphRangeForStringLine = layoutManager.glyphRange(forCharacterRange: characterRangeForStringLine, actualCharacterRange: nil)

                    var glyphIndexForGlyphLine = glyphIndexForStringLine
                    var glyphLineCount = 0

                    while ( glyphIndexForGlyphLine < NSMaxRange(glyphRangeForStringLine) ) {

                        // See if the current line in the string spread across
                        // several lines of glyphs
                        var effectiveRange = NSMakeRange(0, 0)

                        // Range of current "line of glyphs". If a line is wrapped,
                        // then it will have more than one "line of glyphs"
                        let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndexForGlyphLine, effectiveRange: &effectiveRange, withoutAdditionalLayout: true)

                        if glyphLineCount > 0 {
                            drawLineNumber("-", lineRect.minY)
                        } else {
                            drawLineNumber("\(lineNumber)", lineRect.minY)
                        }

                        // Move to next glyph line
                        glyphLineCount += 1
                        glyphIndexForGlyphLine = NSMaxRange(effectiveRange)
                    }

                    glyphIndexForStringLine = NSMaxRange(glyphRangeForStringLine)
                    lineNumber += 1
                }

                // Draw line number for the extra line at the end of the text
                if layoutManager.extraLineFragmentTextContainer != nil {
                    drawLineNumber("\(lineNumber)", layoutManager.extraLineFragmentRect.minY)
                }
            }
        }
    }
}
