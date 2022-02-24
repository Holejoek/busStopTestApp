//
//  ModuleBuilder.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 24.02.2022.
//

import Foundation
import UIKit

protocol ModuleBuilderProtocol {
    static func createBusStopController() -> UIViewController
    static func createMapViewController(inputData: BusStopMaimInfoModel) -> UIViewController
}

class ModuleBuilder {
    static func createMainMenuModule() -> UIViewController {
        let networkService = NetworkService()
        
        let view: BusStopViewControllerProtocol = BusStopViewController()
        let presenter: BusStopPresenterProtocol = BusStopPresenter(view: view)
        
        
        view.presenter = presenter
        
        presenter.networkService = networkService
        
        
        return (view as? UIViewController) ?? UIViewController()
    }
    static func createNextScreenExample(inputData: Any?) -> UIViewController {
        return UIViewController()
    }
}


