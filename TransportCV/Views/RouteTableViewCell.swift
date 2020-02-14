//
//  RouteTableViewCell.swift
//  TransportCV
//
//  Created by Stanislav on 14.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import UIKit

class RouteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var trackersLabel: UILabel!
    @IBOutlet weak var selectionIndicatorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            selectionIndicatorImage.image = UIImage(systemName: "checkmark")
        } else {
            selectionIndicatorImage.setImage(from: "✔️", renderingMode: .alwaysTemplate)
        }
    }
    
}
