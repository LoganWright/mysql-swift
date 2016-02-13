//
//  Query.swift
//  MySQL
//
//  Created by Yusuke Ito on 12/14/15.
//  Copyright © 2015 Yusuke Ito. All rights reserved.
//

import Foundation

// inspired
// https://github.com/felixge/node-mysql/blob/master/lib/protocol/SqlString.js

public protocol QueryParameter {
    func escapedValue() throws -> String
}

public protocol QueryParameterDictionaryType: QueryParameter {
    func queryParameter() throws -> QueryDictionary
}

public extension QueryParameterDictionaryType {
    func escapedValue() throws -> String {
        return try queryParameter().escapedValue()
    }
}


public struct QueryParameterNull: QueryParameter, NilLiteralConvertible {
    public init() {
        
    }
    public init(nilLiteral: ()) {
        
    }
    public func escapedValue() -> String {
        return "NULL"
    }
}


struct SQLString {
    static func escapeId(str: String) -> String {
        var step1: [Character] = []
        for c in str.characters {
            switch c {
                case "`":
                step1.appendContentsOf("``".characters)
            default:
                step1.append(c)
            }
        }
        var out: [Character] = []
        for c in step1 {
            switch c {
                case ".":
                out.appendContentsOf("`.`".characters)
                default:
                out.append(c)
            }
        }
        return "`" + String(out) + "`"
    }
    
    static func escape(str: String) -> String {
        var out: [Character] = []
        for c in str.characters {
            switch c {
            case "\0":
                out.appendContentsOf("\\0".characters)
            case "\n":
                out.appendContentsOf("\\n".characters)
            case "\r":
                out.appendContentsOf("\\r".characters)
            case "\u{8}":
                out.appendContentsOf("\\b".characters)
            case "\t":
                out.appendContentsOf("\\t".characters)
            case "\\":
                out.appendContentsOf("\\\\".characters)
            case "'":
                out.appendContentsOf("\\'".characters)
            case "\"":
                out.appendContentsOf("\\\"".characters)
            case "\u{1A}":
                out.appendContentsOf("\\Z".characters)
            default:
                out.append(c)
            }
        }
        return "'" + String(out) + "'"
    }
}

extension String {
    
    func rangeOf(x: String) -> Range<Index>? {
        return characters.rangeOf(x.characters)
    }
}

extension String.CharacterView {
    
    func rangeOf(x: String.CharacterView) -> Range<Index>? {
        
        guard let first = x.first else { return nil }
        var offset = 0
        var search = self
        
        while !search.isEmpty {
            
            guard let firtIndex = search.indexOf(first) else { return nil }
            
            offset += search.startIndex.distanceTo(firtIndex)
            search = search.suffixFrom(firtIndex)
            
            if search.startsWith(x) {
                let start = startIndex.advancedBy(offset)
                return start..<start.advancedBy(x.count)
            }
            
            offset.advancedBy(1)
            search = search.dropFirst()
        }
        return nil
    }
}

public extension String {
    
    func retrieveRange(range: Range<Int>) -> String {
        var tempString = self
        
        enum rangeLocation {
            case prefix
            case nested
            case suffix
        }
        
        var thisRangeLocation: rangeLocation
        
        
        if range.startIndex == 0 {
            thisRangeLocation = rangeLocation.prefix
        } else if tempString.startIndex.advancedBy(Int(range.endIndex)-1) == tempString.endIndex {
            
            // DEPRECIATED in 7.1
            // } else if advance(tempString.startIndex, Int(range.endIndex)-1) == tempString.endIndex {
            
            thisRangeLocation = rangeLocation.suffix
        } else {
            thisRangeLocation = rangeLocation.nested
        }
        
        switch thisRangeLocation {
        case .prefix:
            tempString.retrieveRange(Range<String.Index>(start: tempString.startIndex.advancedBy(range.endIndex), end: tempString.endIndex))
            
            // DEPRECIATED in 7.1
        // tempString.removeRange(Range<String.Index>(start: advance(tempString.startIndex, range.endIndex), end: tempString.endIndex))
        case .suffix:
            tempString.removeRange(Range<String.Index>(start: tempString.startIndex, end: tempString.startIndex.advancedBy(range.startIndex)))
            
            // DEPRECIATED in 7.1
        // tempString.removeRange(Range<String.Index>(start: tempString.startIndex, end: advance(tempString.startIndex, range.startIndex)))
        case .nested:
            
            tempString.removeRange(Range<String.Index>(start: tempString.startIndex.advancedBy(range.endIndex), end: tempString.endIndex))
            
            // DEPRECIATED in 7.1
            // tempString.removeRange(Range<String.Index>(start: advance(tempString.startIndex, range.endIndex), end: tempString.endIndex))
            
            tempString.removeRange(Range<String.Index>(start: tempString.startIndex, end: tempString.startIndex.advancedBy(range.startIndex)))
            
            // DEPRECIATED in 7.1
            // tempString.removeRange(Range<String.Index>(start: tempString.startIndex, end: advance(tempString.startIndex, range.startIndex)))
        }
        
        return tempString
    }
    
    func retrieveRange(range: Range<String.Index>) -> String {
        var tempString = self
        
        enum rangeLocation {
            case prefix
            case nested
            case suffix
        }
        
        var thisRangeLocation: rangeLocation
        
        if range.startIndex == self.startIndex {
            thisRangeLocation = rangeLocation.prefix
        } else if range.endIndex == tempString.endIndex {
            thisRangeLocation = rangeLocation.suffix
        } else {
            thisRangeLocation = rangeLocation.nested
        }
        
        switch thisRangeLocation {
        case .prefix:
            tempString.removeRange(Range<String.Index>(start: range.endIndex, end: tempString.endIndex))
        case .suffix:
            tempString.removeRange(Range<String.Index>(start: tempString.startIndex, end: range.startIndex))
        case .nested:
            tempString.removeRange(Range<String.Index>(start: range.endIndex, end: tempString.endIndex))
            tempString.removeRange(Range<String.Index>(start: tempString.startIndex, end: range.startIndex))
        }
        
        return tempString
        
    }
    func convertIndexRange(range: Range<Int>) -> Range<String.Index> {
        
        return Range<String.Index>(start: self.startIndex.advancedBy(range.startIndex), end: self.startIndex.advancedBy(range.endIndex))
        
        // DEPRECIATED in 7.1
        // return Range<String.Index>(start: advance(self.startIndex, range.startIndex), end: advance(self.startIndex, range.endIndex))
    }
    
    subscript (i: Int) -> Character {
        get {
            
            return self[self.startIndex.advancedBy(i)]
            
            // DEPRECIATED in 7.1
            // return self[advance(self.startIndex, i)]
        }
    }
    
    subscript (range: Range<Int>) -> String {
        get {
            
            // DEPRECIATED in 7.1
            // if advance(self.startIndex, range.endIndex-1) == self.endIndex {
            
            if self.startIndex.advancedBy(range.endIndex - 1) == self.endIndex {
                
                return self[Range<String.Index>(start: self.startIndex.advancedBy(range.startIndex), end: self.startIndex.advancedBy(range.endIndex - 1 ))]
                
                // DEPRECIATED in 7.1
                // return self[Range<String.Index>(start: advance(self.startIndex, range.startIndex), end: advance(self.startIndex, range.endIndex-1))]
            } else {
                
                return self[Range<String.Index>(start: self.startIndex.advancedBy(range.startIndex), end: self.startIndex.advancedBy(range.endIndex))]
                
                // DEPRECIATED in 7.1
                // return self[Range<String.Index>(start: advance(self.startIndex, range.startIndex), end: advance(self.startIndex, range.endIndex))]
            }
        }
    }
    
    func indiciesOf(string: String) -> [Range<String.Index>] {
        var rangeArray = [Range<String.Index>]()
        var startIndex = self.startIndex
        
        if self.characters.contains(string.characters.first!) {
            startIndex = self.characters.indexOf(string.characters.first!)!
        } else {
            return rangeArray
        }
        
        
        var i = self.startIndex.distanceTo(startIndex)
        
        // DEPRECIATED in 7.1
        // var i = distance(self.startIndex, startIndex)
        
        while (i <= self.characters.count - string.characters.count) {
            
            if self[self.startIndex.advancedBy(i)..<self.startIndex.advancedBy(i + string.characters.count)] == string {
                
                // DEPRECIATED in 7.1
                // if self[advance(self.startIndex, i)..<advance(self.startIndex, i + string.characters.count)] == string {
                
                let rangeFound = Range<String.Index>(start: self.startIndex.advancedBy(i), end: self.startIndex.advancedBy(i + string.characters.count))
                
                // DEPRECIATED in 7.1
                // let rangeFound = Range<String.Index>(start: advance(self.startIndex, i), end: advance(self.startIndex, i + string.characters.count))
                rangeArray.append(rangeFound)
                i = i + string.characters.count
            } else {
                i.advancedBy(1)
            }
        }
        return rangeArray
    }
    
}

public struct QueryFormatter {
    
    public static func format<S: SequenceType where S.Generator.Element == QueryParameter>(query: String, args argsg: S) throws -> String {
        var args: [QueryParameter] = []
        for a in argsg {
            args.append(a)
        }
        
        var placeHolderCount: Int = 0
        
        let formatted = query + ""
        
        var valArgs: [QueryParameter] = []
        
        var escapedString = ""
        let chunks = formatted.parseQueryChunks()
        for chunk in chunks {
            switch chunk {
            case .StringChunk(let chunk):
                escapedString += chunk
            case .DoubleMark:
                if placeHolderCount >= args.count {
                    throw QueryError.QueryParameterCountMismatch
                }
                guard let val = args[placeHolderCount] as? String else {
                    throw QueryError.QueryParameterIdTypeError
                }
                escapedString += SQLString.escapeId(val)
            case .SingleMark:
                if placeHolderCount >= args.count {
                    throw QueryError.QueryParameterCountMismatch
                }
                valArgs.append(args[placeHolderCount])
            }
            
            placeHolderCount += 1
            
            if placeHolderCount >= args.count {
                break
            }
        }
//        
//        // format ??
//        while true {
//            let substring = formatted.retrieveRange(scanRange)
//            let r1 = substring.rangeOf("??")
//            let r2 = substring.rangeOf("?")
//            let r: Range<String.Index>
//            if let r1 = r1, let r2 = r2 {
//                r = r1.startIndex <= r2.startIndex ? r1 : r2
//            } else if let rr = r1 ?? r2 {
//                r = rr
//            } else {
//                break
//            }
//            
//            switch formatted[r] {
//            case "??":
//                if placeHolderCount >= args.count {
//                    throw QueryError.QueryParameterCountMismatch
//                }
//                guard let val = args[placeHolderCount] as? String else {
//                    throw QueryError.QueryParameterIdTypeError
//                }
//                formatted.replaceRange(r, with: SQLString.escapeId(val))
//                scanRange = r.endIndex..<formatted.endIndex
//            case "?":
//                if placeHolderCount >= args.count {
//                    throw QueryError.QueryParameterCountMismatch
//                }
//                valArgs.append(args[placeHolderCount])
//                scanRange = r.endIndex..<formatted.endIndex
//            default: break
//            }
//            
//            placeHolderCount += 1
//            
//            if placeHolderCount >= args.count {
//                break
//            }
//        }
        
        //print(formatted, valArgs)
        
        placeHolderCount = 0
        var formattedChars = Array(escapedString.characters)
        var index: Int = 0
        while index < formattedChars.count {
            if formattedChars[index] == "?" {
                if placeHolderCount >= valArgs.count {
                    throw QueryError.QueryParameterCountMismatch
                }
                let val = valArgs[placeHolderCount]
                formattedChars.removeAtIndex(index)
                let valStr = (try val.escapedValue())
                formattedChars.insertContentsOf(valStr.characters, at: index)
                index += valStr.characters.count-1
                placeHolderCount += 1
            } else {
                index += 1
            }
        }
        
        return String(formattedChars)
    }
}

extension Array {
    public var ip_generator: AnyGenerator<Element> {
        var idx = 0
        let count = self.count
        return AnyGenerator {
            guard idx < count else { return nil }
            let this = idx
            idx += 1
            return self[this]
        }
    }
}

extension String {
    enum Chunk {
        case StringChunk(String)
        case DoubleMark
        case SingleMark
    }
    
    func parseQueryChunks() -> [Chunk] {
        var chunks: [Chunk] = []
        var currentChunk: [Character] = []
        var generator = Array(characters).generate()
        while let char = generator.next() {
            if char == "?" {
                if !currentChunk.isEmpty {
                    chunks.append(.StringChunk(String(currentChunk)))
                    chunks = []
                }
                
                // Check for double quote
                if let next = generator.next() {
                    if next == "?" {
                        chunks.append(.DoubleMark)
                    } else {
                        chunks.append(.SingleMark)
                        currentChunk.append(next)
                    }
                }
            } else {
                currentChunk.append(char)
            }
        }
        
        return chunks
    }
}

extension Connection {
    
    public func query<T: QueryRowResultType>(query: String, _ args: [QueryParameter] = []) throws -> ([T], QueryStatus) {
        return try self.query(query: try QueryFormatter.format(query, args: args))
    }
    
    public func query<T: QueryRowResultType>(query: String, _ args: [QueryParameter] = []) throws -> [T] {
        let (rows, _) = try self.query(query, args) as ([T], QueryStatus)
        return rows
    }
    
    public func query(query: String, _ args: [QueryParameter] = []) throws -> QueryStatus {
        let (_, status) = try self.query(query, args) as ([EmptyRowResult], QueryStatus)
        return status
    }
}