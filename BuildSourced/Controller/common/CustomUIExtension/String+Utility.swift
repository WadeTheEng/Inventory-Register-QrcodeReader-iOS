//
//  String+Utility.swift
//  SecureTribe
//
//  Created by Zhang Yi on 25/11/2015.
//  Copyright © 2015 JustTwoDudes. All rights reserved.
//

import Foundation

// MARK: - Remove non alpha numeric hypens
extension String{
    /**
     A mutating function which removes non alpha numeric, and not hypen characters from self
     */
    mutating func removeNonAlphaNumericHypens(){
        self = removedNonAlphaNumericHypensString()
    }
    
    /**
     Removes non alpha numeric, and not hypen characters from self
     - Returns: new filtered string
     */
    func removedNonAlphaNumericHypensString() -> String{
        let cset = NSMutableCharacterSet.alphanumeric()
        cset.addCharacters(in: "_-")
        return components(separatedBy: cset.inverted).joined(separator: "")
    }
}

// MARK: - Localization extension
extension String {
    /**
     Get localized string from Localizable.strings file
     - Returns: Localized String from table.
     */
    func localizedString() -> String{
        return NSLocalizedString(self, tableName:"Localizable", comment:"")
    }
}

// MARK: - NSRange to Range convert
extension String {
    /**
     Converts NSRange to Range for this string
     - Returns: Converted Range instance
     */
    func rangeFromNSRange(nsRange:NSRange) -> Range<Index>{
        let startElement = index(startIndex, offsetBy: nsRange.location)
            //startIndex.advancedBy(nsRange.location)
        let endElement = index(startElement,offsetBy: nsRange.length)
            //startElement.advancedBy(nsRange.length)
        
        return startElement..<endElement
            //Range(start: startElement, end: endElement)
        
    }
}

// MARK: - Trim String
extension String{
    /**
     Removes prefix and suffix " "
     */
    func trimmedString() -> String{
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}
