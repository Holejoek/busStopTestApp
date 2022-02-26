//
//  MapViewPresenter.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 25.02.2022.
//

import Foundation
import CoreLocation

protocol MapViewPresenterProtocol {
    init(view: MapViewControllerProtocol, networkService: NetworkServiceProtocol, inputModel: BusStopMainInfoModel?)
    
    func getBusStopLocation() -> CLLocationCoordinate2D
    func notifyThatViewDidLoad()
    func getBusStopInputModelName() -> String
    func getBusStopDescription() -> BusStopDescriptionModel?
    
    func getNumberOfRoutes() -> Int
}

final class MapViewPresenter: MapViewPresenterProtocol {
    
    weak var view: MapViewControllerProtocol!
    let networkService: NetworkServiceProtocol!
    
    let inputModel: BusStopMainInfoModel?
    var busStopDescription: BusStopDescriptionModel?
    
    init(view: MapViewControllerProtocol, networkService: NetworkServiceProtocol, inputModel: BusStopMainInfoModel?) {
        self.view = view
        self.networkService = networkService
        self.inputModel = inputModel
    }
    
    func notifyThatViewDidLoad() {
        if let inputModel = inputModel {
            networkService.getBusStopDescription(busStopId: inputModel.id) { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let description):
                    strongSelf.busStopDescription = description
                    strongSelf.view.updateCollectionView()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func getBusStopLocation() -> CLLocationCoordinate2D {
        guard let inputModel = inputModel else {
            return CLLocationCoordinate2D(latitude: 55.749451, longitude: 37.542824)
        }
        return CLLocationCoordinate2D(latitude: inputModel.lat, longitude: inputModel.lon)
    }
    
    func getBusStopInputModelName() -> String {
        guard let inputModel = inputModel else {
            return ""
        }
        return inputModel.name
    }
    
    func getNumberOfRoutes() -> Int {
        guard let busStopDescription = busStopDescription else {
            return 0
        }
        return busStopDescription.routePath.count
    }
    
    func getBusStopDescription() -> BusStopDescriptionModel? {
        return busStopDescription
    }
}
