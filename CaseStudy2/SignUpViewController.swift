//
//  SignUpViewController.swift
//  CaseStudy2
//
//  Created by adminn on 22/09/22.
//

import UIKit
import CoreData
import FirebaseAuth

class SignUpViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var imageLogoView: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var emailID: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!

    // MARK: Variables
    // Creating a context to access persistentContainer viewcontext method
    let userContext = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Making image in circular
        imageLogoView.layer.cornerRadius = imageLogoView.frame.size.width / 2
        imageLogoView.clipsToBounds = true
    }
    // MARK: IBActions
    @IBAction func submitActionButton(_ sender: Any) {
        // If all fields are empty and user clicks on signup button
        if ((emailID.text?.isEmpty)! && (name.text?.isEmpty)! && (phoneNumber.text?.isEmpty)! && (password.text?.isEmpty)!) {
            showAlert(popUptitle: "Invalid", alertMessage: "All Fields are empty please type again.")
        }
        else {
            // Calling all the functions
            let duplicateEmailCheck = checkDuplicateEmail(emailText: emailID.text!)
            let nameReturned = validateName(nameText: name.text!)
            let emailIDReturned = validateEmail(emailIDText:emailID.text!)
            let mobileReturned = validateMobile(mobile: phoneNumber.text!)
            let passwordReturned = validatePassword(passwordText:password.text!)
            let passwordSameReturned = isPasswordSame(passwordText: password.text!, confirmPasswordText: confirmPassword.text!)
            
            // Checking if all the functions return true value so to save data into coredata and create new user in firebase
            if duplicateEmailCheck && nameReturned && emailIDReturned && mobileReturned && passwordReturned && passwordSameReturned == true{
                
                // Object of UserData
                let newUser = UserData(context: self.userContext)
                
                // Passing values to attributes
                newUser.name = name.text
                newUser.emailId = emailID.text
                newUser.password = password.text
                newUser.phonenumber = phoneNumber.text
                           
                do {
                    // Register new user in firebase authentication
                    registerNewUser(emailId: emailID.text!, passwordProvided: password.text!)
                    
                    // Calling save function from persistent container class
                    try self.userContext.save()
                    
                    // After saving data navigating to category view controller
                    let tabVc = self.storyboard?.instantiateViewController(withIdentifier: "tab") as! UITabBarController
                    self.navigationController?.pushViewController(tabVc, animated: true)
                    
                }
                catch (let error) {
                    showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
                }
            }
        }
    }
    // MARK: Functions
    // Display pop-up alert messages
    func showAlert(popUptitle: String, alertMessage: String) {
        
        // Dialog box contents
        let alertController = UIAlertController(title: popUptitle, message: alertMessage, preferredStyle: .alert)
        
        // Action Button
        let  okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        // Pop up dialog box with contents
        self.present(alertController, animated: true)
    }
    // Function to register newuser
    func registerNewUser(emailId: String, passwordProvided: String) {
        // Calling createuser function from Auth
        Auth.auth().createUser(withEmail: emailId, password: passwordProvided, completion: {
            (result, error) in
            if let errorMsg = error {
                self.showAlert(popUptitle: "Error", alertMessage: errorMsg.localizedDescription)
            }
        })
    }
    // Function to check duplicate email
    func checkDuplicateEmail (emailText: String) -> Bool {
        
        // Checking if the managed object is not returning exit code zero
        guard let appDelegate = UIApplication.shared
            .delegate as? AppDelegate else { return 0 != 0}
        
        // Creating context to access persistentContainer class
        let context = appDelegate.persistentContainer.viewContext
        
        // Passing fetch request method to request variable
        let request: NSFetchRequest<UserData> = UserData.fetchRequest()
        
        // Comparing text provided by user with email present in the core data
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["emailId", emailText])
        
        // Creating variable of type NSManagedObject
        var result: [NSManagedObject] = []
        do {
            // Storing email value if exist in core data by calling fetch request
            result = try context.fetch(request)
            
            // If email value exist it will pop alert
            if result.count == 1 {
                showAlert(popUptitle: "Invalid", alertMessage: "Email Id already exists")
            }
        }
        catch (let error) {
            print(error.localizedDescription)
        }
        // If email doesnt exist returns true
        return result.count == 0
    }
    
    // Function to validate name
    func validateName(nameText: String) -> Bool {
        
        // Created result variable to return bool value
        var result: Bool = false
        
        // Regex for name
        let regex = "^[A-Za-z]{4,15}$"
        do {
            // Using NSregularExpression
            let expression = try NSRegularExpression(pattern: regex, options: [ .caseInsensitive])
            
            // Comparing the name provided
            let validName = expression.firstMatch(in: nameText, options: [], range: NSRange(location: 0, length: nameText.count)) != nil
            
            // If valid then setting result to true
            if validName {
                result = true
            }
            else {
                showAlert(popUptitle: "Invalid", alertMessage: "Name is Invalid")
            }
        }
        catch (let error) {
            showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
        }
        return result
    }
    
    // Function to validate email
    func validateEmail(emailIDText: String) -> Bool {
        var result: Bool = false
        let regex = "^[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}$"
        do {
            let expression = try NSRegularExpression(pattern: regex, options: [ .caseInsensitive])
            let validEmail = expression.firstMatch(in: emailIDText, options: [], range: NSRange(location: 0, length: emailIDText.count)) != nil
            
            if validEmail {
                result = true
            }
            else {
                showAlert(popUptitle: "Invalid", alertMessage: "Email ID is Invalid")
            }
        }
        catch (let error) {
            showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
        }
        return result
    }
    
    // Function to validate phone number
    func validateMobile (mobile: String) -> Bool {
        
        // Function to validate name
        var result: Bool = false
        
        // Regex for phonenumber
        let regex = "^[0-9]{10}$"
        do {
            let expression = try NSRegularExpression(pattern: regex)
            let validPhoneNumber = expression.firstMatch(in: mobile, options: [], range: NSRange(location: 0, length: mobile.count)) != nil
            if validPhoneNumber {
                result = true
            }
            else {
                showAlert(popUptitle: "Invalid", alertMessage: "Phone Number is Invalid")
            }
        }
        catch (let error) {
            showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
        }
        return result
    }
    
    // Function to validate password
    func validatePassword(passwordText: String) -> Bool  {
        var result = false
        // Regex for password
        let regex = "^(?=.*[A-Z])(?=.*[$@$#!%?&])(?=.*[0-9])(?=.*[a-z]).{6,15}$"
        
        // Comparing password provided satisfies the regex
        let validPassword = NSPredicate(format: "SELF MATCHES %@", regex)
        
        if validPassword.evaluate(with: passwordText) {
            result.toggle()
        }
        else {
            showAlert(popUptitle: "Invalid", alertMessage: "Invalid Password must be more than 6 characters")
        }
        // Returns bool value after evaluating
        return result
    }
    
    // Function to check if password is same
    func isPasswordSame (passwordText: String, confirmPasswordText: String) -> Bool {
        var result: Bool = false
        
        // Check if both password and confirm password are same
        if passwordText == confirmPasswordText && passwordText.count > 0 {
            result.toggle()
        }
        // Show alert if not same
        else {
            showAlert(popUptitle: "Invalid", alertMessage: "Re-enter confirm password same as password.")
        }
        return result
    }
}
