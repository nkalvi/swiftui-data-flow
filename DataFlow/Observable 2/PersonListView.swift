//
//  PersonList.swift
//  DataFlow
//
//  Created by Sarah Reichelt on 14/09/2019.
//  Copyright © 2019 TrozWare. All rights reserved.
//

import SwiftUI

struct PersonListView: View {
    // Using an ObservedObject for reference-based data (classes)
    @ObservedObject var personList = PersonListModel()
    
    var body: some View {
        List {
            // To make the navigation link edits return to here,
            // the data sent must be a direct reference to an element
            // of the ObservedObject, not the closure parameter.
            
            // Thanks to Stewart Lynch (@StewartLynch) for suggesting using a function to
            // get a binding to the person so it coud be passed to the detail view.
            
            ForEach(personList.persons) { person in
                NavigationLink(destination:
                    PersonDetailView(person: self.selectedPerson(id: person.id))
                ) {
                    Text("\(person.first) \(person.last)")
                }
            }
            .onDelete { indexSet in
                // add this modifier to allow deleting from the list
                self.personList.persons.remove(atOffsets: indexSet)
            }
            .onMove { indices, newOffset in
                // add this modifier to allow moving in the list
                self.personList.persons.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
            
            // This runs when the view appears to load the initial data
            .onAppear(perform: { self.personList.fetchData() })
            
            // set up the navigation bar details
            // EditButton() is a standard View
            .navigationBarTitle("People")
            .navigationBarItems(trailing:
                HStack {
                    Button(action: { self.personList.refreshData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    Spacer().frame(width: 30)
                    EditButton()
                }
        )
    }
    
    func selectedPerson(id: UUID) -> Binding<PersonViewModel> {
        guard let index = self.personList.persons.firstIndex(where: { $0.id == id }) else {
            fatalError("This person does not exist.")
        }
        return self.$personList.persons[index]
    }
}

// To preview this with navigation, it must be embedded in a NavigationView
// but the main ContentView provides the main NavigationView
// so this view will only get its own when in Proview mode

struct PersonList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersonListView()
        }
    }
}

