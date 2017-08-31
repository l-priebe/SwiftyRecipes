//
//  SRImageCache.swift
//  Swifty Recipes
//
//  Based on ImageCache.swift
//  Created by Jason @ Udacity on 1/31/15.
//
//  Modified by Lasse Hammer Priebe on 12/02/16.
//  - pathForIdentifier()   | signature changed
//  - imageWithIdentifier() | simplified
//  - clear()               | added
//

import UIKit

open class SRImageCache {
    
    fileprivate var inMemoryCache = NSCache<AnyObject, AnyObject>()
    
    // MARK: - Clear Cache
    
    open func clear() {
        inMemoryCache.removeAllObjects()
    }
    
    // MARK: - Retreiving Images
    
    open func imageWithIdentifier(_ identifier: String?) -> UIImage? {
        
        if identifier != nil && identifier! != "" {
            
            if let path = pathForIdentifier(identifier!) {
                
                // First try the memory cache
                if let image = inMemoryCache.object(forKey: path as AnyObject) as? UIImage {
                    return image
                }
                
                // Next try the hard drive
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    return UIImage(data: data)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Saving Images
    
    open func storeImage(_ image: UIImage?, withIdentifier identifier: String) {
        
        if let path = pathForIdentifier(identifier) {
            
            // If the image is nil, remove images from the cache
            if image == nil {
                inMemoryCache.removeObject(forKey: path as AnyObject)
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch _ {}
                
                return
            }
            
            // Otherwise, keep the image in memory
            inMemoryCache.setObject(image!, forKey: path as AnyObject)
            
            // And in documents directory
            let data = UIImagePNGRepresentation(image!)!
            try? data.write(to: URL(fileURLWithPath: path), options: [.atomic])
        }
    }
    
    // MARK: - Helper
    
    open func pathForIdentifier(_ identifier: String) -> String? {
        
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        
        return fullURL.path
    }
}
