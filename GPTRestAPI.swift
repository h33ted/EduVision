//
//  GPTRestAPI.swift
//  DocScan
//
//  Created by George-Cristian Cotea on 12/05/2023.
//  Copyright © 2023 ImTech. All rights reserved.
//
//This file takes the OCR output and sends it to the server with a  POST request
import Foundation
import UIKit
import Vision

class GPTRestAPI {
    
    static func sendToServer(text: String) {
        let url = URL(string: "debug")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let postString = "text=\(text)"
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            //print("response = \(response)")
            let responseString = String(data: data!, encoding: .utf8)
            print("responseString = \(responseString)")
            //print("error = \(error)")
        }
        task.resume()
    }
}
