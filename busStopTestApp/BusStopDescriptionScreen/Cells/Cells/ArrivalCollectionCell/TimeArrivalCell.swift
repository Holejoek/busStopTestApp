//
//  TimeArrivalCell.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 26.02.2022.
//

import UIKit

class TimeArrivalCell: UICollectionViewCell {
static let identifier = "TimeArrivalCell"
  
    @IBOutlet weak var rectangleView: UIView!
    @IBOutlet weak var pathNumberLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    
    func configureCell(with model: BusStopDescriptionModel, for indexPath: IndexPath) {
        // есть возможность настроить цвет прямоугольна под определенные нужды
        rectangleView.backgroundColor = .systemBlue
        rectangleView.layer.cornerRadius = 5
        
        let routeModel = model.routePath[indexPath.row]
        
        let arrivalTime = routeModel.timeArrival.first?.replacingOccurrences(of: " мин", with: "m")
        let routeName = routeModel.number
    
        pathNumberLabel.text = routeName
        arrivalTimeLabel.text = arrivalTime
        
        
        if let arrivalTime = arrivalTime {
            var arrivalTimetoInt = arrivalTime.replacingOccurrences(of: "m", with: "")
            arrivalTimetoInt = arrivalTimetoInt.replacingOccurrences(of: "<", with: "")
            guard let intTime = Int(arrivalTimetoInt) else { return }
            
            if intTime < 6 {
                arrivalTimeLabel.textColor = .systemGreen
            } else if intTime > 5, intTime < 15 {
                arrivalTimeLabel.textColor = .systemOrange
            } else if intTime > 16 {
                arrivalTimeLabel.textColor = .systemRed
            }
        }
    }
}
