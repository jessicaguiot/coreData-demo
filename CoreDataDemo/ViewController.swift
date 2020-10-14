//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Jéssica Araujo on 14/10/20.
//  Copyright © 2020 academy. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Data for table
    var items: [Person]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setTableViewDelegate()
        
        //Get items from Core Data
        fetchPeople()
    }
    
    //Setting relationships between entities 
    func relationshipDemo() {
        
        //Create Family
        let family  = Family(context: context)
        family.name = "Guiot Family"
        
        //Create Person
        let person = Person(context: context)
        person.name = "Narlon"
        
        //add person to family
        family.addToPeople(person)
    
        //Save Context
        saveTheData()
    }
    
    
    //Retrieve Data
    func fetchPeople() {
        
        do {
            
            let resquest = Person.fetchRequest() as NSFetchRequest<Person>
            
            //Set the filtering and sorting on the request
            
            //let predicate = NSPredicate(format: "name CONTAINS %@", "Ted")
            //resquest.predicate = predicate
            
            let sort = NSSortDescriptor(key: "name", ascending: true)
            resquest.sortDescriptors = [sort]
            
            self.items = try context.fetch(resquest)
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
            
        } catch {
            
            print(error.localizedDescription)
        }
    }
    
    //Create
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            //Get the textfield for the alert
            guard let textField = alert.textFields?[0] else { return }
            
            //Create a person object
            let newPerson = Person(context: self.context)
            newPerson.name = textField.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            //Save the data
            self.saveTheData()
            
            //Re-fetch the data
            self.fetchPeople()
        }
        
        alert.addAction(submitButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTheData() {
        
        do {
                      
            try self.context.save()
        } catch {
                      
            print(error.localizedDescription)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setTableViewDelegate() {
        
        tableView.dataSource    = self
        tableView.delegate      = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: "personNameCell", for: indexPath)
        
        let person = self.items![indexPath.row]
        
        tableViewCell.textLabel?.text = person.name
        
        return tableViewCell
    }
    
    //Update
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Selected person
        let person = self.items![indexPath.row]
        
        //Create alert
        let alert = UIAlertController(title: "Edit Person", message: "Edit name: ", preferredStyle: .alert)
        alert.addTextField()
        
        //Show the
        let textField = alert.textFields?[0]
        textField?.text = person.name
        
        //Configure button handler
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            let inputTextField = alert.textFields?[0]
            
            //Edit name property of person object
            person.name = inputTextField?.text
            
            //Save the data
            self.saveTheData()
            
            //Re-fetch the data
            self.fetchPeople()
        }
        
        alert.addAction(saveButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //Delete
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            //Which person to remove
            let personToRemove = self.items![indexPath.row]
            
            //Remove the person
            self.context.delete(personToRemove)
            
            //Save the data
            self.saveTheData()
            
            //Re-fetch the data
            self.fetchPeople()
        }
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}
