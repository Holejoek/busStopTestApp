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
}

final class MapViewPresenter: MapViewPresenterProtocol {
    
    weak var view: MapViewControllerProtocol!
    let networkService: NetworkServiceProtocol!
    
    let inputModel: BusStopMainInfoModel?
    
    init(view: MapViewControllerProtocol, networkService: NetworkServiceProtocol, inputModel: BusStopMainInfoModel?) {
        self.view = view
        self.networkService = networkService
        self.inputModel = inputModel
    }
    
    func notifyThatViewDidLoad() {
        if let inputModel = inputModel {
            networkService.getBusStopDescription(busStopId: inputModel.id) { result in
                switch result {
                case .success(let description):
                    return
                case .failure(let error):
                    return
                }
            }
        }
    }
    
    func getBusStopLocation() -> CLLocationCoordinate2D {
        guard let inputModel = inputModel else {
            
            /// Центр Москвы
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
    
}
