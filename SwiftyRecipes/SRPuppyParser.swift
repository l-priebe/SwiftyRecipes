//
//  SRPuppyParser.swift
//  Swifty Recipes
//
//  Created by Lasse Hammer Priebe on 12/02/16.
//  Copyright © 2016 Lasse Hammer Priebe. All rights reserved.
//

import Foundation

public class SRPuppyParser {
    
    typealias CompletionHandler = (result: [SRRecipe]?, error: NSError?) -> Void
    
    /**
    Parses a Recipe Puppy JSON response into a [SRRecipe] array.
    - parameter data: Data from Recipe Puppy in JSON format.
    - parameter completionHandler: Result is provided as an optional [SRRecipe] array and an optional NSError indicating error.
    */
    class func parseJSON(data: NSData, completionHandler: CompletionHandler) {
        
        var parsingError: NSError? = nil
        
        // Parse the data.
        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsedResult = nil
            parsingError = error
            return
        }
        
        // Handle the parsed data.
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            
            // Typecase to JSON object.
            guard let puppyDictionary = parsedResult as? [String: AnyObject] else {
                let error = NSError(domain: "Error in SRPuppyParser.parseJSON: Could not typecast parsed result into JSON object.", code: 701, userInfo: nil)
                completionHandler(result: nil, error: error)
                return
            }
            
            // Get recipe results.
            guard let results = puppyDictionary["results"] as? [[String: AnyObject]] else {
                let error = NSError(domain: "Error in SRPuppyParserparseJSON: Could not get results from Puppy dictionary.", code: 702, userInfo: nil)
                completionHandler(result: nil, error: error)
                return
            }
            
            // Check if no results were returned.
            if results.count == 0 {
                let error = NSError(domain: "Error in SRPuppyParserparseJSON: No results returned by Recipe Puppy.", code: 703, userInfo: nil)
                completionHandler(result: nil, error: error)
                return
            }
            
            var parsedResult = [SRRecipe]()
            
            // Add individual recipes to the parsed result.
            for result in results {
                
                // Make sure the keys are present.
                guard let title = result["title"] as? String, href = result["href"] as? String, ingredients = result["ingredients"] as? String else {
                    continue
                }
                
                // Create NSURLs for the href and thumbnail.
                guard let url = NSURL(string: href) else {
                    continue
                }
                let thumbnail = result["thumbnail"] as? String
                var thumbnailUrl: NSURL?
                
                if let thumbnailString = thumbnail {
                    thumbnailUrl = NSURL(string: thumbnailString)
                } else {
                    thumbnailUrl = nil
                }
                
                // Add the recipe to the parsed result.
                parsedResult.append(SRRecipe(title: title, ingredients: ingredients, url: url, thumbnailUrl: thumbnailUrl))
            }
            
            completionHandler(result: parsedResult, error: nil)
        }
    }
}