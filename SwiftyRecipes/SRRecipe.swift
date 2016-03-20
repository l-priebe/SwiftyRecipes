//
//  SRRecipe.swift
//  Swifty Recipes
//
//  Created by Lasse Hammer Priebe on 12/02/16.
//  Copyright © 2016 Lasse Hammer Priebe. All rights reserved.
//

import UIKit

public class SRRecipe: NSObject, NSCoding {
    
    // MARK: Properties
    
    public let title: String!
    public let ingredients: String!
    public let url: NSURL!
    public let thumbnailUrl: NSURL?
    
    public var thumbnailImage: UIImage? {
        get {
            return SRPuppyClient.sharedClient().imageCache.imageWithIdentifier(thumbnailUrl?.path)
        }
        set {
            if let thumbnailPath = thumbnailUrl?.path {
                SRPuppyClient.sharedClient().imageCache.storeImage(newValue, withIdentifier: thumbnailPath)
            }
        }
    }
    
    private struct CodingKeys {
        static let Title = "title"
        static let Href = "href"
        static let Ingredients = "ingredients"
        static let Thumbnail = "thumbnail"
    }
    
    // MARK: Life Cycle
    
    public init(title: String, ingredients: String, url: NSURL, thumbnailUrl: NSURL?) {
        self.title = title
        self.ingredients = ingredients
        self.url = url
        self.thumbnailUrl = thumbnailUrl
    }
    
    // MARK: NSCoding Protocol
    
    @objc public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: CodingKeys.Title)
        aCoder.encodeObject(url, forKey: CodingKeys.Href)
        aCoder.encodeObject(ingredients, forKey: CodingKeys.Ingredients)
        aCoder.encodeObject(thumbnailUrl, forKey: CodingKeys.Thumbnail)
    }
    
    @objc public required init?(coder aDecoder: NSCoder) {  
        title = aDecoder.decodeObjectForKey(CodingKeys.Title) as! String
        ingredients = aDecoder.decodeObjectForKey(CodingKeys.Ingredients) as! String
        url = aDecoder.decodeObjectForKey(CodingKeys.Href) as! NSURL
        thumbnailUrl = aDecoder.decodeObjectForKey(CodingKeys.Thumbnail) as! NSURL?
    }
    
    // MARK: - CustomStringConvertible Protocol
    override public var description: String {
        get {
            return "Recipe: \(title).\nIngredients: \(ingredients)"
        }
    }
}