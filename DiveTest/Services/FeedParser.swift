//
//  XMLParser.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//
import Foundation
import CoreData
import UIKit

class FeedParser: NSObject {
    
    private var rssItems: [RSSItem] = []
    private var currentElement = ""
    private let regexImg = "(http[^\\s]+(jpg|jpeg|png|tiff)\\b)"
    private var parserCompletionHandler: (([RSSItem]) -> Void)?

//    private let regexImg = "(<img.*?src=\")(.*?)(\".*?>)"

    
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var pubDate: String = "" {
        didSet {
            pubDate = pubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }

    private var currentLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentPostId: String = "" {
        didSet {
            let id = currentPostId.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            currentPostId = id.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        }
    }
    
    private var currentImgLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            let result = imgMatches(for: self.regexImg, in: currentImgLink)
            if let img = result.first {
                self.currentImgLink = img
            }
        }
    }
    
    func imgMatches(for regex: String!, in text: String!) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: [])
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSMakeRange(0, nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func parseFeed(url: String, completionHandler: (([RSSItem]) -> Void)?) {
        self.parserCompletionHandler = completionHandler
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
}

extension FeedParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            pubDate = ""
            currentLink = ""
            currentImgLink = ""
            currentPostId = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "title": currentTitle += string
        case "pubDate": pubDate += string
        case "link": currentLink += string
        case "content:encoded" : currentImgLink += string
        case "description" : currentImgLink += string
        case "guid": currentPostId += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let rssItem = RSSItem(title: currentTitle, pubdate: pubDate, link: currentLink, imgUrl: currentImgLink, postId: currentPostId)
            rssItems += [rssItem]
            DataManager.shared.storeFeed(rss: rssItem)
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("parseErrorOccurred: \(parseError)")
    }
}
