//
//  SingleOptionViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 20/10/2017.
//  Copyright © 2017 zjw. All rights reserved.
//

import UIKit
import SVProgressHUD

//this swift is associate with the single view controller 
class SingleOptionViewController: UIViewController {
    
    
    @IBOutlet weak var nextButton: UIButton!
    //add four options (button) as IBoutlet
    @IBOutlet weak var button1: DLRadioButton!
    @IBOutlet weak var button2: DLRadioButton!
    @IBOutlet weak var button3: DLRadioButton!
    @IBOutlet weak var button4: DLRadioButton!
    @IBOutlet weak var button5: DLRadioButton!
    //display label and progress bar
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    //varibales are used to convert the name of the question to be the identifier
    //of next view controller
    var currentName: String?
    var nextName: String?
    var nextViewIdentifier:String?
    var lastStringToInt:Int?
    
    //this method will called when the page is loaded
    override func viewDidLoad() {
        
        //reset the choosen option to default
        choosenSingle = 0
        super.viewDidLoad()
        
        //set up the background
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background2")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        //hide all the button first
        button1.isHidden = true
        button2.isHidden = true
        button3.isHidden = true
        button4.isHidden = true
        button5.isHidden = true
        
        //loop through the questionnare user is current filling
        for item in (questionnarieResult?.questions!)!{
            
            if (item as! Question).type == "single-option"{
                //set the tile of the view controller
                self.navigationItem.title = (item as! Question).name
                
                //reset current name eg. from question1 to question2
                currentName = (item as! Question).name
                let indexEnd = currentName?.index((currentName?.endIndex)!, offsetBy: -1)
                let lastString = String(currentName![indexEnd!])
                lastStringToInt = Int(lastString)
                let plusOne = String(lastStringToInt! + 1)
                if let index =  indexEnd{
                    currentName?.replaceSubrange(index...index, with: plusOne)
                }
                nextName = currentName
                
                //set the progress bar to current progress
                progressBar.setProgress(Float(lastString)!/4, animated: true)
                
                //set the display label to the corresponding text
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
            
            //assign the next dientifier
            for item in (questionnarieResult?.questions!)!{
                if (item as! Question).name == nextName {
                    nextViewIdentifier = (item as! Question).type
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //trigger the event when any of the button is toggled
    @IBAction func change(sender: UIButton) {
        
        switch sender {
        case button1:
            choosenSingle = 1
            print ("Choose 1")
        case button2:
            choosenSingle = 2
            print ("Choose 2")
        case button3:
            choosenSingle = 3
            print ("Choose 3")
        case button4:
            choosenSingle = 4
            print ("Choose 4")
        case button5:
            choosenSingle = 5
            print ("Choose 5")
        default:
            break
            
        }
        
    }
    
    //trigger the event when the move next button is clicked
    @IBAction func moveNext(_ sender: UIButton) {
        //no choice has been entered
        nextButton.isSelected = true
        if(choosenSingle == 0){
            SVProgressHUD.showError(withStatus: "Please select at least one option")
            SVProgressHUD.dismiss(withDelay: 2)
        }else{
            choosenSingleArray.append(String(choosenSingle))
            //check if this question is the last question. if yes save and generate the report
            //if not jump to the next question.
            if((questionnarieResult?.questions?.count)! > lastStringToInt!){
                //store the respond and put into instance
                
                //navigate to the the viewController
                let nextViewController = self.storyboard?.instantiateViewController(
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
                    let nextViewController = self.storyboard?.instantiateViewController(
                        withIdentifier:"ReportViewControllerID")
                    
                    // this method contain the activity of stack
                    let navController = UINavigationController(
                        rootViewController: nextViewController!)
                    // Creating a navigation controller with VC1 at the root of
                    //the navigation stack.
                    self.present(navController, animated:true, completion: nil)
                }else{
                    SVProgressHUD.showError(withStatus: "Saving Failed")
                    SVProgressHUD.dismiss(withDelay: 1)
                }
                
                
            }
        }
        
    }
    
}


