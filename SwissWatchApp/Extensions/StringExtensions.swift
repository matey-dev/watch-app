//
//  StringExtensions.swift
//  SwissWatchApp
//
//  Created by Matey Borisov on 8/3/19.
//  Copyright © 2019 Matey Borisov. All rights reserved.
//

import UIKit

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func replace(with param: Any) -> String {
        return self.replacingOccurrences(of: "%s", with: "\(param)")
    }
    
    static func combine(strings: [String?]) -> String {
        return strings.compactMap { $0 }.joined(separator: " ")
    }
    
    func htmlToAttributedString(font: UIFont, color: UIColor? = nil) -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        let resultAttributetString = try? NSMutableAttributedString(data: data,
                                                                    options: [.documentType: NSAttributedString.DocumentType.html,
                                                                              .characterEncoding: String.Encoding.utf8.rawValue],
                                                                    documentAttributes: nil)
        resultAttributetString?.set(font: font, color: color)
        return resultAttributetString
    }
    
    func strikethrough() -> NSAttributedString {
        return NSMutableAttributedString(string: self,
                                         attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue])
    }
    
    // MARK: - Calculate text width
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        
        return ceil(boundingBox.width)
    }
    // MARK: - Calculate text height
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func getLast(stringElement: String.Element) -> String? {
        return self.last(where: { $0 == stringElement }).map { String($0) }
    }
    
    func remove(text: String) {
        _ = self.replacingOccurrences(of: text, with: "")
    }
    
    func escapingBackslash() -> String {
        return self.replacingOccurrences(of: "\\", with: "\\\\", options: .literal, range: nil)
    }
    
    func quoted() -> String {
        return "\"\(self)\""
    }
    
    // MARK: - make colored strings
    func makePink(text: String, font: UIFont? = nil) -> NSAttributedString {
        let nsSelf = NSString(string: self)
        let pinkRange = nsSelf.range(of: text)
        let color = Colors.redDark
        let attrText = NSMutableAttributedString(string: self)
        font.map { attrText.set(font: $0) }
        attrText.addAttribute(.foregroundColor, value: color, range: pinkRange)
        return attrText
    }
    
    static var empty: String { return "" }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension NSMutableAttributedString {
    func set(font: UIFont, color: UIColor?) {
        var attrs = self.attributes(at: 0, effectiveRange: nil)
        attrs[.font] = font
        attrs[.foregroundColor] = color
        self.setAttributes(attrs, range: NSRange(location: 0, length: self.length))
    }
    
    func set(font: UIFont) {
        var attrs = self.attributes(at: 0, effectiveRange: nil)
        attrs[.font] = font
        self.setAttributes(attrs, range: NSRange(location: 0, length: self.length))
    }
    
    func replaceFont(with font: UIFont) {
        self.beginEditing()
        self.enumerateAttribute(.font, in: NSRange(location: 0, length: self.length)) { (value, range, _) in
            if let f = value as? UIFont {
                if let ufd = f.fontDescriptor.withFamily(font.familyName).withSymbolicTraits(f.fontDescriptor.symbolicTraits) {
                    let newFont = UIFont(descriptor: ufd, size: f.pointSize)
                    self.removeAttribute(.font, range: range)
                    self.addAttribute(.font, value: newFont, range: range)
                }
            }
        }
        self.endEditing()
    }
    
    func removeLastCharacter() {
        self.deleteCharacters(in: NSRange(location: self.length - 1, length: 1))
    }
}

extension NSMutableAttributedString {
    @discardableResult
    public func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttributes([.attachment: URL(string: linkURL)!, .underlineStyle: 0, .foregroundColor: Colors.blackTextColor], range: foundRange)
            return true
        }
        return false
    }
}
