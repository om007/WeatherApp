//
//  Utils.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import UIKit

class Utils {
    static func showAlert(_ message: String, alertStyle: UIAlertController.Style, refViewController: UIViewController) {
        let alert = UIAlertController(title: AlertTitle.alert, message: message, preferredStyle: alertStyle)
        alert.addAction(UIAlertAction(title: AlertTitle.ok, style: UIAlertAction.Style.default, handler: nil))
        refViewController.present(alert, animated: true, completion: nil)
    }
    
    //Dismiss current view on clicking OK
    static func showAlertWithDismissVC(_ message: String, alertStyle: UIAlertController.Style, refViewController: UIViewController) {
        let alert = UIAlertController(title: AlertTitle.alert, message: message, preferredStyle: alertStyle)
        alert.addAction(UIAlertAction(title: AlertTitle.ok, style: UIAlertAction.Style.default, handler: { Void in
            refViewController.dismiss(animated: true, completion: nil)
        }))
        refViewController.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertAndPopVC(_ message: String, alertStyle: UIAlertController.Style, refViewController: UIViewController) {
        let alert = UIAlertController(title: AlertTitle.alert, message: message, preferredStyle: alertStyle)
        alert.addAction(UIAlertAction(title: AlertTitle.ok, style: UIAlertAction.Style.default, handler: { Void in
            refViewController.navigationController?.popViewController(animated: true)
        }))
        refViewController.present(alert, animated: true, completion: nil)
    }
    
    static func newLoadingAlert() -> UIAlertController {
        let loadingAlert = UIAlertController(title: nil, message: AlertTitle.pleaseWait, preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 80, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.startAnimating()
        loadingAlert.view.addSubview(loadingIndicator)
        
        return loadingAlert
    }

}
