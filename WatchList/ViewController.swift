//
//  ViewController.swift
//  WatchList
//
//  Created by Stephanie on 4/20/20.
//  Copyright © 2020 Stephanie Chiu. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var movieTitle: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Before using/accessing CoreData, call AppDelegate and get reference to its persistent container to access NSManagedObjectContext
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Fetch results have several qualifiers, including NSEntityDescription, used to refine the set of results returned. The init(entityName:) fetches all objects of the specific entity. **Note that NSFetchRequest  is a generic type that specifies a fetch request's expected return type (in this case NSManagedObject)
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Movie")
        
        // fetch(_:) returns an array of managed objects meeting the criteria specified by the fetch request
        do {
            movieTitle = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name", message: "Add a new show/movie", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            self.save(name: nameToSave)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter First Name"
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func save(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        // Creates new managed object where changes made by the user are commited to the managed object context and saved to CoreData. The managed object context lives as a property of the NSPersistentCOntainer in AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // The new managed object is inserted into the managed object context via entity(forEntityName:in:)
        let entity = NSEntityDescription.entity(forEntityName: "Movie", in: managedContext)!
        let titles = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // The title attribute is set using key-value coding (KVC) exactly as it appears in the Data Model
        titles.setValue(name, forKey: "title")
        
        // Changes to "title" are committed and saved to disk by calling save on the managed object context. The new managed object is inserted into the title movieTitle array so it shows when the table view reloads
        do {
            try managedContext.save()
            movieTitle.append(titles)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return movieTitle.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let title = movieTitle[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//    cell.textLabel?.text = names[indexPath.row]
    
    //title attribute from NSManagedObject will be called here
    cell.textLabel?.text = title.value(forKeyPath: "title") as? String
                    
    return cell
  }
}


