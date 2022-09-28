//
//  CartViewController.swift
//  CaseStudy2
//
//  Created by adminn on 25/09/22.
//

import UIKit
import CoreData
import FirebaseAuth

class CartViewCell: UITableViewCell {
    // MARK: IBOutlet for table view cell
    @IBOutlet weak var productOrderImage: UIImageView!
    @IBOutlet weak var productOrderTitle: UILabel!
    @IBOutlet weak var productOrderDescription: UILabel!
    @IBOutlet weak var cartImageView: UIImageView!
}
class CartViewController: UIViewController {
    // MARK: IBOutlet for Table View
    @IBOutlet weak var cartTableView: UITableView!
    
    // MARK: Vvariable
    var productAddedToCart = [AddToCart]()
    let addCartContext = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    let currentUserEmail = Auth.auth().currentUser?.email
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        cartTableView.dataSource = self
        cartTableView.delegate = self
        checkEmail(emailText: currentUserEmail!)
    }
    // MARK: Functions
    func checkEmail(emailText: String){
        
        // Checking if the managed object is not returning exit code zero
        guard let appDelegate = UIApplication.shared
            .delegate as? AppDelegate else { return }
        
        // Creating context to access persistentContainer class
        let context = appDelegate.persistentContainer.viewContext
        
        // Passing fetch request method to request variable
        let request: NSFetchRequest<AddToCart> = AddToCart.fetchRequest()
        
        // Comparing text provided by user with email present in the core data
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["emailId", emailText])
        do {
            // Storing values if exist in core data by calling fetch request
            productAddedToCart = try context.fetch(request)
            
            // Reloading data after getting values in main thread
            DispatchQueue.main.async {
                self.cartTableView.reloadData()
            }
        }
        catch (let error) {
            showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
        }
    }
    // Display alert pop-ups
    func showAlert(popUptitle: String, alertMessage: String) {
        
        // Dialog box contents
        let alertController = UIAlertController(title: popUptitle, message: alertMessage, preferredStyle: .alert)
        
        // Action Button
        let  okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        // Pop up dialog box with contents
        self.present(alertController, animated: true)
    }
    // MARK: Selector Method
    // After clicking on cart navigates to Map View Controller
    @objc func clickOnCart(_ sender: UITapGestureRecognizer) {
        let mapVc = storyboard?.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.navigationController?.pushViewController(mapVc, animated: true)
    }
    
}
// MARK: Extension for Table functions
extension CartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productAddedToCart.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152.0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartViewCell") as! CartViewCell
        
        // If the image is tapped it will call selector method
        let tapGestureRecognise = UITapGestureRecognizer(target: self, action: #selector(clickOnCart(_:)))
        let product = productAddedToCart[indexPath.row]
        cell.productOrderTitle.text = product.productTitle
        cell.productOrderDescription.text = product.productDescription
        
        // Calling function to load image from url
        cell.productOrderImage.loadFromUrl(urlAddress: product.productThumbnail!)
        
        // Add gesture recogniser for cart image
        cell.cartImageView.addGestureRecognizer(tapGestureRecognise)
        return cell
    }
    
}

