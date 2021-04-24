//
//  ViewController.swift
//  HitList
//
//  Created by İstemihan Çelik on 24.04.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var people: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1 Before you can do anything with Core Data, you need a managed object context. Fetching is no different! Like before, you pull up the application delegate and grab a reference to its persistent container to get your hands on its
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2 As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data. You can use fetch requests to fetch a set of objects meeting the provided criteria (i.e. give me all employees living in Wisconsin and have been with the company at least three years), individual values (i.e. give me the longest name in the database) and more.
        //Fetch requests have several qualifiers used to refine the set of results returned. For now, you should know NSEntityDescription is one of these required qualifiers.
        
        // Setting a fetch request’s entity property, or alternatively initializing it with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities. Also note NSFetchRequest is a generic type. This use of generics specifies a fetch request’s expected return type, in this case NSManagedObject.
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        //3 You hand the fetch request over to the managed object context to do the heavy lifting. fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request.
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch \(error)")

        }
    }
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        //1 You can consider a managed object context as an in-memory “scratchpad” for working with managed objects. Think of saving a new managed object to Core Data as a two-step process: first, you insert a new managed object into a managed object context; once you’re happy, you “commit” the changes in your managed object context to save it to disk.
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2 You create a new managed object and insert it into the managed object context, An entity description is the piece linking the entity definition from your Data Model with an instance of NSManagedObject at runtime.
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        //3 With an NSManagedObject in hand, you set the name attribute using key-value coding. You must spell the KVC key (name in this case) exactly as it appears in your Data Model, otherwise, your app will crash at runtime.
        person.setValue(name, forKeyPath: "name")
        
        //4ou commit your changes to person and save to disk by calling save on the managed object context. Note save can throw an error, which is why you call it using the try keyword within a do-catch block. Finally, insert the new managed object into the people array so it shows up when the table view reloads.
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save \(error)")
        }
        
    }

    @IBAction func addItem(_ sender: Any) {
        let alert = UIAlertController(title: "New Name", message: "Add a new name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self ] action in
            guard let textField = alert.textFields?.first,
                  let nameToSave = textField.text else {
                return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        }
    }
    

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let person = people[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        //Deleting by swipe left and deleting from disk as well
        if editingStyle == .delete {
            let person = people[indexPath.row]
            appDelegate.persistentContainer.viewContext.delete(person)
            people.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            appDelegate.persistentContainer.viewContext.delete(person)
            appDelegate.saveContext()
            
            self.tableView.reloadData()
        }
    }
    
}


