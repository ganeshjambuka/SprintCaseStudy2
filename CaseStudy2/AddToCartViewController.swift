//
//  AddToCartViewController.swift
//  CaseStudy2
//
//  Created by adminn on 25/09/22.
//

import UIKit
import Alamofire
import CoreData
import FirebaseAuth

class ProductViewCell: UITableViewCell {
    // MARK: IBOutlets for table view cell
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var cartImageview: UIImageView!
    
}
class AddToCartViewController: UIViewController {
    // MARK: IBOutlet for table view
    @IBOutlet weak var productTableView: UITableView!
    // MARK: Variables
    var productName = String()
    var apiLink = "https://dummyjson.com/products/category/"
    var diffProducts = [products]()
    // Creating a context to access persistentContainer viewcontext method.
    let addCartContext = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Add To Cart"
        // Variable productName has a value passed from category added to url
        apiLink += productName
        // Calling a network call function
        fetchingDataFromURLUsingAF()
        productTableView.dataSource = self
        productTableView.delegate = self
    }
    // MARK: Selector method
    @objc func clickedOnCart(_ sender: UITapGestureRecognizer) {
        // Checking if the user has already added the product so to avoid duplicate entry
        if checkDuplicateEntry(productTitle: diffProducts[sender.view!.tag].productTitle) {
            
            // Fetching current user email id from Auth
            let currentUserEmailId = Auth.auth().currentUser?.email
            
            // Object of Addtocart entity
            let addProduct = AddToCart(context: addCartContext)
            
            // Passing values to attributes
            addProduct.emailId = currentUserEmailId
            addProduct.productTitle = diffProducts[sender.view!.tag].productTitle
            addProduct.productDescription = diffProducts[sender.view!.tag].productDescription
            addProduct.productThumbnail = diffProducts[sender.view!.tag].productThumbnail
            do {
                // Calling save function from persistent container class
                try self.addCartContext.save()
                showAlert(popUptitle: "Added To Cart", alertMessage: "Your Selected Product: \(diffProducts[sender.view!.tag].productTitle)")
            }
            catch (let error) {
                showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
            }
        }
    }
    // MARK: Functions
    // Function to check duplicate entry
    func checkDuplicateEntry(productTitle: String) -> Bool {
        
        // Checking if the managed object is not returning exit code zero
        guard let appDelegate = UIApplication.shared
            .delegate as? AppDelegate else { return (0 != 0)}
        
        // Creating context to access persistentContainer class
        let context = appDelegate.persistentContainer.viewContext
        
        // Passing fetch request method to request variable
        let request = AddToCart.fetchRequest()
        
        // Comparing product present in the core data
        request.predicate = NSPredicate(format: "%K == %@", argumentArray: ["productTitle", productTitle])
        
        // Creating variable of type NSManagedObject
        var result: [NSManagedObject] = []
        do {
            // Storing email value if exist in core data by calling fetch request
            result = try context.fetch(request)
            
            // If product value exist it will pop alert
            if result.count == 1 {
                showAlert(popUptitle: "Alert", alertMessage: "Already added this product in the cart.")
            }
        }
        catch (let error) {
            showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
        }
        // If product doesnt exist returns true
        return result.count == 0
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
    // Using third party API for network call
    func fetchingDataFromURLUsingAF() {
        // Request function provided by Alamofire psasing url and setting get method
        Alamofire.request(apiLink, method: .get, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success:
                // Setting jsonData with response data
                if let jsonData = response.data {
                    do {
                        // Decoding the contents in JSON from jsonData into urlresponse of Product Model type
                        let urlResponse = try JSONDecoder().decode(Root.self, from: jsonData)
                        
                        // Appending the data categories array
                        self.diffProducts.append(contentsOf: urlResponse.product)
                        
                        // As it is a background task running it in main thread
                        DispatchQueue.main.async {
                            // Calling all table methods to update the data in table view
                            self.productTableView.reloadData()
                        }
                    }
                    catch let error {
                        self.showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
                    }
                }
                break
            case .failure(let error):
                self.showAlert(popUptitle: "Error", alertMessage: error.localizedDescription)
            }
            
        }
    }
}
// MARK: Extension for UIImageView to load image from url.
extension UIImageView {
    // Function for to load image view from url
    func loadFromUrl(urlAddress: String) {
        // If it is nil it will return without crashing the app.
        guard let url = URL(string: urlAddress) else {
            return
        }
        // If the url address is present run the task in main thread
        DispatchQueue.main.async { [weak self] in
            // Getting image data from url
            if let imageData = try? Data(contentsOf: url) {
                
                // Getting image loaded to the view
                if let loadedimage = UIImage(data: imageData) {
                    self?.image = loadedimage
                }
            }
        }
    }
}
// MARK: Extension for Table functions
extension AddToCartViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Table Function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diffProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductViewCell", for: indexPath) as! ProductViewCell
        // If the image is tapped it will call selector method
        let tapGestureRecognise = UITapGestureRecognizer(target: self, action: #selector(clickedOnCart(_:)))
        
        // Calling function to load image from url
        cell.productImageView.loadFromUrl(urlAddress: diffProducts[indexPath.row].productThumbnail)
        cell.productTitle.text = diffProducts[indexPath.row].productTitle
        cell.productDescription.text = diffProducts[indexPath.row].productDescription
        
        // Getting row value for the image tapped
        cell.cartImageview.tag = indexPath.row
        
        // Add gesture recogniser for cart image
        cell.cartImageview.addGestureRecognizer(tapGestureRecognise)

        return cell
    }
    
    
}
