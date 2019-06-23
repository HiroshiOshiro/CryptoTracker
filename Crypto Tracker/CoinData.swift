//
//  CoinData.swift
//  Crypto Tracker
//
//  Created by hiroshi on 2018/07/28.
//  Copyright © 2018 hiroshi. All rights reserved.
//

import UIKit
import Alamofire

class CoinData {
    static let shared = CoinData()
    var coins = [Coin]()
    weak var delegate: CoinDataDelegate?
    
    private init() {
        let symbols = ["BTC", "ETH", "LTC"]
        
        for symbol in symbols {
            let coin = Coin(symbol: symbol)
            coins.append(coin)
        }
    }
    
    func html() -> String {
        var html = "<h1>My Crypto Report</h1>"
        html += "<h2>Net Worth: \(netWorthAsString())</h2>"
        html += "<u1>"
        for coin in coins {
            if coin.amount != 0.0 {
                html += "<li>\(coin.symbol) - I own: \(coin.amount) - Valued at: \(doubleToMoneyString(double: coin.amount * coin.price))</li>"
            }
        }
        
        html += "</ul>"
        
        return html
    }
    
    func netWorthAsString() -> String {
        var netWorth = 0.0
        for coin in coins {
            netWorth += coin.amount * coin.price
        }
        return doubleToMoneyString(double: netWorth)
    }
    
    func getPrice() {
        var listOfSymboles = ""
        for coin in coins {
            listOfSymboles += coin.symbol
            if coin.symbol != coins.last?.symbol {
                listOfSymboles += ","
            }
        }
        
        Alamofire.request("https://min-api.cryptocompare.com/data/pricemulti?fsyms=\(listOfSymboles)&tsyms=USD").responseJSON {
            (response) in
            // print(response.result.value)
            if let json = response.result.value as? [String: Any] {
                for coin in self.coins {
                    if let coinJson = json[coin.symbol] as? [String: Double] {
                        if let price = coinJson["USD"] {
                            coin.price = price
                            UserDefaults.standard.set(price, forKey: coin.symbol)
                        }
                    }
                }
                self.delegate?.newPrices?()
            }
        }
    }
    
    func doubleToMoneyString(double: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .currency
        
        if let fancyPrice = formatter.string(from: NSNumber(floatLiteral: double)) {
            return fancyPrice
        } else {
            return "ERROR"
        }
    }
}

@objc protocol CoinDataDelegate: class {
    @objc optional func newPrices()
    @objc optional func newHistory()
}

class Coin  {
    var symbol = ""
    var image = UIImage()
    var price = 0.0
    var amount = 0.0
    var historicalDate = [Double]()
    
    init(symbol: String) {
        self.symbol = symbol
        if let image = UIImage(named: symbol) {
            self.image = image
        }
        self.price = UserDefaults.standard.double(forKey: symbol)
        self.amount = UserDefaults.standard.double(forKey: symbol + "amount")
        if let history = UserDefaults.standard.array(forKey: symbol + "history") as? [Double]  {
            self.historicalDate = history
        }
    }
    
    func getHistricalDate() {
        Alamofire.request("https://min-api.cryptocompare.com/data/histoday?fsym=\(symbol)&tsym=USD&limit=30").responseJSON {
            (response) in
            
            
            if let json = response.result.value as? [String: Any] {
                if let pricesJSON = json["Data"] as?
                    [[String:Double]] {
                    self.historicalDate = []
                    for priceJSON in pricesJSON {
                        if let closePrice = priceJSON["close"] {
                            self.historicalDate.append(closePrice)
                        }
                    }
                    CoinData.shared.delegate?.newHistory?()
                    UserDefaults.standard.set(self.historicalDate, forKey: self.symbol + "history")
                }
            }
        }
    }
    
    func priceAsString() -> String {
        if price == 0.0 {
            return "Loading..."
        }
        
        return CoinData.shared.doubleToMoneyString(double: price)        
    }
    
    func amountAsString() -> String {
        return CoinData.shared.doubleToMoneyString(double: amount * price)
    }
}
