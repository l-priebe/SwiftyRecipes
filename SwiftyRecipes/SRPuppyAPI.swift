//
//  SRPuppyAPI.swift
//  Swifty Recipes
//
//  Created by Lasse Hammer Priebe on 12/02/16.
//  Copyright © 2016 Hundredeni. All rights reserved.
//

import Foundation

open class SRPuppyAPI {
    
    // MARK: Properties
    
    /// Recipe Puppy API and optional parameters. See http://www.recipepuppy.com/about/api/
    fileprivate struct API {
        static let BasePath: String = "http://www.recipepuppy.com/api/?"
        struct Keys {
            static let Ingredients = "i"
            static let Query = "q"
            static let Page = "p"
            static let Images = "onlyImages"
        }
    }
    
    // MARK: Class Methods
    
    /**
     Creates a NSURL for the Recipe Puppy API given a set of parameters.
     - parameter ingredients: An optional array of ingredient names represented by a [String].
     - parameter query: An optional search query represented by a String.
     - parameter page: An Int representing the page number of the request. The Recipe Puppy API returns at most 10 items per page.
     - parameter onlyImages: A Bool determining whether recipes with no thumbnail should be excluded from the API request.
     - returns: The created NSURL if the parameters are appropriate, otherwise nil is returned and an error message is printed to the console.
     */
    class func getURLWithParameters(_ ingredients: [String]?, query: String?, page: Int = 1, onlyImages: Int = 0) -> URL? {
        
        var urlPath = API.BasePath
        
        // Add ingredients parameter and ingredients to the path.
        if let ingredients = ingredients, ingredients.count > 0 {
            
            urlPath += "\(API.Keys.Ingredients)="
            
            for ingredient in ingredients {
                
                // Encode ingredient with URL query allowed character set.
                if let encodedIngredient = ingredient.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                    
                    urlPath += encodedIngredient
                    
                    // Seperate by ingredients by commas.
                    if ingredient != ingredients.last {
                        urlPath += ","
                    }
                    
                } else {
                    print("Error in SRPuppyAPI.getURLWithParameters: Ingredients could not be encoded.")
                    return nil
                }
            }
        }
        
        // Add the normal search query to the path.
        if let encodedQuery = query?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            urlPath += "&\(API.Keys.Query)=\(encodedQuery)"
        } else if query != nil {
            print("Error in SRPuppyAPI.getURLWithParameters: Query could not be encoded.")
            return nil
        }
        
        // Add the page parameter to the url and make sure it is valid.
        if page > 0 {
            urlPath += "&\(API.Keys.Page)=\(page)"
        } else {
            print("Error in SRPuppyAPI.getURLWithParameters: Invalid page number (must be > 0).")
            return nil
        }
        
        // Add images parameter to the url and make sure it is valid.
        if onlyImages == 1 || onlyImages == 0 {
            urlPath += "&\(API.Keys.Images)=\(onlyImages)"
        } else {
            print("Error in SRPuppyAPI.getURLWithParameters: Invalid onlyImages parameter (must be either 1 or 0).")
            return nil
        }
        
        return URL(string: urlPath)
    }
}
