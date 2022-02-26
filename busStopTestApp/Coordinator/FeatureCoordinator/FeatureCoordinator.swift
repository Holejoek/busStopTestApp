//
//  ConcreteCoordinator.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 25.02.2022.
//

import UIKit


class FeatureCoordinator: Coordinator {

    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    func start() {
        showFirstScene()
    }
}

extension FeatureCoordinator {
    func showFirstScene() {
        let scene = FeatureSceneFactory.makeFirstScene(delegate: self) 
        navigationController.viewControllers = [scene]
        
    }
    
    func showSecondScene(busStop: BusStopMainInfoModel) {
        let scene = FeatureSceneFactory.makeSecondScene(busStop: busStop)
        navigationController.pushViewController(scene, animated: true)
    }
}

extension FeatureCoordinator: BusStopPresenterDelegate {
    func didPickBusStop(_ busStop: BusStopMainInfoModel) {
        showSecondScene(busStop: busStop)
    }
}
