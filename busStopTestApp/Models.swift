//
//  Models.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 24.02.2022.
//

import Foundation


// MARK: - BusStopMaimInfo
struct BusStopList: Codable {
    let data: [BusStopMainInfoModel]
}

struct BusStopMainInfoModel: Codable {
    let id: String
    let lat, lon: Double
    let name: String
    let type: TypeElement
    let routeNumber, color, routeName, subwayID: String?
    let wifi, usb: Bool
    let transportTypes: [TypeElement]
    let isFavorite: Bool
    let mapIcon: String?
    let cityShuttle, electrobus: Bool
    
    var russianLgType: String {
        switch type {
        case .bus:
            return "Автобус"
        case .mcd:
            return "МЦК"
        case .publicTransport:
            return "Общественный транспорт"
        case .subwayHall:
            return "Метро"
        case .train:
            return "Автобус"
        case .tram:
            return "Тролейбус"
        }
    }
    
}

enum TypeElement: String, Codable {
    case bus = "bus"
    case mcd = "mcd"
    case publicTransport = "public_transport"
    case subwayHall = "subwayHall"
    case train = "train"
    case tram = "tram"
}


// MARK: - BusStopDescriptionModel
struct BusStopDescriptionModel: Codable {
    let id, name, type: String
    let wifi: Bool
    let commentTotalCount: Int
    let routePath: [RouteModel]
    let color, routeNumber: String
    let isFavorite: Bool
    let lat, lon: Double
    let cityShuttle, electrobus: Bool
    let transportTypes: [String]
    let regional: Bool
}

// MARK: - RoutePath
struct RouteModel: Codable {
    let id, type, number: String
    let timeArrivalSecond: [Int]
    let timeArrival: [String]
    let lastStopName: String
    let isFifa, weight, byTelemetry: Int
    let color, fontColor: String
    let cityShuttle, electrobus: Bool
    let byTelemetryArray: [Int]
    let sberShuttle, isFavorite: Bool
}

