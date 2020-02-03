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
    
    let vehicleTypeSelector: UISegmentedControl = {
        let items = VehicleType.allCases.map { $0.segmentedControlTitle }
        return UISegmentedControl(items: items)
    }()
    
    var selectedVehicleType: VehicleType = .trolley
    
    var cellSelections: [RouteSelection] {
        switch selectedVehicleType {
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
        vehicleTypeSelector.selectedSegmentIndex = selectedVehicleType.rawValue
        vehicleTypeSelector.addTarget(self,
                                      action: #selector(didSelectVehicleType),
                                      for: .valueChanged)
        let checkedRoutes = Storage.checkedRoutes
        for route in RouteStore.shared.routes {
            let selection = RouteSelection(routeKey: route.key)
            selection.isChecked = checkedRoutes[route.key] ?? true
            switch route.key.type {
            case .trolley:
                trolleySelections.append(selection)
            case .bus:
                busSelections.append(selection)
            }
        }
        trolleySelections.sort {
            $0.routeKey < $1.routeKey
        }
        busSelections.sort {
            $0.routeKey < $1.routeKey
        }
        
        navigationItem.titleView = vehicleTypeSelector
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Check",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(checkAll))
        updateCheckAllButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        recordSelections()
    }
    
    @objc func didSelectVehicleType() {
        selectedVehicleType = VehicleType(rawValue: vehicleTypeSelector.selectedSegmentIndex) ?? .trolley
        tableView.reloadData()
        updateCheckAllButton()
    }
    
    @objc func checkAll() {
        let selected = !anyChecked
        for selection in cellSelections {
            selection.isChecked = selected
        }
        tableView.reloadData()
        updateCheckAllButton()
    }
    
    func updateCheckAllButton() {
        let image: UIImage?
        let imageSystemName: String
        let title: String
        if anyChecked {
            title = "✅"
            imageSystemName = "checkmark.circle.fill"
        } else {
            title = "❎"
            imageSystemName = "checkmark.circle"
        }
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: imageSystemName)
        } else {
            image = nil
        }
        navigationItem.rightBarButtonItem?.title = title
        navigationItem.rightBarButtonItem?.image = image
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
        updateCheckAllButton()
    }
    
}
