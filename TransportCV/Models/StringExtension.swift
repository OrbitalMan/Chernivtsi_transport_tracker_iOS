//
//  StringExtension.swift
//  TransportCV
//
//  Created by Stanislav on 14.02.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import UIKit

extension String {
    
    func image(of size: CGSize) -> UIImage? {
        let textColor: UIColor
        if #available(iOS 13.0, *) {
            textColor = .label
        } else {
            textColor = .black
        }
        return image(of: size,
                     textColor: textColor,
                     backgroundColor: .clear)
    }
    
    func image(of size: CGSize,
               textColor: UIColor,
               backgroundColor: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        backgroundColor.set()
        UIRectFill(rect)
        
        let side = min(size.width, size.height)
        let fontSize: CGFloat
        switch side {
        case ..<30:
            fontSize = side * 0.7
        case 111...:
            fontSize = side * 0.9
        default:
            fontSize = side * 0.9 - 1
        }
        
        (self as AnyObject).draw(in: rect,
                                 withAttributes: [.foregroundColor: textColor,
                                                  .font: UIFont.systemFont(ofSize: fontSize)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UIImageView {
    
    func setImage(from emoji: String,
                  renderingMode: UIImage.RenderingMode = .automatic) {
        image = emoji.image(of: bounds.size)?.withRenderingMode(renderingMode)
    }
    
}

