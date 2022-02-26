//
//  BusStopTableViewCell.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 25.02.2022.
//

import UIKit

protocol BusStopCellProtocol {
    func configure(with model: BusStopMainInfoModel)
}

final class BusStopTableViewCell: UITableViewCell {
    static let identifier = "BusStopTableViewCell"

    @IBOutlet weak var busStopName: UILabel!
    @IBOutlet weak var busStopType: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

extension BusStopTableViewCell: BusStopCellProtocol {
    func configure(with model: BusStopMainInfoModel) {
        busStopName.text = model.name
        busStopType.text = model.russianLgType
    }
}
