//
//  ViewController.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/11/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var citySearchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    var resultsData: [LocationResponseModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addObservers()
        
        //Configuring search bar
        citySearchBar.searchTextField.clearButtonMode = .never
        citySearchBar.delegate = self
        
        //Configuring results table view
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        addObservers()
        view.layoutIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        removeObservers()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        if !resultsTableView.isHidden {
            if notification.name == UIResponder.keyboardWillHideNotification {
                resultsTableView.contentInset = .zero
                resultsTableView.setContentOffset(.zero, animated: true)
            } else {
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardHeight = keyboardFrame.cgRectValue.height
                    let heightToScroll = keyboardHeight/2
                    resultsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: heightToScroll, right: 0)
                    resultsTableView.setContentOffset(CGPoint(x: 0, y: heightToScroll), animated: true)
                }
            }
            resultsTableView.scrollIndicatorInsets = resultsTableView.contentInset
        }
    }
    
    func addObservers() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        cell.textLabel?.text = resultsData[indexPath.row].cityName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TO-DO
    }
}

// UISearchBar Delegate Implementation
extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let httpRequest = HttpRequest(withUrl: URL(string: CommonConsts.HTTPGeocodeEndPoint)!, forHttpMethod: .get)
        HttpUtility.shared.request(huRequest: httpRequest, resultType: [LocationResponseModel].self) { [unowned self] result in
            switch result {
            case .success(let locations):
                let searchResults = locations?.map { return LocationResponseModel(cityName: $0.cityName, country: $0.country) }
                resultsData = searchResults ?? []
                resultsTableView.reloadData()
                
            case .failure(let error):
                Utils.showAlert(error.reason ?? AlertTitle.error, alertStyle: .alert, refViewController: self)
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
}

// UISearchBar Delegate Implementation
extension ViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

