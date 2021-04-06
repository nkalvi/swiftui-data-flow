#  Alternate Solution Using PersonModel without PersonViewModel
2021-04-05


## Changes to PersonListModel

- Removed PersonViewModel
- Converted PersonModel to a class: `class PersonModel: Identifiable, ObservableObject, Codable`
- Since the list itself (`@Published var persons: [UUID : PersonModel] = [:]`) is published and observed, properties of PersonModel need not to be `@Published`
- Changed the Dictionary extension condition to PersonModel instead.
- Updated `fetchData()` to use only PersonModel
- Moved sorting of `ids` to separate method


## Changes to PersonListView
- Updated to use PersonModel instead of PersonViewModel


## Changes to PersonDetailView

- Very minor:  `.autocapitalization(.words)` added to form and removed from individual fields.


## Changes to PersonVMTestData

- Updated to use PersonModel


