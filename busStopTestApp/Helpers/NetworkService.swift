//
//  NetworkService.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 24.02.2022.
//

import Foundation


protocol NetworkServiceProtocol {
    func getBusStops(completion: @escaping (Result<BusStopList, Error>) -> Void)
    func getBusStopDescription(busStopId: String, completion:  @escaping (Result<BusStopDescriptionModel, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    let stringAPIPath = "https://api.mosgorpass.ru/v8.2/stop"
    
    func getBusStopDescription(busStopId: String, completion: @escaping (Result<BusStopDescriptionModel, Error>) -> Void) {
        let stringURL = stringAPIPath + "/\(busStopId)"
    }
    
    func getBusStops(completion: @escaping (Result<BusStopList, Error>) -> Void) {
        guard let url = URL(string: stringAPIPath) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            do {
                let obj = try JSONDecoder().decode(BusStopList.self, from: data!)
                completion(.success((obj)))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
