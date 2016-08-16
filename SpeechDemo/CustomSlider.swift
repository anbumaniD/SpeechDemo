//
//  CustomSlider.swift
//  SpeechDemo
//
//  Created by Anbumani on 27/07/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
   
    var sliderIdentifier: Int!
    
    convenience init() {
        
        self.init()
        
        sliderIdentifier = 0
        
    }
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    
    
    
    
}
