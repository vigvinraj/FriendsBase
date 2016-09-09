//
//  DesignBtn.swift
//  FriendsBase
//
//  Created by Vignesh Kumar on 9/9/16.
//  Copyright © 2016 Vignesh Kumar. All rights reserved.
//

import UIKit

class DesignBtn: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.shadowColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.6).cgColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.cornerRadius = 5.0
        
    }

}
