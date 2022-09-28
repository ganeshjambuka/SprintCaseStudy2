//
//  ViewController.swift
//  CaseStudy2
//
//  Created by adminn on 22/09/22.
//

import UIKit
import FirebaseAuth
import CoreData
import LocalAuthentication
import Security

class LoginViewController: UIViewController {
    // MARK: IBOutlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var emailID: UITextField!
    
    // MARK: Variables
    var authenticationError: NSError?
    let context = LAContext()
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // For making image in circular
        logoImageView.layer.cornerRadius = logoImageView.frame.size.width / 2
        logoImageView.clipsToBounds = true
        // Calling Local Authentication Methods
        //authenticateUserByPasscode()
        //authenticateUserByBiometrics()
    }
    
    // MARK: IBActions
    @IBAction func loginActionButton(_ sender: Any) {
        // Passing emailvalue and password to authenticate using FirebaseAuth
        authenticateUsingFirebase(emailText: emailID.text!, passwordText: password.text!)
    }
    @IBAction func signupActionButton(_ sender: Any) {
        // Navigating to Signup Screen
        let signUpVc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signUpVc, animated: true)
    }
    
    // MARK: Functions
    // Local Authentication by Biometrics
    func authenticateUserByBiometrics() {
        // The message to be displayed while asking face id
        let authenticatingMsg = "Face ID is required to access this app."
        
        // Checking whether the authenticaton policy by face id is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authenticationError){
            
            // The User face id matches or not has been checked
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authenticatingMsg, reply: { [weak self] success, error in
                    if success {
                        // It is a background so it should run on main thread
                        DispatchQueue.main.async() {
                            // Showing Success Pop up
                            self?.showAlert(popUptitle: "Success", alertMessage: "Authentication Successful")
                        }
                    }
            })
        }
        else {
            // Showing Alert Pop up
            self.showAlert(popUptitle: "Error", alertMessage: "Authentication Failed")
        }
    }
    
    // Local Authentication by passcode
    func authenticateUserByPasscode() {
        // The message to be displayed while asking passcode
        let authenticationMsg = "Authentication is required to access this app."
        
        // Checking whether the authenticaton policy is available
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authenticationError) {
            
            // The User passcode matches or not has been checked
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: authenticationMsg, reply: { success, error in
                    if success {
                        // It is a background so it should run on main thread
                        DispatchQueue.main.async {
                            self.showAlert(popUptitle: "Success", alertMessage: "Authentication Successful")
                        }
                    }
                    else {
                        guard let errorMsg = error  else{ return }
                        self.showAlert(popUptitle: "Error", alertMessage: errorMsg.localizedDescription)
                    }
            })
        }
    }
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
    // Function to authenticate user by auth
    func authenticateUsingFirebase(emailText: String, passwordText: String) {
        // Calling signin func from auth to authenticate user
        Auth.auth().signIn(withEmail: emailText, password: passwordText, completion: {
            (result, error) -> Void in
            if error != nil {
                self.showAlert(popUptitle: "Invalid", alertMessage: "User does not exist. Please signup.")
            }
            else {
                do {
                    // Passing values to Keychainmanager class function to save
                    try KeyChainManager.save(
                        account: self.emailID.text!, password: self.password.text!.data(using: .utf8) ?? Data())
                }
                catch (let error) {
                    self.showAlert(popUptitle: "Keychain Error", alertMessage: error.localizedDescription)
                }
                // Pushing or navigating to category screen
                let tabVc = self.storyboard?.instantiateViewController(withIdentifier: "tab") as! UITabBarController
                self.navigationController?.pushViewController(tabVc, animated: true)
            }
        })
    }
}
// MARK: KeyChain Class
// Creating class for KeyChain
class KeyChainManager {
    
    // Creating enum for different types of error so to access each options
    enum KeyChainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
    }
    // Function to Add email and password in keychain
    static func save(account: String, password: Data) throws {
        
        // keyChain Items
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject
            ]
        
        // Calling function SecItemAdd to add the values in dictionary
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // Checking if values already added in keychain
        guard status == errSecDuplicateItem else {
            throw KeyChainError.duplicateEntry
        }
        // To check the values added sucessfully
        guard status == errSecSuccess else {
            throw KeyChainError.unknown(status)
        }
    }
}
