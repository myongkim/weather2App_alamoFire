//
//  ViewController.swift
//  weather2App
//
//  Created by Isaac Kim on 1/24/22.
//

import UIKit
import Alamofire


class ViewController: UIViewController {

    @IBOutlet var cityNameTextField: UITextField!
    @IBOutlet var cityNameLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    
    @IBOutlet var maxTempLabel: UILabel!
    @IBOutlet var minTempLabel: UILabel!
    
    @IBOutlet var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    @IBAction func TapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text  {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
        
    }
    
    
    @IBAction func tapAlamoButton(_ sender: UIButton) {
        if let cityName = cityNameTextField.text {
            alamoeGetData(cityName: cityName) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case let .success(result):
                    self.weatherStackView.isHidden = false
                    self.cityNameLabel.text = result.name
                    
                    self.weatherDescriptionLabel.text = result.weather.first?.description
                    
                    self.tempLabel.text = "\(Int(result.temp.temp - 273.15))°C"
                    self.maxTempLabel.text = "\(Int(result.temp.maxTemp - 273.15))°C"
                    self.minTempLabel.text = "\(Int(result.temp.minTemp - 273.15))°C"
                    
                    debugPrint("success: \(result)")
                
                case let .failure(error):
                    debugPrint("error \(error)")
                }
            }
        }
        
    }
    
    
    
    func configureView(weatherInformation: WeatherInformation) {
        cityNameLabel.text = weatherInformation.name
        
        // if it has a weather info, then do a closure
        if let weather = weatherInformation.weather.first {
            weatherDescriptionLabel.text = weather.description
        }
        tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))°C"
        minTempLabel.text = "\(Int(weatherInformation.temp.minTemp - 273.15))°C"
        maxTempLabel.text = "\(Int(weatherInformation.temp.maxTemp - 273.15))°C"
        
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func getCurrentWeather(cityName: String) {
        
//        let weatherKey = "f12b0398a849c20c1e6f84d3a449fd7b"

          guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=f12b0398a849c20c1e6f84d3a449fd7b")
            else { return }
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            
            guard let data = data, error == nil else { return }
            
            let decoder = JSONDecoder()
            
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                
                debugPrint(weatherInformation)
                
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
                
            } else {
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                debugPrint(errorMessage)
             
                DispatchQueue.main.async {
                    self?.showAlert(message: errorMessage.message)
                    
                }
            }
        }.resume()
        
        
        
    }
    
    func alamoeGetData(cityName: String, completionHandler: @escaping (Result<WeatherInformation, Error>) -> Void) {
        
        let url = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)"
        let param = [
            "appid" : "f12b0398a849c20c1e6f84d3a449fd7b"
        ]
        
        AF.request(url, method: .get, parameters: param)
            .validate()
            .responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(WeatherInformation.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        completionHandler(.failure(error))
                    }
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            }
    }
    
}

