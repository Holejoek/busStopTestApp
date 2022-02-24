//
//  NetworkService.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 24.02.2022.
//

import Foundation


protocol NetworkServiceProtocol {
    func getBusStops(completion: @escaping (Result<[BusStopMaimInfoModel], Error>) -> Void)
    func getBusStopDescription(busStopId: String, completion:  @escaping (Result<BusStopDescriptionModel, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    let stringAPIPath = "https://api.mosgorpass.ru/v8.2/stop"
    
    func getBusStopDescription(busStopId: String, completion: @escaping (Result<BusStopDescriptionModel, Error>) -> Void) {
        let stringURL = stringAPIPath + "/\(busStopId)"
    }
    
    func getBusStops(completion: @escaping (Result<[BusStopMaimInfoModel], Error>) -> Void) {
        
    }
}
