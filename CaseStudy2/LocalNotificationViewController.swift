//
//  LocalNotificationViewController.swift
//  CaseStudy2
//
//  Created by adminn on 26/09/22.
//

import UIKit
import NotificationFramework

class LocalNotificationViewController: UIViewController {
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    // MARK: IBAction function
    @IBAction func notificationCallButton(_ sender: Any) {
        // Object notification class from the custom framework
        let notificationCall = LocalNotification()
        // Calling method from that class
        notificationCall.localNotification(title: "Product Ordered", body: "Your product has been ordered sucessfully.")
    }
}
