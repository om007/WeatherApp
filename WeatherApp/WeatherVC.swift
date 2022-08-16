//
//  ViewController.swift
//  WeatherApp
//
//  Created by Om Prakash Shah on 8/15/22.
//

import UIKit
import Combine
import SDWebImage

class WeatherVC: UIViewController {

    @IBOutlet weak var locationSearchBar: UISearchBar!
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var weatherDetailContrinerScrollView: UIScrollView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var min_temperatureLabel: UILabel!
    @IBOutlet weak var max_temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var timezoneLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    
    lazy var loadingAlert: UIAlertController = {
        let alert = UIAlertController(title: nil, message: AlertTitle.pleaseWait, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 80, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        alert.view.addSubview(loadingIndicator)
        
        return alert
    }()

    private var weatherViewModel: WeatherViewModel = WeatherViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    private var locationResultsData: [LocationResponse] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addObservers()
        setupBinders()
        
        //Configuring search bar
        locationSearchBar.searchTextField.clearButtonMode = .never
        locationSearchBar.delegate = self
        
        //Configuring results table view
        resultsTableView.register(UINib(nibName: LocationTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: LocationTableViewCell.identifier)
        resultsTableView.layer.shadowRadius = 5
        resultsTableView.layer.shadowOffset = CGSize.zero
        resultsTableView.layer.shadowColor = UIColor.black.cgColor
        resultsTableView.layer.shadowOpacity = 0.2

        resultsTableView.rowHeight = DimenConsts.locationResultTable_rowHeight
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.isHidden = true
        
        weatherDetailContrinerScrollView.isHidden = true
        locationLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
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
    
    func setupBinders() {
        weatherViewModel.$locationResults
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] validLocations in
                //Populating locations as a suggestions in list
                locationResultsData = validLocations
                resultsTableView.reloadData()
                resultsTableView.isHidden = validLocations.count == 0
                locationSearchBar.isLoading = false
            }.store(in: &cancellables)
        
        weatherViewModel.$weatherDetail
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] weatherInfo in
                //Displaying weather detail
                updateDetailView(weatherDetail: weatherInfo)
                loadingAlert.dismiss(animated: false)
            }.store(in: &cancellables)
    }
    
    func updateDetailView(weatherDetail: WeatherResponse?) {
        resultsTableView.isHidden = true
        hideAllInfoLabels()
        if weatherDetail != nil {
            if let name = weatherDetail?.name {
                locationLabel.text = name.uppercased()
                locationLabel.isHidden = false
            }
            if let condition = weatherDetail?.weather?.main {
                conditionLabel.text = "Condition: \(condition)"
                conditionLabel.isHidden = false
            }
            if let description = weatherDetail?.weather?.description {
                descriptionLabel.text = "Description: \(description)"
                descriptionLabel.isHidden = false
            }
            if let temp = weatherDetail?.weather?.temp {
                temperatureLabel.text = "Current temperature: \(temp) degrees celcius"
                temperatureLabel.isHidden = false
            }
            if let min_temp = weatherDetail?.weather?.temp_min {
                min_temperatureLabel.text = "Minimum temperature: \(min_temp) degrees celcius"
                min_temperatureLabel.isHidden = false
            }
            if let max_temp = weatherDetail?.weather?.temp_max {
                max_temperatureLabel.text = "Maximum temperature: \(max_temp) degrees celcius"
                max_temperatureLabel.isHidden = false
            }
            if let humidity = weatherDetail?.weather?.humidity {
                humidityLabel.text = "Humidity: \(humidity) g/m3"
                humidityLabel.isHidden = false
            }
            if let timezone = weatherDetail?.timezone {
                timezoneLabel.text = "Timezone: \(timezone)"
                timezoneLabel.isHidden = false
            }
            
            if let iconName = weatherDetail?.weather?.icon {
                let weatherIconUrl = URL(string: CommonConsts.openWeatherIconUrl)?.appendingPathComponent("\(iconName).png")
                weatherImageView.sd_setImage(with: weatherIconUrl, placeholderImage: UIImage(named: "Landscape")?.withTintColor(.systemTeal))
                weatherImageView.isHidden = false
            }
            weatherDetailContrinerScrollView.isHidden = false
        }
    }
    
    func hideAllInfoLabels() {
        locationLabel.isHidden = true
        conditionLabel.isHidden = true
        descriptionLabel.isHidden = true
        temperatureLabel.isHidden = true
        min_temperatureLabel.isHidden = true
        max_temperatureLabel.isHidden = true
        humidityLabel.isHidden = true
        timezoneLabel.isHidden = true
        weatherImageView.isHidden = true
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

extension WeatherVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationResultsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location = locationResultsData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.identifier, for: indexPath) as! LocationTableViewCell
        cell.cityLabel.text = location.name
        cell.countryLabel.text = location.country
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        locationSearchBar.textField?.text = ""
        resultsTableView.isHidden = true //Hiding search results
        
        let locationModel = locationResultsData[indexPath.row]
        guard let lat = locationModel.lat, let lon = locationModel.lon else {
            Utils.showAlert(ErrorMessage.noWeatherDetails, alertStyle: .alert, refViewController: self)
            return
        }
        
        present(loadingAlert, animated: true)
        weatherViewModel.getWeatherInfo(lat: lat, lon: lon)
    }
}

// UISearchBar Delegate Implementation
extension WeatherVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch(_:)), object: searchBar)
        perform(#selector(performSearch(_:)), with: searchBar, afterDelay: 1.0)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    @objc func performSearch(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, query.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
            print("Nothing to search")
            return
        }
        
        searchBar.isLoading = true
        weatherViewModel.searchLocations(query)
    }
    
}

// UISearchBar Delegate Implementation
extension WeatherVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

//Handle tap gesture
extension WeatherVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view == gestureRecognizer.view
    }
}

