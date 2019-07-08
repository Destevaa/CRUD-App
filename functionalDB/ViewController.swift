//
//  ViewController.swift
//  functionalDB
//
//  Created by Mary Celina Louise S. Esteva on 30/06/2019.
//  Copyright © 2019 Desteva. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {

    var database: Connection!
    let usersTable = Table("users")
    let id = Expression<Int>("id")
    let name = Expression<String?>("name")
    let email = Expression<String>("email")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        do{
    
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("users").appendingPathExtension("sqlite3")
            
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch{
            print(error)
        }
    }
    
    @IBAction func createTable(){
        print("Create Tapped")
        
        let createTable = self.usersTable.create { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.email, unique: true)
        }
        
        do {
            try self.database.run(createTable)
            print("Created Table")
        } catch{
            print(error)
        }
        
    }

    @IBAction func insertUser() {
        print("Insert Tapped")
        let alert = UIAlertController(title: "Insert User", message: nil, preferredStyle: .alert); alert.addTextField { (tf) in tf.placeholder = "Name" }
            alert.addTextField { (tf) in tf.placeholder = "Email" }
        
        let action = UIAlertAction(title: "Submit", style: .default) {
            (_) in
            guard let name = alert.textFields?.first?.text,
            let email = alert.textFields?.last?.text
                else { return }
            print(name)
            print(email)
            
            let insertUser = self.usersTable.insert(self.name <- name, self.email <- email)
            do {
                try self.database.run(insertUser)
                print("INSERTED USER")
            } catch{
                
            }
            
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func listUsers(){
        print("LIST TAPPED")
        
        do {
            let users = try self.database.prepare(self.usersTable)
            print(users)
            for user in users {
                print("userId: \(user[self.id]), name: \(user[self.name]), email \(user[self.email])")
            }
        } catch {
            print(error)
        }
        
    }
    
    @IBAction func updateUsers(){
        print("Update Tapped")
        let alert = UIAlertController(title: "Update User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "User ID" }
        alert.addTextField { (tf) in tf.placeholder = "Email" }
        
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIdString = alert.textFields?.first?.text,
            let userId = Int(userIdString),
            let email = alert.textFields?.last?.text
            else{ return }
                print(userIdString)
                print(email)
            let user = self.usersTable.filter(self.id == userId)
            let updateUser = user.update(self.email <- email)
            do
            {
               try self.database.run(updateUser)
            }catch{
                print(error)
            }
            
            
            
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func deleteUser(){
        print("Delete Tapped")
        let alert = UIAlertController(title: "Delete User", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in tf.placeholder = "User ID" }
        let action = UIAlertAction(title: "Submit", style: .default) { (_) in
            guard let userIdString = alert.textFields?.first?.text,
            let userId = Int(userIdString)
                else { return }
            print(userIdString)
            
            let user = self.usersTable.filter(self.id == userId)
            let deleteUser = user.delete()
            do{
                try self.database.run(deleteUser)
            } catch{
                print(error)
            }
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    

}

