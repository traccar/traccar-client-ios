//
//  VehicleTrackerRepository.swift
//  TraccarClient
//
//  Created by Balleng on 2024/11/12.
//  Copyright © 2024 Traccar. All rights reserved.
//

import Foundation

protocol repositoryDelegate {
    func login()
    func sendSOS()
    func clockIn()
    func clockOut()
}

struct VehicleTrackerRepository {
    
    func login() {
        let endpoint = "https://pathfinder.sbmkinetics.co.za/login"
        let params = [
            "email":"balleng@exonic",
            "password":"Regally]Map]Brewery]Commuting7",
            "id": "A80A73DA-3112-47B1-A929-CC0B860E62C2",
            "timestamp": "1731420695",
            "lat":"37.785834",
            "lon":"-122.406417",
            "speed":"0",
            "bearing":"0",
            "altitude":"0",
            "accuracy":"5",
            "batt":"0",
            "charge":"true"
        ]
        let url = createURLFromParameters(parameters: params, pathparam: "")
        
        print("URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        
//        let encodedAuthInfo = String(format: "email=%@&password=%@", "balleng@exonic.co.za", "Regally]Map]Brewery]Commuting7")
//                    .data(using: String.Encoding.utf8)!
//                    .base64EncodedString()
//        urlRequest.addValue("Basic \(encodedAuthInfo)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "POST"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "ERROR ERROR ERROR")
                return
            }
            
            guard let responseData = data else {
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error trying to convert data to JSON")
                    return
                }
                print("Response: \(json)")
            }
            catch (let error) {
                print("Error Message:\(error.localizedDescription)")
                return
            }
        }
        task.resume()
    }
    
    func getDevices() {
        let endpoint = "https://pathfinder.sbmkinetics.co.za/devices"
        let params = [
            "email":"balleng@exonic",
            "password":"Regally]Map]Brewery]Commuting7",
        ]
        let url = createURLFromParameters(parameters: params, pathparam: "")
        
        print("URL: \(url)")
        
        var urlRequest = URLRequest(url: url)
        
//        let encodedAuthInfo = String(format: "email=%@&password=%@", "balleng@exonic.co.za", "Regally]Map]Brewery]Commuting7")
//                    .data(using: String.Encoding.utf8)!
//                    .base64EncodedString()
//        urlRequest.addValue("Basic \(encodedAuthInfo)", forHTTPHeaderField: "Authorization")
        urlRequest.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                print(error?.localizedDescription ?? "ERROR ERROR ERROR")
                return
            }
            
            guard let responseData = data else {
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] else {
                    print("error trying to convert data to JSON")
                    return
                }
                print("Response: \(json)")
            }
            catch (let error) {
                print("Error Message:\(error.localizedDescription)")
                return
            }
        }
        task.resume()
    }
    
    func sendSOS() {
        
    }
    
    func clockIn() {
        
    }
    
    func clockOut() {
        
    }
    
    struct Constants {

        struct APIDetails {
            static let APIScheme = "https"
            static let APIHost = "pathfinder.sbmkinetics.co.za"
            static let APIPath = "/devices"
        }
    }

    private func createURLFromParameters(parameters: [String:Any], pathparam: String?) -> URL {

        var components = URLComponents()
        components.scheme = Constants.APIDetails.APIScheme
        components.host   = Constants.APIDetails.APIHost
        components.path   = Constants.APIDetails.APIPath
        if let paramPath = pathparam {
            components.path = Constants.APIDetails.APIPath + "\(paramPath)"
        }
        if !parameters.isEmpty {
            components.queryItems = [URLQueryItem]()
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }

        return components.url!
    }
}
