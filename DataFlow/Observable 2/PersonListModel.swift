//
//  PersonsModel.swift
//  DataFlow
//
//  Created by Sarah Reichelt on 14/09/2019.
//  Copyright © 2019 TrozWare. All rights reserved.
//

import Foundation

class PersonListModel: ObservableObject {
    // Main list view model
    @Published var ids: [UUID] = []
    @Published var persons: [UUID : PersonModel] = [:]
    
    func fetchData() {
        // avoid too many calls to the API
        if persons.count > 0 { return }
        
        let address = "https://next.json-generator.com/api/json/get/VyQroKB8P?indent=2"
        guard let url = URL(string: address) else {
            fatalError("Bad data URL!")
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data")
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601
                let dataArray = try jsonDecoder.decode([PersonModel].self, from: data)
                DispatchQueue.main.async { [self] in
                    persons = Dictionary( uniqueKeysWithValues: dataArray.map { ($0.id, $0) })
                    sortIds()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func refreshData() {
        ids = []
        persons = [:]
        fetchData()
    }
    
    func sortIds() {
        ids = persons.values.sorted {
            $0.last + $0.first < $1.last + $1.first
        }.map { $0.id }
    }
    
    init() {
        refreshData()
    }
}


class PersonModel: Identifiable, ObservableObject, Codable {
    // Basic model for decoding from JSON
    
    let id: UUID
    var first: String
    var last: String
    var phone: String
    var address: String
    var city: String
    var state: String
    var zip: String
    let registered: Date
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        first = try values.decode(String.self, forKey: .first)
        last = try values.decode(String.self, forKey: .last)
        phone = try values.decode(String.self, forKey: .phone)
        registered = try values.decode(Date.self, forKey: .registered)
        
        // split up address into separate lines for easier editing
        let addressData = try values.decode(String.self, forKey: .address)
        let addressComponents = addressData.components(separatedBy: ", ")
        address = addressComponents[0]
        city = addressComponents[1]
        state = addressComponents[2]
        zip = addressComponents[3]
    }
}

// Extension to force un-wrap a Dictionary value which is normally an optional.
// This is so it can be used to create a Binding.
extension Dictionary where Key == UUID, Value == PersonModel {
    subscript(unchecked key: Key) -> Value {
        get {
            guard let result = self[key] else {
                fatalError("This person does not exist.")
            }
            return result
        }
        set {
            self[key] = newValue
        }
    }
}
