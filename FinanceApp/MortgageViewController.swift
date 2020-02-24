//
//  MortgageViewController.swift
//  FinanceApp
//
//  Created by Abduvokhid Akhmedov on 22/02/2020.
//  Copyright © 2020 Abduvokhid Akhmedov. All rights reserved.
//

import UIKit

enum MortgageFinding {
    case empty
    case initialAmount
    case paymentAmount
    case numberOfYears
}

class MortgageViewController: UIViewController{

    @IBOutlet weak var initialAmountTF: UITextField!
    @IBOutlet weak var paymentAmountTF: UITextField!
    @IBOutlet weak var numberOfYearsTF: UITextField!
    @IBOutlet weak var interestRateTF: UITextField!
    var currentTextField: UITextField!
    
    var finding = MortgageFinding.empty
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        var counter = 0
        
        let interestRate: Double! = Double(interestRateTF.text!)
        if (interestRate == nil) {
            return
        }
        
        let initialAmount: Double! = Double(initialAmountTF.text!)
        if (initialAmount == nil) {
            counter += 1
            finding = .initialAmount
        }
        
        let paymentAmount: Double! = Double(paymentAmountTF.text!)
        if (paymentAmount == nil) {
            counter += 1
            finding = .paymentAmount
        }
        
        let numberOfYears: Double! = Double(numberOfYearsTF.text!)
        if (numberOfYears == nil) {
            counter += 1
            finding = .numberOfYears
        }
        
        if ((counter == 0 && finding == .empty) || counter > 1) {
            finding = .empty
            return
        }
        
        switch finding {
        case .initialAmount:
            let result = MortgageHelper.initialValue(paymentAmount: paymentAmount, interestRate: interestRate, numberOfYears: numberOfYears)
            initialAmountTF.text = String(format: "%.2f", result)
        case .numberOfYears:
            let result = MortgageHelper.numberOfYears(initialAmount: initialAmount, interestRate: interestRate, paymentAmount: paymentAmount)
            numberOfYearsTF.text = String(format: "%.2f", result)
        case .paymentAmount:
            let result = MortgageHelper.paymentAmount(initialAmount: initialAmount, interestRate: interestRate, numberOfYears: numberOfYears)
            paymentAmountTF.text = String(format: "%.2f", result)
            
            /*let formatter = NumberFormatter()
            formatter.usesGroupingSeparator = true
            formatter.numberStyle = .currency
            formatter.currencyGroupingSeparator = " "
            formatter.currencyDecimalSeparator = "."
            formatter.currencySymbol = "£"
            paymentAmountTF.text = formatter.string(for: result)*/
        default:
            return
        }
    }
}
