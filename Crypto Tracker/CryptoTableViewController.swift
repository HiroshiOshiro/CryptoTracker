//
//  CryptoTableViewController.swift
//  Crypto Tracker
//
//  Created by hiroshi on 2018/07/28.
//  Copyright © 2018 hiroshi. All rights reserved.
//

import UIKit
import LocalAuthentication

private let headerHeight: CGFloat = 100.0
private let netWorthHight: CGFloat = 45.0

class CryptoTableViewController: UITableViewController, CoinDataDelegate {
    
    var amountLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoinData.shared.delegate = self
        CoinData.shared.getPrice()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Report", style: .plain, target: self, action: #selector(reportTapped))
        
        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            updateSecureButton()
        }
    }
    
    @objc func reportTapped() {
        let formatter = UIMarkupTextPrintFormatter(markupText: CoinData.shared.html())
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(formatter, startingAtPageAt: 0)
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage()
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        let shareVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        self.present(shareVC, animated: true, completion: nil)
    }
    
    func updateSecureButton() {
        if UserDefaults.standard.bool(forKey: "secure") {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unsecure App", style: .plain, target: self, action: #selector(secureTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Ssecure App", style: .plain, target: self, action: #selector(secureTapped))
        }
    }
    
    @objc func secureTapped() {
        if UserDefaults.standard.bool(forKey: "secure") {
            UserDefaults.standard.set(false, forKey: "secure")
        } else {
            UserDefaults.standard.set(true, forKey: "secure")
        }
        updateSecureButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoinData.shared.delegate = self
        tableView.reloadData()
        displayNetWorth()
    }
    
    func newPrices() {
        displayNetWorth()
        tableView.reloadData()
        
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: headerHeight))
        headerView.backgroundColor = UIColor.white
        let netWorthLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: netWorthHight))
        netWorthLabel.text = "My Crypto Net Worth"
        netWorthLabel.textAlignment = .center
        headerView.addSubview(netWorthLabel)
        
        amountLabel.frame = CGRect(x: 0, y: netWorthHight, width: view.frame.size.width, height: headerHeight - netWorthHight)
        amountLabel.textAlignment = .center
        amountLabel.font = UIFont.boldSystemFont(ofSize: 60.0)
        
        amountLabel.backgroundColor = UIColor.orange
        
        
        headerView.addSubview(amountLabel)
        
        displayNetWorth()
        
        return headerView
    }
    
    func displayNetWorth() {
        amountLabel.text = CoinData.shared.netWorthAsString()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        return 1
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoinData.shared.coins.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        let coin = CoinData.shared.coins[indexPath.row]
        
        if coin.amount != 0.0 {
            cell.textLabel?.text = coin.symbol + " - \(coin.priceAsString()) - \(coin.amount)"
        } else {
            cell.textLabel?.text = coin.symbol + " - \(coin.priceAsString())"
        }
        
        cell.imageView?.image = coin.image
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinVC = CoinViewController()
        coinVC.coin = CoinData.shared.coins[indexPath.row]
        navigationController?.pushViewController(coinVC, animated: true)
        
    }
    
}
