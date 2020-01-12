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
    
    let pointer = PointerView()
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
        addSubview(pointer)
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
        label.frame = bounds.insetBy(dx: 2, dy: 2)
        let pointerTransform = pointer.transform
        pointer.transform = .identity
        pointer.frame = bounds
        pointer.transform = pointerTransform
    }
    
    func updateData() {
        guard let trackerAnnotation = trackerAnnotation else { return }
        pointer.update(location: trackerAnnotation.location)
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
            pointer.update(location: trackerAnnotation?.location)
        default:
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }
    
}
