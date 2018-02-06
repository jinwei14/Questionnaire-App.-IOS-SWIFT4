//
//  RecordTableViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 05/11/2017.
//  Copyright © 2017 zjw. All rights reserved.
//

import UIKit
import CoreData

//this class will display the questions in the selected questionnaire
//and the times of the completion
class DataTableViewController: UITableViewController {
    //use to return the number of the row
    var numberOfQuestions = 0
    var cellContent: [String] = []
    var cellNumber: [Int] = []
    @IBOutlet var myTable: UITableView!
    
    //call this method when DataTableViewComtroller appear
    override func viewDidLoad() {
        super.viewDidLoad()
 
        questionnarieResult = searchResult![chooseOne!] as Questionnaire
        //store the number of the questions
        numberOfQuestions = ((questionnarieResult?.questions!)?.count)!
        
        for item in (questionnarieResult?.questions!)!{
            //apprnd the question content to the array
            cellContent.append((item as! Question).questionContent!)
            
            if(searchResultResponses?.count == 0){
                //no data in the core data do not have to display
            }else{
                var counter = 0
                //loop through the response in the core data
                for response in searchResultResponses! {
                    
                    //find the same result in this questinnaire
                    if(response as Responses).questionnaireID ==
                        questionnarieResult?.questionnaireID
                        && (response as Responses).questionName ==
                        (item as! Question).type{
                        counter += 1;
                    }
                    //store the number of times been answered
                   
                }
             cellNumber.append(counter)
            }
            
        }

        //reset the cell height
        myTable.estimatedRowHeight = 100
        myTable.rowHeight = UITableViewAutomaticDimension

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //return the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int {
        // return the number of the rows which is the number of the questionnaire
        return numberOfQuestions
        
    }
    
    //load the content in the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell")!
            as UITableViewCell

        // Configure the cell...
        let timesView = cell.viewWithTag(2) as! UILabel
        let textView = cell.viewWithTag(1) as! UITextView
        
        //put the question content in the text view in each cell
        textView.text = cellContent[indexPath.row]
        if(cellNumber.count != 0){
            //put the time been completed in the label in each cell
          timesView.text = String(cellNumber [indexPath.row])
        } else{
            //if no one has filled in the questionnaires yet.
            timesView.text = "0"
        }
        return cell
    }
    

    
}

