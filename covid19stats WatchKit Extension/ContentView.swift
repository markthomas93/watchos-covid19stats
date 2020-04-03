//
//  ContentView.swift
//  covid19stats WatchKit Extension
//
//  Created by Kyle Jones on 4/1/20.
//  Copyright © 2020 Kyle Jones. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: CountriesController
    @State var isDetailViewPresented = false
    
    var body: some View {
        List {
            ForEach(model.countries, id: \.id) { country in
                NavigationLink(destination: CountryDetailView(model: self.model, country: country)) {
                    VStack(alignment: .leading) {
                        Text(country.name)
                        Text(country.cases?.total.description ?? "--")
                    }
                }
            }
            .onMove(perform: { self.model.countries.move(fromOffsets: $0, toOffset: $1)})
            .onDelete(perform: {
                if self.model.countries[$0.first!].name != "All" {
                    self.model.countries.remove(atOffsets: $0)
                }
            })
            
            Button(action: {
                self.isDetailViewPresented = true
            }) {
                Text("Add Country")
            }
            .sheet(isPresented: self.$isDetailViewPresented) {
                AddCountrySheet(model: self.model, isDetailViewPresented: self.$isDetailViewPresented)
            }
        }
        .onAppear {
            self.model.updateAllStats()
        }
    }
}

struct CountryDetailView: View {
    var model: CountriesController
    var country: Country
    
    var body: some View {
        VStack {
            Text(country.name)
            Text(country.cases?.total.description ?? "--")
        }
        .navigationBarTitle(country.name)
    }
}

struct AddCountrySheet: View {
    var model: CountriesController
    @Binding var isDetailViewPresented: Bool
    
    var body: some View {
        List {
            ForEach(model.namesOfCountries, id: \.self) { countryName in
                Button(action: {
                    self.model.addNewCountry(name: countryName)
                    self.isDetailViewPresented = false
                }) {
                    Text(countryName)
                }
            }
        }
        
    }
}

