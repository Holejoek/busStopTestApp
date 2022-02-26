//
//  FeatureSceneFatory.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 25.02.2022.
//

import Foundation
import UIKit

struct FeatureSceneFactory {
    static func makeFirstScene(delegate: BusStopPresenterDelegate?) -> BusStopViewController {
        let networkService = NetworkService()
        
        let viewController = BusStopViewController()
        let presenter: BusStopPresenterProtocol = BusStopPresenter(view: viewController, networkService: networkService, delegate: delegate)

        viewController.presenter = presenter
        
        return viewController
    }
    
    static func makeSecondScene(busStop: BusStopMainInfoModel) -> MapViewController {
        let networkService = NetworkService()
        
        let viewController = MapViewController()
        let presenter = MapViewPresenter(view: viewController, networkService: networkService, inputModel: busStop)
        
        viewController.presenter = presenter
        
        return viewController
    }
}
