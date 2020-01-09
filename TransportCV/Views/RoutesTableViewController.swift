//
//  RoutesTableViewController.swift
//  TransportCV
//
//  Created by Stanislav on 08.01.2020.
//  Copyright © 2020 OrbitalMan. All rights reserved.
//

import UIKit

class RouteSelection {
    
    let routeKey: RouteKey
    var isChecked = true
    
    init(routeKey: RouteKey) {
        self.routeKey = routeKey
    }
    
}

class RoutesTableViewController: UITableViewController {
    
    var trolleySelections: [RouteSelection] = []
    var busSelections: [RouteSelection] = []
    
    let busTypeSelector = UISegmentedControl(items: ["Trolleys", "Buses"])
    var busType: BusType = .trolley
    
    var cellSelections: [RouteSelection] {
        switch busType {
        case .trolley:
            return trolleySelections
        case .bus:
            return busSelections
        }
    }
    
    var anyChecked: Bool {
        return cellSelections.contains { $0.isChecked }
    }
    
    let reuseIdentifier = "reuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        busTypeSelector.selectedSegmentIndex = busType.segmentIndex
        busTypeSelector.addTarget(self,
                                  action: #selector(selectedBusType),
                                  for: .valueChanged)
        let checkedRoutes = Storage.checkedRoutes
        for routeKey in RouteStore.shared.routes.keys {
            let s = RouteSelection(routeKey: routeKey)
            s.isChecked = checkedRoutes[routeKey] ?? true
            switch routeKey.type {
            case .trolley:
                trolleySelections.append(s)
            case .bus:
                busSelections.append(s)
            }
        }
        trolleySelections.sort {
            $0.routeKey < $1.routeKey
        }
        busSelections.sort {
            $0.routeKey < $1.routeKey
        }
        
        navigationItem.titleView = busTypeSelector
        updateCheckAll()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recordSelections()
    }
    
    @objc func selectedBusType() {
        busType = BusType(segmentIndex: busTypeSelector.selectedSegmentIndex)
        tableView.reloadData()
        updateCheckAll()
    }
    
    @objc func checkAll() {
        let selected = !anyChecked
        for selection in cellSelections {
            selection.isChecked = selected
        }
        tableView.reloadData()
        updateCheckAll()
    }
    
    func updateCheckAll() {
        if #available(iOS 13.0, *) {
            let image: UIImage?
            if anyChecked {
                image = UIImage(systemName: "checkmark.circle.fill")
            } else {
                image = UIImage(systemName: "checkmark.circle")
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: image,
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(checkAll))
        } else {
            let title: String
            if anyChecked {
                title = "Uncheck All"
            } else {
                title = "Check All"
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: title,
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(checkAll))
        }
    }
    
    func recordSelections() {
        var newSelections: [RouteKey: Bool] = [:]
        for s in trolleySelections+busSelections {
            newSelections[s.routeKey] = s.isChecked
        }
        Storage.checkedRoutes = newSelections
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellSelections.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        let model = cellSelections[indexPath.row]
        var letter = model.routeKey.routeLetter ?? ""
        if letter.count > 1, model.routeKey.routeNumber != nil {
            letter = " \(letter)"
        }
        cell.textLabel?.text = "\(model.routeKey.routeNumber?.description ?? "")\(letter)"
        cell.accessoryType = model.isChecked ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellSelections[indexPath.row].isChecked.toggle()
        tableView.reloadData()
        updateCheckAll()
    }
    
}
