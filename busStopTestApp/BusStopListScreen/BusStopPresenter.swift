//
//  BusStopPresenter.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 25.02.2022.
//

import Foundation
import UIKit

protocol BusStopPresenterProtocol: AnyObject {
    init(view: BusStopViewControllerProtocol, networkService: NetworkServiceProtocol, delegate: BusStopPresenterDelegate?)
    
    func notifyThatViewDidLoad()
    
    func getNumberOfRows() -> Int
    func getHeightForRowAt(_ indexPath: IndexPath) -> Double
    func getModelForCellAt(_ indexPath: IndexPath) -> BusStopMainInfoModel
    
    func didSelectedRowAt(indexPath: IndexPath)
}

protocol BusStopPresenterDelegate: AnyObject {
    func didPickBusStop(_ busStop: BusStopMainInfoModel)
}

final class BusStopPresenter: BusStopPresenterProtocol {
    
    weak var view: BusStopViewControllerProtocol!
    let networkService: NetworkServiceProtocol!
    
    weak var delegate: BusStopPresenterDelegate?
    
    var busStopList = [BusStopMainInfoModel]()
    
    required init(view: BusStopViewControllerProtocol, networkService: NetworkServiceProtocol, delegate: BusStopPresenterDelegate?) {
        self.view = view
        self.networkService = networkService
        self.delegate = delegate
    }
    
    func notifyThatViewDidLoad() {
        networkService.getBusStops { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let list):
                strongSelf.busStopList = list.data
                strongSelf.view.updateCells()
            case .failure(let error):
                strongSelf.view.showError(with: error, orSomeErrorText: nil)
            }
        }
    }
    
    func getNumberOfRows() -> Int {
        return busStopList.count
    }
    
    func getHeightForRowAt(_ indexPath: IndexPath) -> Double {
        return 70
    }
    
    func getModelForCellAt(_ indexPath: IndexPath) -> BusStopMainInfoModel {
        let model = busStopList[indexPath.row]
        return model
    }
    
    func didSelectedRowAt(indexPath: IndexPath) {
        let busStop = busStopList[indexPath.row]
        delegate?.didPickBusStop(busStop)
    }
}
