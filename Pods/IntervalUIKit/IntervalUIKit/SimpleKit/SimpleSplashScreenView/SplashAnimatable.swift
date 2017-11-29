//
//  Animatable.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/13/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import Foundation
import UIKit

/**
 *  Protocol that represents splash animatable functionality
 */
public protocol SplashAnimatable: class {
    
    /// The image view that shows the icon
    var imageView: UIImageView? { get set }
    
    /// The animation type
    var animationType: SplashAnimationType { get set }
    
    /// The duration of the overall animation
    var duration: Double { get set }
    
    /// The delay to play the animation
    var delay: Double { get set }
    
    /// The trigger to stop heartBeat animation
    var heartAttack: Bool { get set }
    
    /// The minimum number of beats before removing the splash view
    var minimumBeats: Int { get set }
}
