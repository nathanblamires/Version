//
//  Version.swift
//  Version
//
//  Created by Nathan Blamires on 10/8/19.
//  Copyright © 2019 nathanblamires. All rights reserved.
//

import Foundation

public struct Version: Codable, Hashable {
        
    // Details of how semantic versioning works at: https://semver.org/
    
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    public let prereleaseString: String?
    public let metadataString: String?
    
    public var prereleaseIdentifiers: [String] {
        prereleaseString?.split(separator: ".").map { String($0) } ?? []
    }
    
    public var metadataIdentifiers: [String] {
        metadataString?.split(separator: ".").map { String($0) } ?? []
    }
    
    public var isPrerelease: Bool {
        !prereleaseIdentifiers.isEmpty
    }
    
    public init(major: Int = 0, minor: Int = 0, patch: Int = 0, prerelease: String? = nil, metadata: String? = nil) throws {
        
        guard major >= 0, minor >= 0, patch >= 0 else {
            throw Error.illegalNegativeVersionNumbers
        }
        
        self.major = major
        self.minor = minor
        self.patch = patch
        
        let validPrerelease = prerelease.map { value -> Bool in
            let scanner = Scanner(string: value)
            var scanResult: NSString? = nil
            scanner.scanCharacters(from: CharacterSet.indentifiersString, into: &scanResult)
            return scanner.isAtEnd
        }
        guard (validPrerelease ?? true) else { throw Error.invalidPrereleaseString }
        
        let validMetadata = metadata.map { value -> Bool in
            let scanner = Scanner(string: value)
            var scanResult: NSString? = nil
            scanner.scanCharacters(from: CharacterSet.indentifiersString, into: &scanResult)
            return scanner.isAtEnd
        }
        guard (validMetadata ?? true) else { throw Error.invalidMetadataString }
        
        self.prereleaseString = prerelease
        self.metadataString = metadata
    }
    
    public init(major: Int, minor: Int, patch: Int, prereleaseIdentifiers: [String], metadataIdentifiers: [String]) throws {
        let hasPrereleasIdentifiers = prereleaseIdentifiers.count > 0
        let prerelease: String? = hasPrereleasIdentifiers ? prereleaseIdentifiers.joined(separator: ".") : nil
        let hasMetadataIdentifiers = metadataIdentifiers.count > 0
        let metadata: String? = hasMetadataIdentifiers ? metadataIdentifiers.joined(separator: ".") : nil
        try self.init(major: major, minor: minor, patch: patch, prerelease: prerelease, metadata: metadata)
    }
    
    public enum Error: Swift.Error {
        case malformedVersionString
        case invalidPrereleaseString
        case invalidMetadataString
        case illegalNegativeVersionNumbers
    }
}

// MARK:- CustomStringConvertible

extension Version: CustomStringConvertible {
    
    public var description: String {
        var text = "\(major).\(minor).\(patch)"
        if let prerelease = prereleaseString {
            text += "-\(prerelease)"
        }
        if let metadata = metadataString {
            text += "+\(metadata)"
        }
        return text
    }
}

// MARK: - Comparable

public func === (lhs: Version, rhs: Version) -> Bool {
    (lhs == rhs) && (lhs.metadataString == rhs.metadataString)
}

public func !==(lhs: Version, rhs: Version) -> Bool {
    return !(lhs === rhs)
}

extension Version: Comparable {
    
    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.patch == rhs.patch &&
            lhs.prereleaseString == rhs.prereleaseString
    }
    
    public static func < (lhs: Version, rhs: Version) -> Bool {
          
        // handle major/minor/patch difference
        let lhsComponents = [lhs.major, lhs.minor, lhs.patch]
        let rhsComponents = [rhs.major, rhs.minor, rhs.patch]
        if let differingComponent = zip(lhsComponents, rhsComponents).first(where: { $0 != $1 }) {
            return differingComponent.0 < differingComponent.1
        }

        // handle prerelease difference
        switch (lhs.isPrerelease, rhs.isPrerelease) {
        case (true, true):
            return isPrerelease(lhs.prereleaseString!, lessThan: rhs.prereleaseString!)
        case (true, false):
            return true
        default:
            return false
        }
    }
    
    public static func isPrerelease(_ lhs: String, lessThan rhs: String) -> Bool {
        
        let lhsIds = lhs.split(separator: ".").map { String($0) }
        let rhsIds = rhs.split(separator: ".").map { String($0) }
        guard let differingPair = zip(lhsIds, rhsIds).first(where: { $0 != $1 }) else {
            return lhs.count < rhs.count
        }
        
        let leftNumber = Int(differingPair.0) ?? Int.max
        let rightNumber = Int(differingPair.1) ?? Int.max
        
        if leftNumber != rightNumber {
            return leftNumber < rightNumber
        }
        return differingPair.0 < differingPair.1
    }
}

// MARK:- ExpressibleByStringLiteral

extension Version: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(_ value: String, strict: Bool = false) throws {
        
        let scanner = Scanner(string: value)
        
        major = try scanner.nextNumber()
        
        do {
            try scanner.advance(over: ".")
            minor = try scanner.nextNumber()
        } catch Scanner.Error.valueNotAtScanLocation {
            if strict { throw Error.malformedVersionString }
            minor = 0
        }
        
        do {
            try scanner.advance(over: ".")
            patch = try scanner.nextNumber()
        } catch Scanner.Error.valueNotAtScanLocation {
            if strict { throw Error.malformedVersionString }
            patch = 0
        }
        
        let isPrerelease = (try? scanner.advance(over: "-")) != nil
        prereleaseString = isPrerelease ? try scanner.nextIdentifiers().joined(separator: ".") : nil
        let hasMetadata = (try? scanner.advance(over: "+")) != nil
        metadataString = hasMetadata ? try scanner.nextIdentifiers(allowLeadingZeros: true).joined(separator: ".") : nil
        guard scanner.isAtEnd else { throw Error.malformedVersionString }
    }
    
    public init(stringLiteral value: String) {
        do {
            try self.init(value)
        } catch {
            print("Version error: Malformed version string \(value). Setting to \"0.0.0\".")
            try! self.init(major: 0)
        }
    }
}

// MARK:- Scanner Helper Functions

extension Scanner {
    
    fileprivate func nextNumber() throws -> Int {
        var component: NSString?
        scanCharacters(from: CharacterSet.decimalDigits, into: &component)
        guard let string = component as String?, let number = Int(string) else {
            throw Error.invalidNumber
        }
        if number != 0 && string.first == "0" {
            throw Error.leadingZerosProhibited
        }
        return number
    }
    
    fileprivate func nextIdentifier(allowLeadingZero: Bool = false) throws -> String {
        var string: NSString?
        scanCharacters(from: CharacterSet.indentifier, into: &string)
        guard let identifier = string as String?, !identifier.isEmpty else {
            throw Error.invalidIdentifier
        }
        if !allowLeadingZero, let asInt = Int(identifier), asInt != 0, identifier.first == "0" {
            throw Error.leadingZerosProhibited
        }
        return identifier
    }
    
    fileprivate func nextIdentifiers(allowLeadingZeros: Bool = false) throws -> [String] {
        var identifiers: [String] = []
        repeat {
            identifiers.append(try nextIdentifier(allowLeadingZero: allowLeadingZeros))
            guard scanString(".", into: nil) else { break }
        } while (true)
        return identifiers
    }
    
    fileprivate func advance(over value: String) throws {
        guard scanString(value, into: nil) else {
            throw Error.valueNotAtScanLocation
        }
    }
    
    public enum Error: Swift.Error {
        case leadingZerosProhibited
        case invalidNumber
        case invalidIdentifier
        case valueNotAtScanLocation
    }
}

// MARK:- Additional CharacterSet Definition

extension CharacterSet {
    
    fileprivate static let indentifier: CharacterSet = {
        let characters = "-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return NSMutableCharacterSet(charactersIn: characters) as CharacterSet
    }()
    
    fileprivate static let indentifiersString: CharacterSet = {
        let characters = "-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ."
        return NSMutableCharacterSet(charactersIn: characters) as CharacterSet
    }()
}

