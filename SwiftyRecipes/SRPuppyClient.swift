//
//  SRPuppyClient.swift
//  Swifty Recipes
//
//  Created by Lasse Hammer Priebe on 12/02/16.
//  Copyright © 2016 Lasse Hammer Priebe. All rights reserved.
//

import Foundation

public class SRPuppyClient {
    
    public typealias CompletionHandler = (result: [SRRecipe]?, error: NSError?) -> Void
    
    // MARK: Properties
    
    public let imageCache = SRImageCache()
    public var includesRecipesWithoutThumbnails: Bool {
        get {
            return onlyImages == 0
        }
        set {
            if newValue == true {
                onlyImages = 0
            } else {
                onlyImages = 1
            }
        }
    }

    private let session: NSURLSession!
    private var onlyImages: Int = 1
    
    // MARK: Life Cycle
    
    private init() {
        session = NSURLSession.sharedSession()
    }
    
    class func sharedClient() -> SRPuppyClient {
        
        struct Singleton {
            static let sharedClient = SRPuppyClient()
        }
        
        return Singleton.sharedClient
    }
    
    // MARK: Convenience Methods
    
    /**
    Utilizes a NSURLSessionDataTask to retrieve recipes using the Recipe Puppy API.
    - parameter ingredients: An optional array of ingredient names represented by a [String].
    - parameter query: An optional search query represented by a String.
    - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
    - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional [SRRecipe] array and an optional NSError indicating error.
    */
    public func fetchRecipes(ingredients: [String]?, query: String?, page: Int = 1, completionHandler: CompletionHandler)  {
        
        taskWithParameters(ingredients, query: query, page: page) { result, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: error)
            }
        }
    }
    
    /**
     Utilizes a NSURLSessionDataTask to retrieve recipes using the Recipe Puppy API.
     - parameter ingredients: An optional array of ingredient names represented by a [String].
     - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
     - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional [SRRecipe] array and an optional NSError indicating error.
     */
    public func fetchRecipesWithIngredients(ingredients: [String]?, page: Int = 1, completionHandler: CompletionHandler) -> Void {
        
        taskWithParameters(ingredients, query: nil, page: page) { result, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: error)
            }
        }
    }
    
    /**
     Utilizes a NSURLSessionDataTask to retrieve recipes using the Recipe Puppy API.
     - parameter query: An optional search query represented by a String.
     - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
     - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional [SRRecipe] array and an optional NSError indicating error.
     */
    public func fetchRecipesWithQuery(query: String?, page: Int = 1, completionHandler: CompletionHandler) -> Void {
        
        taskWithParameters(nil, query: query, page: page) { result, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: error)
            }
        }
    }
    
    // MARK: Task Method
    
    /**
    Creates a NSURLSessionDataTask for a Recipe Puppy API request given a set of parameters.
    - parameter ingredients: An optional array of ingredient names represented by a [String].
    - parameter query: An optional search query represented by a String.
    - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
    - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional [SRRecipe] array and an optional NSError indicating error. If the recipe array and errors are both nil, this indicates correct response with no result.
    - returns: The created NSURLSessionDataTask if an url can be created with the provided parameters. Otherwise nil is returned.
    */
    public func taskWithParameters(ingredients: [String]?, query: String?, page: Int = 1, completionHandler: CompletionHandler) -> NSURLSessionDataTask? {
        
        // Create the url request.
        if let url = SRPuppyAPI.getURLWithParameters(ingredients, query: query, page: page, onlyImages: onlyImages) {
            let request = NSURLRequest(URL: url)
            
            // Create the task.
            let task = session.dataTaskWithRequest(request) {data, response, downloadError in
                
                // Parse the data if no errors were returned.
                if let error = downloadError {
                    completionHandler(result: nil, error: error)
                } else if let data = data {
                    SRPuppyParser.parseJSON(data, completionHandler: completionHandler)
                } else {
                    completionHandler(result: nil, error: nil)
                }
            }
            task.resume()
            return task
        } else {
            return nil
        }
    }
}