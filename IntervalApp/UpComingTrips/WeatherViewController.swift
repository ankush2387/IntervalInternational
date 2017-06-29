//
//  WeatherViewController.swift
//  IntervalApp
//
//  Created by Jhon Sanchez Garcia on 6/8/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit
import DarwinSDK

class WeatherViewController: UIViewController {
    
    
    var resortWeather: ResortWeather?
    let selectedButtonTextColor = UIColor.black
    var resortName: String?
    var countryCode: String?

    @IBOutlet weak var temperaureLowLabel: UILabel!
    @IBOutlet weak var temperatureHighLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var resortNameLabel: UILabel!
    @IBOutlet var highTempeartureBars: [VerticalProgressView]!
    @IBOutlet var LowTempeartureBars: [VerticalProgressView]!
    @IBOutlet weak var celsiusButton: UIButton!
    @IBOutlet weak var fahrenheitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // change Nav-bar tint color.
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 229.0/255.0, green: 231.0/255.0, blue: 228.0/255.0, alpha: 1.0)
        //Nav-bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(WeatherViewController.menuBackButtonPressed(_:)))
        doneButton.tintColor = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        self.navigationItem.rightBarButtonItem = doneButton
        
        setup()
        
    }
    
    func setup() {
        if let resortName = self.resortName {
            resortNameLabel.text = "\(resortName)"
        }
        
        if let countryCode = self.countryCode {
            resortNameLabel.text?.append(", \(countryCode)")
        }
        
        weatherConditionLabel.text = resortWeather?.condition
        
        self.displayFarenheit()
    
    }
    
    func displayCelsius() {
        if let temp = resortWeather?.temperature?.celsius {
            temperatureLabel.text = "\(temp)°"
        }
        
        if let monthAvg = resortWeather?.monthlyAverage {
            var i = 0
            var n = 0
            var highAvg = 0
            var lowAvg = 0
            for month in monthAvg {
                let progress = month.high?.celsius
                highAvg += progress!
                highTempeartureBars[i].progress = Float(progress!) / 100
                i += 1
            }
            
        
            for month in monthAvg {
                let progress = month.low?.celsius
                lowAvg += progress!
                LowTempeartureBars[n].progress = Float(progress!) / 100
                n += 1
            }
            
            self.temperatureHighLabel.text = "\(Int(highAvg/12))°"
            self.temperaureLowLabel.text = "\(Int(lowAvg/12))°"
        }
    }
    
    func displayFarenheit() {
        if let temp = resortWeather?.temperature?.fahrenheit {
            temperatureLabel.text = "\(temp)°"
        }
        
        if let monthAvg = resortWeather?.monthlyAverage {
            var i = 0
            var n = 0
            var highAvg = 0
            var lowAvg = 0
            for month in monthAvg {
                let progress = month.high?.fahrenheit
                highAvg += progress!
                highTempeartureBars[i].progress = Float(progress!) / 100
                i += 1
            }
            
            
            for month in monthAvg {
                let progress = month.low?.fahrenheit
                lowAvg += progress!
                LowTempeartureBars[n].progress = Float(progress!) / 100
                n += 1
            }
            
            self.temperatureHighLabel.text = "\(Int(highAvg/12))°"
            self.temperaureLowLabel.text = "\(Int(lowAvg/12))°"
        }
    }
    
    @IBAction func didPressCelsiusButton(_ sender: Any) {
        self.fahrenheitButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
        self.celsiusButton.setTitleColor(selectedButtonTextColor, for: .normal)
        
        displayCelsius()
    }
    @IBAction func didPressFahrenheitButton(_ sender: Any) {
        self.fahrenheitButton.setTitleColor(selectedButtonTextColor, for: .normal)
        self.celsiusButton.setTitleColor(UIColor.init(colorLiteralRed: 0, green: 122/255, blue: 255/255, alpha: 1.0), for: .normal)
        
        displayFarenheit()
    }
    
    func menuBackButtonPressed(_ sender:UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



extension UIViewController {
    func displayWeatherView(resortCode: String, resortName: String, countryCode: String, completionHandler: @escaping (_ response: Bool) -> Void) {
        
        DirectoryClient.getResortWeather(Constant.MyClassConstants.systemAccessToken, resortCode: resortCode, onSuccess: { (response) in
            if let weatherResponse = response as? ResortWeather {
                let storyboard = UIStoryboard(name: "MyUpcomingTripIphone", bundle: nil)
                let mapDetailsNav = storyboard.instantiateViewController(withIdentifier: "weatherNav") as! UINavigationController
                let weatherVC = mapDetailsNav.viewControllers.first as? WeatherViewController
                weatherVC?.resortWeather = weatherResponse
                weatherVC?.countryCode = countryCode
                weatherVC?.resortName = resortName
                self.present(mapDetailsNav, animated: true, completion: nil)
                completionHandler(true)
            }
            
            
        }) { (error) in
            completionHandler(false)
            print(error)
            SimpleAlert.alert(self, title: "Error", message: "Something went wrong. Please try again.")
            
        }

    }
}
