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

public class SRImageCache {
    
    private var inMemoryCache = NSCache()
    
    // MARK: - Clear Cache
    
    public func clear() {
        inMemoryCache.removeAllObjects()
    }
    
    // MARK: - Retreiving Images
    
    public func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        if identifier != nil && identifier! != "" {
            
            if let path = pathForIdentifier(identifier!) {
                
                // First try the memory cache
                if let image = inMemoryCache.objectForKey(path) as? UIImage {
                    return image
                }
                
                // Next try the hard drive
                if let data = NSData(contentsOfFile: path) {
                    return UIImage(data: data)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Saving Images
    
    public func storeImage(image: UIImage?, withIdentifier identifier: String) {
        
        if let path = pathForIdentifier(identifier) {
            
            // If the image is nil, remove images from the cache
            if image == nil {
                inMemoryCache.removeObjectForKey(path)
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(path)
                } catch _ {}
                
                return
            }
            
            // Otherwise, keep the image in memory
            inMemoryCache.setObject(image!, forKey: path)
            
            // And in documents directory
            let data = UIImagePNGRepresentation(image!)!
            data.writeToFile(path, atomically: true)
        }
    }
    
    // MARK: - Helper
    
    public func pathForIdentifier(identifier: String) -> String? {
        
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path
    }
}