//
//  SRPuppyClient.swift
//  Swifty Recipes
//
//  Created by Lasse Hammer Priebe on 12/02/16.
//  Copyright © 2016 Hundredeni. All rights reserved.
//

import Foundation

open class SRPuppyClient {
    
    public typealias CompletionHandler = (_ result: [SRRecipe]?, _ error: NSError?) -> Void
    
    // MARK: Properties
    
    open let imageCache = SRImageCache()
    open var includesRecipesWithoutThumbnails: Bool {
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
    
    fileprivate let session: URLSession!
    fileprivate var onlyImages: Int = 1
    
    // MARK: Life Cycle
    
    fileprivate init() {
        session = URLSession.shared
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
    open func fetchRecipes(_ ingredients: [String]?, query: String?, page: Int = 1, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask? {
        
        return taskWithParameters(ingredients, query: query, page: page) { result, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, error)
            }
        }
    }
    
    /**
     Utilizes a NSURLSessionDataTask to retrieve recipes using the Recipe Puppy API.
     - parameter ingredients: An optional array of ingredient names represented by a [String].
     - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
     - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional [SRRecipe] array and an optional NSError indicating error.
     */
    open func fetchRecipesWithIngredients(_ ingredients: [String]?, page: Int = 1, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask? {
        
        return taskWithParameters(ingredients, query: nil, page: page) { result, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, error)
            }
        }
    }
    
    /**
     Utilizes a NSURLSessionDataTask to retrieve recipes using the Recipe Puppy API.
     - parameter query: An optional search query represented by a String.
     - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
     - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional [SRRecipe] array and an optional NSError indicating error.
     */
    open func fetchRecipesWithQuery(_ query: String?, page: Int = 1, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask? {
        
        return taskWithParameters(nil, query: query, page: page) { result, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, error)
            }
        }
    }
    
    // MARK: Task Methods
    
    /**
     Creates a NSURLSessionDataTask for a Recipe Puppy API request given a set of parameters.
     - parameter ingredients: An optional array of ingredient names represented by a [String].
     - parameter query: An optional search query represented by a String.
     - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
     - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional [SRRecipe] array and an optional NSError indicating error. If the recipe array and errors are both nil, this indicates correct response with no result.
     - returns: The created NSURLSessionDataTask if an url can be created with the provided parameters. Otherwise nil is returned.
     */
    open func taskWithParameters(_ ingredients: [String]?, query: String?, page: Int = 1, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask? {
        
        // Create the url request.
        if let url = SRPuppyAPI.getURLWithParameters(ingredients, query: query, page: page, onlyImages: onlyImages) {
            let request = URLRequest(url: url)
            
            // Create the task.
            let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
                
                // Parse the data if no errors were returned.
                if let error = downloadError {
                    completionHandler(nil, error as NSError)
                } else if let data = data {
                    SRPuppyParser.parseJSON(data, completionHandler: completionHandler)
                } else {
                    completionHandler(nil, nil)
                }
            }) 
            task.resume()
            return task
        } else {
            return nil
        }
    }
    
    /**
     Creates a NSURLSessionDataTask for an image located at a given NSURL.
     - parameter imageURL: The URL of the image in an NSURL object.
     - parameter completionHandler: A completion handler for the asynchroneous data request. The result is provided as an optional NSData object containing the image data and an optional NSError indicating error.
     - returns: The created NSURLSessionDataTask.
     */
    open func taskForImage(_ imageURL: URL, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) ->  Void) -> URLSessionTask {
        
        // Create the url request.
        let request = URLRequest(url: imageURL)
        
        // Create the task.
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(nil, error as NSError?)
            } else {
                completionHandler(data, nil)
            }
        }) 
        
        task.resume()
        
        return task
    }
}
