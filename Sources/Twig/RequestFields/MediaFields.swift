//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 21/11/21.
//

import Foundation

/// Docs: https://developer.twitter.com/en/docs/twitter-api/data-dictionary/object-model/media
public enum MediaField: String {
    
    static let queryKey = "media.fields"
    
    /// Available when type is video.
    /// Duration in milliseconds of the video.
    case duration_ms = "duration_ms"
    
    /// Height of this content in pixels.
    case height = "height"
    
    /// Width of this content in pixels.
    case width = "width"
    
    /// URL to the static placeholder preview of this content.
    case preview_image_url = "preview_image_url"
    
    /**
     A description of an image to enable and support accessibility.
     Can be up to 1000 characters long.
     Alt text can only be added to images at the moment.
     */
    case alt_text = "alt_text"
    
    /// - Note: Undocumented!
    /// The URL for retrieving the image.
    case url = "url"
    
    /* ignored keys */
    // non_public_metrics
    // organic_metrics
    // promoted_metrics
    // public_metrics
}
