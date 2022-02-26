//
//  AppCoordinator.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 25.02.2022.
//

import UIKit
import Foundation


protocol Coordinator {
  func start()
}

class AppCoordinator: Coordinator {
    
    private let window: UIWindow
    private let navigationController: UINavigationController
    var starterCoordinator: Coordinator?
    
    init(window: UIWindow = UIWindow(frame: UIScreen.main.bounds),
         navigationController: UINavigationController = UINavigationController()) {
        self.window = window
        self.navigationController = navigationController
        setupWindow()
        setupStarterCoordinator()
    }
    
    func setupWindow() {
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
    }
    
    func setupStarterCoordinator() {
        starterCoordinator = FeatureCoordinator(navigationController: navigationController)
    }
    
    func start() {
        starterCoordinator?.start()
    }
}
