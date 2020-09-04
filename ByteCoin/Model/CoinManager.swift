//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Maria Yelfimova on 9/4/20.
//  Copyright © 2020 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoinRate(_ coinManager: CoinManager, rate: String)
    func didFailWithEror(error: Error?)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "bla-472D-42CC-B468-9A35E620AE4B"
    var delegate: CoinManagerDelegate?
    
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let finalUrl = baseURL+"/\(currency)?apikey="+apiKey
        self.performRequest(with: finalUrl)
    }
    
    func performRequest (with urlString: String) {
        // create URL
        if let url = URL(string: urlString) {
            // create URL session
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithEror(error: error)
                    return
                }
                
                if let safeData = data {
                    let parsedRate = self.parseJSON(coinData: safeData)
                    self.delegate?.didUpdateCoinRate(self, rate: parsedRate!)
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(coinData: Data) -> String? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let rate = decodedData.rate
            return String(format: "%.2f", rate)
        }
        catch {
            self.delegate?.didFailWithEror(error: error)
        }
        return nil
    }
}
