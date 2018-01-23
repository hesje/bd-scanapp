//
//  API.swift
//  bd-scanapp
//
//  Created by Hessel Bierma on 21/12/2017.
//  Copyright © 2017 Bedrijvendagen Twente. All rights reserved.
//

import SystemConfiguration
import UIKit

public class Reachability {
    
    //function to check internet connection status
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

public class API {
    
    //class to pass persons credentials between viewcontrollers
    class QRparameters{
        var fname = String()
        var lname = String()
        var email = String()
        var uid = Int()
        var comment = String()
    }
    
    
    //Decoder format for the received JSON data from the API
    struct loginItem : Decodable{
        let _csrf : String
        let id : Int
        let auth : Bool
        let email : String
        let company_name : String
    }
    
    //check if the token is stil valid
    func AuthCheck(vc: UIViewController) {
        let url = URL(string: "https://www.bedrijvendagentwente.nl/auth/api/accounts/session")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XmlHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("{\(authToken)}", forHTTPHeaderField: "X-Csrf-Token")
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            let string1 = String(data: data!, encoding: String.Encoding.utf8) ?? "Data could not be printed"
            print(string1)
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print(httpStatus.statusCode)
                DispatchQueue.main.async {
                    self.renewAuth(view: vc) //if the token is not valid anymore request a new token
                    print("Auth false")
                }
            }else{
                print("HTTP 200 OK")
            }
        }
        task.resume()
    }
    
    //request a new token by logging in again
    func renewAuth(view: UIViewController) {
        let url = URL(string: "https://www.bedrijvendagentwente.nl/auth/api/accounts/session")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XmlHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.httpMethod = "POST"
        let parameters = ["email":"\(username)","password":"\(passHash)"]
        guard let logindata = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return }
        request.httpBody = logindata
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("HTTP Error")
                DispatchQueue.main.async {
                    view.performSegue(withIdentifier: "toLogIn", sender: nil)
                }
            } else{
                do{
                    let User = try JSONDecoder().decode(API.loginItem.self, from: data)
                    companyName = User.company_name
                    authToken = User._csrf
                    print("Auth renewed")
                    print(authToken)
                }catch{
                    print("error in serialization")
                }
            }
        }
        task.resume()
    }
    
}
