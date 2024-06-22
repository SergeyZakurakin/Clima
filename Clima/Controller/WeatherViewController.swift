//
//  WeatherViewController.swift
//  Clima
//
//  Created by Sergey Zakurakin on 19/06/2024.
//

import UIKit
import SnapKit
import CoreLocation

final class WeatherViewController: UIViewController {
    
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    // MARK: - UI
    private lazy var backgroundImageView: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(named: Constants.background)
        element.contentMode = .scaleAspectFill
        
        return element
    }()
    
    private lazy var mainStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .vertical
        element.spacing = 10
        element.alignment = .trailing
        
        return element
    }()
    
    private lazy var headerStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .horizontal
        element.alignment = .fill
        element.distribution = .fill
        
        return element
    }()
    
    private lazy var geoButton: UIButton = {
        let element = UIButton(type: .system)
        element.setImage(UIImage(systemName: Constants.geoSF), for: .normal)
        element.tintColor = .label
        
        element.addTarget(self, action: #selector(geoButtonPressed), for: .touchUpInside)
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    @objc private func geoButtonPressed(_ sender: UIButton) {
        locationManager.requestLocation()
        
    }
    
    private lazy var searchTextField: UITextField = {
        let element = UITextField()
        element.placeholder = Constants.search
        element.borderStyle = .roundedRect
        element.textAlignment = .right
        element.font = .systemFont(ofSize: 25)
        element.textColor = .label
        element.tintColor = .label
        element.backgroundColor = .systemFill
        element.returnKeyType = .go
        element.autocapitalizationType = .words
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var searchButton: UIButton = {
        let element = UIButton(type: .system)
        element.setImage(UIImage(systemName: Constants.searchSF), for: .normal)
        element.tintColor = .label
        element.addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var conditionImageView: UIImageView = {
        let element = UIImageView()
        element.image = UIImage(systemName: Constants.conditionSF)
        element.tintColor = .label
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var tempStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .horizontal
        
        return element
    }()
    
    private lazy var tempLabel: UILabel = {
        let element = UILabel()
        element.tintColor = .label
        element.font = .systemFont(ofSize: 80, weight: .black)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var tempTypeLabel: UILabel = {
        let element = UILabel()
        element.tintColor = .label
        element.font = .systemFont(ofSize: 100, weight: .light)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    private lazy var cityLabel: UILabel = {
        let element = UILabel()
        element.tintColor = .label
        element.font = .systemFont(ofSize: 30)
        
        element.translatesAutoresizingMaskIntoConstraints = false
        return element
    }()
    
    let emptyView = UIView()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
        
        
    }

    private func setupView() {
        
        
        view.addSubview(backgroundImageView)
        view.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(headerStackView)
        headerStackView.addArrangedSubview(geoButton)
        headerStackView.addArrangedSubview(searchTextField)
        headerStackView.addArrangedSubview(searchButton)
        
        mainStackView.addArrangedSubview(conditionImageView)
        mainStackView.addArrangedSubview(tempStackView)
        
        tempStackView.addArrangedSubview(tempLabel)
        tempStackView.addArrangedSubview(tempTypeLabel)
        
        mainStackView.addArrangedSubview(cityLabel)
        mainStackView.addArrangedSubview(emptyView)
        
        tempLabel.text = "21"
        tempTypeLabel.text = Constants.celsius
        cityLabel.text = "London"
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.requestLocation()
        
        
    }
}
//MARK: - Setup constraint
extension WeatherViewController {
    
    private func setupConstraints() {
        
        backgroundImageView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        mainStackView.snp.makeConstraints({ make in
            make.edges.equalTo(view.safeAreaLayoutGuide).inset(24)
        })
        
        headerStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        geoButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        searchButton.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        conditionImageView.snp.makeConstraints { make in
            make.width.height.equalTo(120)
        }
//        NSLayoutConstraint.activate([
//            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//        ])
    }
}
// MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    
    @objc private func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        print(searchTextField.text ?? "")
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if searchTextField.text != "" {
            return true
        } else {
            searchTextField.placeholder = "Type something here"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
            
        }
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async { [self] in
            tempLabel.text = weather.temperatureString
            conditionImageView.image = UIImage(systemName: weather.conditionName)
            cityLabel.text = weather.cityName
            
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
        print("got location Data")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
