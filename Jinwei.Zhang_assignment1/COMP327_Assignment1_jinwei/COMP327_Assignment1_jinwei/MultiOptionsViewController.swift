//
//  MultiOptionsViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 28/10/2017.
//  Copyright © 2017 zjw. All rights reserved.
//

import UIKit
import SVProgressHUD

//this swift is associate with the multiple view controller 
class MultiOptionsViewController: UIViewController {
    
    @IBOutlet weak var nextButton: UIButton!
    //add four options (button) as IBoutlet
    @IBOutlet weak var button1: DLRadioButton!
    @IBOutlet weak var button2: DLRadioButton!
    @IBOutlet weak var button3: DLRadioButton!
    @IBOutlet weak var button4: DLRadioButton!
    @IBOutlet weak var button5: DLRadioButton!
    //labels and progress bar
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    //varibales are used to convert the name of the question to be the
    //identifier of next view controller
    var currentName: String?
    var nextName: String?
    var nextViewIdentifier:String?
    var lastStringToInt:Int?
    
    //this method will called when the page is loaded
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //remove all the element after each load
        choosenMuti.removeAll()
        
        //load the back ground image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background2")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        //enable multiple selection since all the button are linked
        button1.isMultipleSelectionEnabled = true
        
        //hide all the button first
        button1.isHidden = true
        button2.isHidden = true
        button3.isHidden = true
        button4.isHidden = true
        button5.isHidden = true
        
        //loop through the questionnare user is current filling
        for item in (questionnarieResult?.questions!)!{
            
            if (item as! Question).type == "multi-option"{
                //set the tile of the view controller
                self.navigationItem.title = (item as! Question).name
                
                //reset current title eg. from "question-1" to "question-2"
                currentName = (item as! Question).name
                let indexEnd = currentName?.index((currentName?.endIndex)!, offsetBy: -1)
                let lastString = String(currentName![indexEnd!])
                lastStringToInt = Int(lastString)
                let plusOne = String(lastStringToInt! + 1)
                if let index =  indexEnd{
                    currentName?.replaceSubrange(index...index, with: plusOne)
                }
                nextName = currentName
                
                //set the progress bar
                progressBar.setProgress(Float(lastString)!/4, animated: false)
                
                //set the diaplay label to question content 
                displayLabel.text = (item as! Question).questionContent
                let choiceSet = (item as! Question).choices
                
                //set the button to corresponding text and determine whether
                //this button should appear
                for choice in choiceSet!{
                    if(choice as! Choices).value == 1 {
                        button1.setTitle((choice as! Choices).label, for: .normal)
                        button1.isHidden = false
                    }
                    if(choice as! Choices).value == 2 {
                        button2.setTitle((choice as! Choices).label, for: .normal)
                        button2.isHidden = false
                    }
                    if(choice as! Choices).value == 3 {
                        button3.setTitle((choice as! Choices).label, for: .normal)
                        button3.isHidden = false
                    }
                    if(choice as! Choices).value == 4 {
                        button4.setTitle((choice as! Choices).label, for: .normal)
                        button4.isHidden = false
                    }
                    if(choice as! Choices).value == 5 {
                        button5.setTitle((choice as! Choices).label, for: .normal)
                        button5.isHidden = false
                    }
                    
                }
                
            }
            
        }
        
        //assign the next dientifier 
        for item in (questionnarieResult?.questions!)!{
            if (item as! Question).name == nextName {
                nextViewIdentifier = (item as! Question).type
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //trigger the event when any of the button is toggled
    @IBAction func changeMuti(sender: UIButton) {
        switch sender {
        case button1:
            print ("Choose 1")
        case button2:
            print ("Choose 2")
        case button3:
            print ("Choose 3")
        case button4:
            print ("Choose 4")
        case button4:
            print ("Choose 4")
        default:
            break
        }
    }
    
    //append the anser into the chooseMuti array if the button is selected
    func checkAnswer(){
        choosenMuti.removeAll()
        if(button1.isSelected){
            choosenMuti.append(1)
        }
        if(button2.isSelected){
            choosenMuti.append(2)
        }
        if(button3.isSelected){
            choosenMuti.append(3)
        }
        if(button4.isSelected){
            choosenMuti.append(4)
        }
        if(button5.isSelected){
            choosenMuti.append(5)
        }
        print(choosenMuti)
    }
    
    //    //when the previous button is pressed move the last one in the answer array
    //    override func viewWillDisappear(_ animated:Bool) {
    //        super.viewWillDisappear(animated)
    //
    //        // check if the back button was pressed
    //        if (self.isMovingFromParentViewController) {
    //            if(nextButton.isSelected){
    //                //delete the last element in the array
    //                choosenMutiArray.removeLast()
    //                print("remove last multi answer")
    //            }
    //            nextButton.isSelected = false
    //
    //        }
    //    }
    
    //trigger the even when the next button is pressed
    @IBAction func moveNext(_ sender: Any) {
        nextButton.isSelected = true
        checkAnswer()
        if(choosenMuti.count == 0){
            //no choice has been entered
            SVProgressHUD.showError(
                withStatus: "Please select at least one option")
            SVProgressHUD.dismiss(withDelay: 2)
        }else{
            
            //matain the data in the answer array
            var choiceString = ""
            for choice in choosenMuti {
                choiceString = choiceString + String(choice)
            }
            choosenMutiArray.append(choiceString)
            //check if this question is the last question.
            //if yes save and generate the report
            //if not jump to the next question.
            if((questionnarieResult?.questions?.count)! > lastStringToInt!){
                //store the respond and put into instance
                
                //navigate to the the viewController
                let nextViewController =
                    self.storyboard?.instantiateViewController(
                        withIdentifier: nextViewIdentifier!)
                
                // this method contain the activity of stack
                self.navigationController?.pushViewController(
                    nextViewController!, animated: true)
                
                //if the last digit of the question name is greater or equal to
                //the number of the question
            }else{
                if(saveToCoreData() == true){
                    SVProgressHUD.showSuccess(withStatus: "Saving Done")
                    SVProgressHUD.dismiss(withDelay: 1)
                    //navigate to the the viewController
                    let nextViewController =
                        self.storyboard?.instantiateViewController(
                            withIdentifier:"ReportViewControllerID")
                    
                    // this method contain the activity of stack
                    let navController = UINavigationController(
                        rootViewController: nextViewController!)
                    // Creating a navigation controller with VC1 at the root
                    //of the navigation stack.
                    self.present(navController, animated:true, completion: nil)
                }else{
                    SVProgressHUD.showError(withStatus: "Saving Failed")
                    SVProgressHUD.dismiss(withDelay: 1)
                }
            }
        }
    }
}
