//
//  PointerView.swift
//  TransportCV
//
//  Created by Stanislav on 13.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import UIKit
import CoreLocation

class PointerView: UIView {
    
    let arrow = ArrowView()
    let circle = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        let borderColor = UIColor.red
        layer.masksToBounds = false
        arrow.shape.fillColor = borderColor.cgColor
        addSubview(arrow)
        circle.backgroundColor = .yellow
        circle.layer.borderColor = borderColor.cgColor
        circle.layer.borderWidth = 1
        addSubview(circle)
    }
    
    func update(location: CLLocation?) {
        guard let location = location else { return }
        let course = location.course
        let speed = location.speed
        
        let angle = course * .pi / 180
        
        let maxOffset = arrow.bounds.height * 0.89
        let minOffset = arrow.bounds.height * 0.3
        let maxSpeed: CGFloat = 60
        var offset: CGFloat = 0
        if speed >= 1 {
            offset = minOffset + CGFloat(speed)/(maxSpeed/(maxOffset-minOffset))
            offset = min(max(minOffset, offset), maxOffset)
        } else if course != 0 {
            offset = minOffset
        }
        rotate(angle: CGFloat(angle), yOffset: -offset)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        let arrowTransform = arrow.transform
        arrow.transform = .identity
        let arrowWidth = bounds.width * 0.6
        let arrowHeight = bounds.height * 0.9
        arrow.frame = CGRect(x: (bounds.width-arrowWidth)/2, y: 0,
                             width: arrowWidth, height: arrowHeight)
        arrow.transform = arrowTransform
        
        circle.frame = bounds
        circle.layer.cornerRadius = bounds.width/2
    }
    
    func rotate(angle: CGFloat, yOffset: CGFloat) {
        transform = CGAffineTransform(rotationAngle: angle)
        arrow.transform = CGAffineTransform(translationX: 0, y: yOffset)
    }
    
}

class ArrowView: UIView {
    
    let shape = TriangleShape()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.addSublayer(shape)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        if let boundsAnimation = layer.animation(forKey: "bounds.size") {
            CATransaction.setAnimationDuration(boundsAnimation.duration)
            CATransaction.setAnimationTimingFunction(boundsAnimation.timingFunction)
            let pathAnimation = CABasicAnimation(keyPath: "path")
            shape.add(pathAnimation, forKey: "path")
        } else {
            CATransaction.disableActions()
        }
        shape.drawPath(in: bounds)
        CATransaction.commit()
    }
    
}


class TriangleShape: CAShapeLayer {
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        setup()
    }
    
    fileprivate func setup() {
        contentsScale = UIScreen.main.scale
        fillColor = UIColor.red.cgColor
        strokeColor = nil
        lineWidth = 0
    }
    
    func drawPath(in rect: CGRect) {
        let triangleBzPath = UIBezierPath()
        triangleBzPath.move(to: CGPoint(x: rect.width/2, y: 0))
        triangleBzPath.addLine(to: CGPoint(x: rect.width, y: rect.height))
        triangleBzPath.addLine(to: CGPoint(x: 0, y: rect.height))
        triangleBzPath.close()
        frame = rect
        path = triangleBzPath.cgPath
    }
    
}
