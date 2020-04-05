//
//  CountriesController.swift
//  covid19stats WatchKit Extension
//
//  Created by Kyle Jones on 4/2/20.
//  Copyright © 2020 Kyle Jones. All rights reserved.
//

import Foundation
import Combine

final class CountriesController: ObservableObject {
    
    let objectWillChange = ObservableObjectPublisher()
    
    @Published var countries: [Country]
    @Published var namesOfCountries: [String]
    
    init() {
        self.countries = []
        self.namesOfCountries = []
        self.getCountryNames()
        self.updateAllStats()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(countryUpdated), name: Notification.Name("Country Updated"), object: nil)
    }
    
    @objc private func countryUpdated() {
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func getCountryNames() {
        self.getCountriesJSON { (result) in
            switch result {
            case .success(let json):
                let response = json["response"] as! Array<String>
                self.namesOfCountries = response
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getCountriesJSON(completionHandler: @escaping (Result<[String: Any], Error>) -> Void) {
        //self.namesOfCountries += ["China", "South Korea", "USA", "Italy"]
        let url = URL(string: "https://covid-193.p.rapidapi.com/countries")!
        let headers = [
            "x-rapidapi-host": "covid-193.p.rapidapi.com",
            "x-rapidapi-key": ConfigString.rapidApiKey.rawValue
        ]
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    completionHandler(.failure(NetworkError.badResponseCode(response)))
                    return
            }
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completionHandler(.success(json))
                }
            }
               
        }
        task.resume()
        
    }
    
    public func updateAllStats() {
        var updatedCountries = [Country]()
        for country in self.countries {
            country.updateStats()
            updatedCountries.append(country)
        }
        self.countries = updatedCountries
        
    }
    
    public func addNewCountry(name: String) {
        let newCountry = Country(name: name)
        self.countries.append(newCountry)
        newCountry.updateStats()
    }
    
}
