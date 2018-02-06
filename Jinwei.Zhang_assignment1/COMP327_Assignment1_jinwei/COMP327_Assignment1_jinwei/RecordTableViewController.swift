//
//  RecordTableViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 05/11/2017.
//  Copyright © 2017 zjw. All rights reserved.
//

import UIKit
import CoreData
var searchResult:[Questionnaire]?
var chooseOne:Int?

//this class display the questionnare which is already in the core data
class RecordTableViewController: UITableViewController {
    
    @IBOutlet var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fetch the result from the core fata
        let fetchRequestQuestionnaire:NSFetchRequest<Questionnaire> = Questionnaire.fetchRequest();
        do{
            searchResult = try context?.fetch(fetchRequestQuestionnaire)
            
        }catch{
            print("Couldn't fetch results")
        }
        myTable.reloadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the
        //navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    //can selected one row and jump to the data table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    //return the number of the questionnaires
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of the rows which is the number of the questionnaire
        return (searchResult?.count)!
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "myCell")
        
        cell.textLabel?.text = (searchResult![indexPath.row] as Questionnaire).questionnaireID
        // Configure the cell...
        return cell
    }
    
    //if one row is been selected then move to the data table view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //make sure the row selected is within boudary
        if indexPath.row <= (searchResult?.count)! {
            chooseOne = indexPath.row
            self.performSegue(withIdentifier: "moveToData", sender: self)
        }
        
    }
    
    
}
