//
//  MortgageView.swift
//  FinanceApp
//
//  Created by Abduvokhid Akhmedov on 05/03/2020.
//  Copyright © 2020 Abduvokhid Akhmedov. All rights reserved.
//

import UIKit

//
// Comments were written only for complex snippets of code as it is mentioned in Coursework description
//

class MortgageView: UIView, UITextFieldDelegate, Slide {
    
    // This enum is used to identify which text field must be calculated
    enum MortgageFinding {
        case Empty
        case InitialAmount
        case PaymentAmount
        case NumberOfYears
    }
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var initialAmountTF: UITextField!
    @IBOutlet weak var paymentAmountTF: UITextField!
    @IBOutlet weak var interestRateTF: UITextField!
    @IBOutlet weak var numberOfYearsTF: UITextField!
    
    @IBOutlet weak var cardViewTitle: UILabel!
    @IBOutlet weak var cardViewTitleSpace: UIView!
    
    @IBOutlet weak var errorTextView: UITextView!
    
    var finding = MortgageFinding.Empty
    let defaults = UserDefaults.standard
    
    // This method is executed when current view is generated in a parent view
    override func awakeFromNib() {
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowRadius = 10
        cardView.layer.shadowOffset = CGSize(width: 1, height: 1)
        cardView.layer.shadowOpacity = 0.2
        
        calculateButton.layer.cornerRadius = 5
        initialAmountTF.layer.cornerRadius = 5
        paymentAmountTF.layer.cornerRadius = 5
        interestRateTF.layer.cornerRadius = 5
        numberOfYearsTF.layer.cornerRadius = 5
        
        errorTextView.textColor = Colors.Red
        errorTextView.alpha = 0
        
        // This observer is created to save text field data when user closes the application
        let resignSelector = #selector(saveFields)
        NotificationCenter.default.addObserver(self, selector: resignSelector, name: UIApplication.willResignActiveNotification, object: nil)
        
        readFields()
    }
    
    // This method animates the page accordingly when keyboard is opened
    func keyboardOpened() {
        UIView.transition(with: superview!,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.titleLabel.text = self?.cardViewTitle.text!
            }, completion: nil)
        self.cardViewTitle.removeConstraints(self.cardViewTitle.constraints)
        self.cardViewTitle.heightAnchor.constraint(equalToConstant: 0).isActive = true
        self.cardViewTitleSpace.removeConstraints(self.cardViewTitleSpace.constraints)
        self.cardViewTitleSpace.heightAnchor.constraint(equalToConstant: 0).isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.cardViewTitle.alpha = 0
        }, completion: {_ in
            UIView.animate(withDuration: 0.3, animations: {
                self.superview?.layoutIfNeeded()
            }, completion: nil)
        })
    }
    
    // This method returns all views back to their default style when keyboard is closed
    func keyboardClosed() {
        UIView.transition(with: superview!,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
                            self?.titleLabel.text = "Finance App"
            }, completion: nil)
        self.cardViewTitle.removeConstraints(self.cardViewTitle.constraints)
        self.cardViewTitle.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.cardViewTitleSpace.removeConstraints(self.cardViewTitleSpace.constraints)
        self.cardViewTitleSpace.heightAnchor.constraint(equalToConstant: 10).isActive = true
        UIView.animate(withDuration: 0.3, animations: {
            self.cardViewTitle.alpha = 1
        }, completion: {_ in
            UIView.animate(withDuration: 0.3, animations: {
                self.superview?.layoutIfNeeded()
            }, completion: nil)
        })
    }
    
    // Here text fields are validated and necessary field is calculated
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        
        // Closing the keyboard when Calculate button is pressed
        HomePageViewController.parentController.closeKeyboard()
        
        let interestRate = interestRateTF.validatedDouble
        let initialAmount = initialAmountTF.validatedDouble
        let paymentAmount = paymentAmountTF.validatedDouble
        let numberOfYears = numberOfYearsTF.validatedDouble
        
        // Passing current values of all textfields to validate them
        let validationError = validateInput(interestRate: interestRate, initialAmount: initialAmount, paymentAmount: paymentAmount, numberOfYears: numberOfYears)
        
        let color = sender.backgroundColor
        
        // If validation is successfull, validationError will be nil and calculation will be done. But if it is not nil, it will store error text and text will be shown on a page
        if validationError == nil {
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                self.calculateButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                sender.backgroundColor = Colors.Green
                self.topBarView.backgroundColor = Colors.Green
            }, completion: {_ in
                UIView.animate(withDuration: 0.2, animations: {() -> Void in
                    self.calculateButton.transform = CGAffineTransform.identity
                }, completion: { _ in
                    UIView.animate(withDuration: 0.2, delay: 0.6, animations: {() -> Void in
                        sender.backgroundColor = color
                        self.topBarView.backgroundColor = color
                    })
                })
            })
            
            // Depending on the field which must be calculated, necessary method will be called
            switch finding {
            case .InitialAmount:
                let result = MortgageHelper.initialValue(paymentAmount: paymentAmount!, interestRate: interestRate!, numberOfYears: numberOfYears!)
                initialAmountTF.text = "£ " + String(format: "%.2f", result)
            case .NumberOfYears:
                let result = MortgageHelper.numberOfYears(initialAmount: initialAmount!, interestRate: interestRate!, paymentAmount: paymentAmount!)
                numberOfYearsTF.text = String(format: "%.2f", result)
            case .PaymentAmount:
                let result = MortgageHelper.paymentAmount(initialAmount: initialAmount!, interestRate: interestRate!, numberOfYears: numberOfYears!)
                paymentAmountTF.text = "£ " + String(format: "%.2f", result)
            default:
                return
            }
        } else {
            errorTextView.text = validationError!
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.notificationOccurred(.error)
            UIView.animate(withDuration: 0.2, animations: {
                sender.backgroundColor = Colors.Red
                self.topBarView.backgroundColor = Colors.Red
                self.errorTextView.alpha = 1
            }, completion: {_ in
                UIView.animate(withDuration: 0.5, delay: 2, animations: {
                    sender.backgroundColor = color
                    self.topBarView.backgroundColor = color
                    self.errorTextView.alpha = 0
                })
            })
        }
        
    }
    
    // This method is adding necessary symbols to the textfield
    @IBAction func textFieldEdited(_ sender: UITextField) {
        if sender.filteredText == "" {
            sender.text = sender.filteredText
            return
        }
        switch sender.tag {
        case 1:
            sender.text = "£ " + sender.filteredText
        case 2:
            sender.text = sender.filteredText + " %"
        default:
            break
        }
    }
    
    // Current method is validating textfield data
    func validateInput(interestRate: Double!, initialAmount: Double!, paymentAmount: Double!, numberOfYears: Double!) -> String! {
        var counter = 0
        
        if (initialAmount == nil) {
            counter += 1
            finding = .InitialAmount
        }
        
        if (paymentAmount == nil) {
            counter += 1
            finding = .PaymentAmount
        }
        
        if (numberOfYears == nil) {
            counter += 1
            finding = .NumberOfYears
        }
        
        if counter > 1 {
            finding = .Empty
            return "Only one text field can be empty!\nPlease, read the help page to get more information!"
        }
        
        if interestRate == nil {
            return "Interest rate cannot be empty!\nPlease, read the help page to get more information!"
        }
        
        if counter == 0 && finding == .Empty {
            finding = .Empty
            return "At least one text field must be empty!\nPlease, read the help page to get more information!"
        }
        
        if paymentAmount != nil && initialAmount != nil {
            if paymentAmount > initialAmount {
                finding = .Empty
                return "Payment amount cannot be more than initial amount!"
            }
        }
        
        if initialAmount != nil && initialAmount == 0 {
            finding = .Empty
            return "Initial amount cannot be zero!"
        }
        
        if paymentAmount != nil && paymentAmount == 0 {
            finding = .Empty
            return "Payment amount cannot be zero!"
        }
        
        if numberOfYears != nil && numberOfYears == 0 {
            finding = .Empty
            return "Number of years cannot be zero!"
        }
        
        return nil
    }
    
    // When user presses the Clear button, current method is clearing text from all textfields with transition (smoothly)
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        sender.layer.cornerRadius = 5
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            sender.tintColor = .white
            sender.backgroundColor = UIColor(red:0.27, green:0.41, blue:0.78, alpha:1.0)
        }, completion: {_ in
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                sender.tintColor = UIColor(red:0.88, green:0.89, blue:0.90, alpha:1.0)
                sender.backgroundColor = .none
            })
        })
        
        UIView.transition(with: cardView,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in 
                            self?.initialAmountTF.text = ""
                            self?.paymentAmountTF.text = ""
                            self?.interestRateTF.text = ""
                            self?.numberOfYearsTF.text = ""
            }, completion: nil)
    }
    
    // Current method is calling help page
    @IBAction func helpButtonPressed(_ sender: UIButton) {
        HomePageViewController.parentController.closeKeyboard()
        sender.layer.cornerRadius = 5
        UIView.animate(withDuration: 0.2, animations: {() -> Void in
            sender.tintColor = .white
            sender.backgroundColor = UIColor(red:0.27, green:0.41, blue:0.78, alpha:1.0)
        }, completion: {_ in
            UIView.animate(withDuration: 0.2, animations: {() -> Void in
                sender.tintColor = UIColor(red:0.88, green:0.89, blue:0.90, alpha:1.0)
                sender.backgroundColor = .none
            })
        })
        
        // Creating instance of the help page controller and passing data to be shown in that page
        let helpPage = HomePageViewController.parentController.storyboard?.instantiateViewController(withIdentifier: "HelpPageViewController") as! HelpPageViewController
        helpPage.titleText = "Mortgage help page"
        helpPage.helpText = "<b>Initial amount</b> (A) – In this box, it is required to insert the amount of money that the user currently is planning to take from the bank for the mortgage.</br><i>Please leave this box empty if you are looking for the Initial amount.</i></br></br><b>Payment amount</b> (PMT) – In this box, it is required to insert the amount of money the user is planning to pay back monthly.</br><i>Please leave this box empty if you are looking for the Payment amount.</i></br></br><b>Interest Rate</b> (r) - In this box, it is required to insert the interest rate stablished for the mortgage.</br><i>This box cannot be empty.</i></br></br><b>Number of years</b> (t) - In this box, it is required to insert the period of time (years) within what user expects to pay back the mortgage.</br><i>Please leave this box empty if you are looking for Number of years.</i></br></br><b>Calculate</b> – press Calculate button to get the desired result.</br><i>Please leave empty the box you are expecting to get the result for.</i></br></br><b>Calculations are done based on the current formula:</b>"
        helpPage.helpFormula = UIImage(named: "mortgageFormula")
        
        HomePageViewController.parentController.present(helpPage, animated: true, completion: nil)
    }
    
    // This method is changing border color of the textfield which user selected
    @IBAction func textFieldEditBegin(_ sender: UITextField) {
        sender.delegate = self
        sender.layer.borderWidth = 1
        changeBorderColor(sender: sender, fromColor: Colors.Gray.cgColor, toColor: Colors.Blue.cgColor)
    }
    
    // This method is changing border color back to default color when user finishes editing the textfield
    @IBAction func textFieldEditEnd(_ sender: UITextField) {
        changeBorderColor(sender: sender, fromColor: Colors.Blue.cgColor, toColor: Colors.Gray.cgColor)
        sender.layer.borderWidth = 0
    }
    
    // This is common method for changing border color of the textfield. Used both when user starts and ends textfield editing
    func changeBorderColor(sender: UITextField, fromColor: CGColor, toColor: CGColor) {
        let color = CABasicAnimation(keyPath: "borderColor");
        color.fromValue = fromColor
        color.toValue = toColor
        color.duration = 0.3;
        color.repeatCount = 1;
        sender.layer.borderColor = toColor
        sender.layer.add(color, forKey: "borderColor");
    }
    
    // This method is called whenever user presses any button on the keyboard when textfield is active. Last change will be canceled if false is returned from this method. Otherwise changes will be applied
    // Current method is used to set some rules for textfields: only one decimal separator, only two decimal places etc
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = textField.filteredText
        
        if let char = string.cString(using: String.Encoding.utf8){
            let isBackspace = strcmp(char, "\\b")
            if (isBackspace == -92){
                textField.text = String(newText.dropLast()) + " "
                return true
            }
        }
        
        let stringParts = newText.components(separatedBy: ".")
        
        if stringParts.count > 1 && string == "." {
            return false
        }
        
        if (stringParts.count == 2 && stringParts[1].count == 2){
            return false
        }
        
        if textField.filteredText == "0" && string != "." {
            textField.text = ""
        }
        
        if textField.filteredText == "" && string == "." {
            textField.text = "0"
        }
        
        return true
    }
    
    // Saving textfield data to the user defaults
    @objc func saveFields() {
        defaults.set(initialAmountTF.text, forKey: "mortgageInitialAmount")
        defaults.set(paymentAmountTF.text, forKey: "mortgagePaymentAmount")
        defaults.set(numberOfYearsTF.text, forKey: "mortgageNumberOfYears")
        defaults.set(interestRateTF.text, forKey: "mortgageInterestRate")
    }
    
    // Reading data from user defaults and setting it to textfields
    func readFields(){
        initialAmountTF.text = defaults.string(forKey: "mortgageInitialAmount")
        paymentAmountTF.text = defaults.string(forKey: "mortgagePaymentAmount")
        numberOfYearsTF.text = defaults.string(forKey: "mortgageNumberOfYears")
        interestRateTF.text = defaults.string(forKey: "mortgageInterestRate")
    }
    
}
