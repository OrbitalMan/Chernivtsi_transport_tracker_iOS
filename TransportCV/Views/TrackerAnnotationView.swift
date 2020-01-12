//
//  TrackerAnnotationView.swift
//  TransportCV
//
//  Created by Stanislav on 11.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import MapKit

class TrackerAnnotationView: MKAnnotationView {
    
    private var titleContext = 0
    private var locationContext = 1
    
    let arrowView = ArrowView()
    let label = UILabel()
    
    override var annotation: MKAnnotation? {
        willSet {
            removeObservers()
        } didSet {
            addObservers()
            updateData()
        }
    }
    
    var trackerAnnotation: TrackerAnnotation?
    
    // MARK: -
    
    override init(annotation: MKAnnotation?,
                  reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        removeObservers()
    }
    
    private func setup() {
        arrowView.setup()
        addSubview(arrowView)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        label.font = UIFont.systemFont(ofSize: 10)
        label.minimumScaleFactor = 0.2
        addSubview(label)
        frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addObservers()
        updateData()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        arrowView.frame = bounds
        label.frame = bounds.insetBy(dx: 2, dy: 2)
        let arrowTransform = arrowView.transform
        arrowView.transform = .identity
        arrowView.frame = bounds
        arrowView.transform = arrowTransform
    }
    
    func updateData() {
        guard let trackerAnnotation = trackerAnnotation else { return }
        arrowView.update(location: trackerAnnotation.location)
        label.text = trackerAnnotation.title
    }
    
    private func addObservers() {
        trackerAnnotation = annotation as? TrackerAnnotation
        trackerAnnotation?.addObserver(self,
                                       forKeyPath: #keyPath(TrackerAnnotation.title),
                                       context: &titleContext)
        trackerAnnotation?.addObserver(self,
                                       forKeyPath: #keyPath(TrackerAnnotation.location),
                                       context: &locationContext)
    }
    
    private func removeObservers() {
        trackerAnnotation?.removeObserver(self,
                                          forKeyPath: #keyPath(TrackerAnnotation.title))
        trackerAnnotation?.removeObserver(self,
                                          forKeyPath: #keyPath(TrackerAnnotation.location))
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        switch context {
        case &titleContext:
            label.text = trackerAnnotation?.title
        case &locationContext:
            arrowView.update(location: trackerAnnotation?.location)
        default:
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }
    
}

class ArrowView: UIView {
    
    let arrow = UIView()
    let circle = UIView()
    
    fileprivate func setup() {
        let borderColor = UIColor.red
        layer.masksToBounds = false
        circle.backgroundColor = .yellow
        circle.layer.borderColor = borderColor.cgColor
        circle.layer.borderWidth = 1
        arrow.backgroundColor = borderColor
        addSubview(arrow)
        addSubview(circle)
    }
    
    func update(location: CLLocation?) {
        guard let location = location else { return }
        let course = location.course
        let speed = location.speed
        
        let angle = course * .pi / 180
        
        let height = arrow.bounds.height
        let maxSpeed: CGFloat = 70
        var offset: CGFloat = 0
        if speed >= 1 {
            offset = min(CGFloat(speed)/(maxSpeed/height), height) + circle.layer.borderWidth
        } else if course != 0 {
            offset = 1 + circle.layer.borderWidth
        } else {
            offset = 0
        }
        
        rotate(angle: CGFloat(angle), yOffset: -offset)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        if let boundsAnimation = layer.animation(forKey: "bounds.size") {
            CATransaction.setAnimationDuration(boundsAnimation.duration)
            CATransaction.setAnimationTimingFunction(boundsAnimation.timingFunction)
        } else {
            CATransaction.disableActions()
        }
        
        let arrowTransform = arrow.transform
        arrow.transform = .identity
        arrow.frame = CGRect(x: bounds.width/2-1, y: 0, width: 4, height: 20)
        arrow.transform = arrowTransform
        
        circle.frame = bounds
        circle.layer.cornerRadius = bounds.width/2
        CATransaction.commit()
    }
    
    func rotate(angle: CGFloat, yOffset: CGFloat) {
        transform = CGAffineTransform(rotationAngle: angle)
        arrow.transform = CGAffineTransform(translationX: 0, y: yOffset)
    }
    
}

