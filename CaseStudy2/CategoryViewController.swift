//
//  CategoryViewController.swift
//  CaseStudy2
//
//  Created by adminn on 25/09/22.
//

import UIKit
import Alamofire
import FirebaseAuth

class CategoryViewCell: UITableViewCell {
    // MARK: IBOutlet for Table View Cell
    @IBOutlet weak var products: UILabel!
}
class CategoryViewController: UIViewController {
    
    // MARK: IBOutlet for Table View
    @IBOutlet weak var categoryTableView: UITableView!
    
    // MARK: Variable
    var categories = [String]()
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Calling a network call function
        requestFromThirdPartyAPI()
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
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
    // Fetching data from JSON using Third Party API
    func requestFromThirdPartyAPI() {
        // Request function provided by Alamofire psasing url and setting get method
        Alamofire.request("https://dummyjson.com/products/categories", method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            
            // Setting jsonData with response data
            if let jsonData = response.data {
                do {
                    // Decoding the contents in JSON from jsonData into urlresponse of [String] type
                    let urlResponse = try JSONDecoder().decode([String].self, from: jsonData)
                    
                    // Appending the data categories array
                    self.categories.append(contentsOf: urlResponse)
                    
                    // As it is a background task running it in main thread
                    DispatchQueue.main.async {
                        // Calling all table methods to update the data in table view
                        self.categoryTableView.reloadData()
                    }
                }
                catch let error {
                    self.showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
                }
            }
        }
    }
}
// MARK: Extension for Category View Controller
extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Table functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryViewCell", for: indexPath) as! CategoryViewCell
        cell.products.text! = categories[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let addVc = storyboard?.instantiateViewController(withIdentifier: "AddToCartViewController") as! AddToCartViewController
        addVc.productName = categories[indexPath.row]
        self.navigationController?.pushViewController(addVc, animated: true)
    }
}
