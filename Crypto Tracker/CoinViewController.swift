//
//  CoinViewController.swift
//  Crypto Tracker
//
//  Created by hiroshi on 2018/07/30.
//  Copyright © 2018 hiroshi. All rights reserved.
//

import UIKit
import SwiftChart

private let chartHight: CGFloat = 300.0
private let imageSize: CGFloat = 100.0
private let priceLabelHight: CGFloat = 25.0

class CoinViewController: UIViewController, CoinDataDelegate {
    
    var coin: Coin?
    var chart = Chart()
    var priceLabal = UILabel()
    var youOwnLabal = UILabel()
    var worthLabal = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let coin = coin {
            CoinData.shared.delegate = self
            
            edgesForExtendedLayout = []
            view.backgroundColor = UIColor.white
            title = coin.symbol
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
            
            chart.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: chartHight)
            chart.yLabelsFormatter = { CoinData.shared.doubleToMoneyString(double: $1) }
            chart.xLabels = [0,5,10,15,20,25,30]
            chart.xLabelsFormatter = { String(Int(round(30 - $1))) + "d" }
            
            view.addSubview(chart)
            
            let imageView = UIImageView(frame: CGRect(x: view.frame.size.width / 2 - imageSize / 2, y: chartHight, width: imageSize, height: imageSize))
            imageView.image = coin.image
            view.addSubview(imageView)
            
            priceLabal.frame = CGRect(x: 0, y: chartHight + imageSize, width: view.frame.size.width, height: priceLabelHight)
            //            priceLabal.text = coin.priceAsString()
            priceLabal.textAlignment = .center
            view.addSubview(priceLabal)
            
            youOwnLabal.frame = CGRect(x: 0, y: chartHight + imageSize + priceLabelHight * 2, width: view.frame.size.width, height: priceLabelHight)
            youOwnLabal.textAlignment = .center
            youOwnLabal.font = UIFont.boldSystemFont(ofSize: 20.0)
            //            youOwnLabal.text = "You own: \(coin.amount) \(coin.symbol)"
            view.addSubview(youOwnLabal)
            
            worthLabal.frame = CGRect(x: 0, y: chartHight + imageSize + priceLabelHight * 3, width: view.frame.size.width, height: priceLabelHight)
            worthLabal.textAlignment = .center
            worthLabal.font = UIFont.boldSystemFont(ofSize: 20.0)
            //            worthLabal.text = coin.amountAsString()
            view.addSubview(worthLabal)
            
            
            coin.getHistricalDate()
            newPrices()
        }
    }
    
    @objc func editTapped() {
        if let coin = coin {
            let alert = UIAlertController(title: "How much \(coin.symbol) do you own?", message: nil, preferredStyle: .alert)
            alert.addTextField {
                (textField) in
                textField.placeholder = "0.5"
                textField.keyboardType = .decimalPad
                
                if coin.amount != 0.0 {
                    textField.text = String(coin.amount)
                }
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action) in
                if let text = alert.textFields?[0].text {
                    if let amount = Double(text) {
                        self.coin?.amount = amount
                        UserDefaults.standard.set(amount, forKey: coin.symbol + "amount")
                        self.newPrices()
                    }
                }
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func newHistory() {
        if let coin = coin {
            let serise = ChartSeries(coin.historicalDate)
            serise.area = true
            chart.add(serise)
        }
        
    }
    
    func newPrices()  {
        if let coin = coin {
            priceLabal.text = coin.priceAsString()
            worthLabal.text = coin.amountAsString()
            youOwnLabal.text = "You own: \(coin.amount) \(coin.symbol)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
