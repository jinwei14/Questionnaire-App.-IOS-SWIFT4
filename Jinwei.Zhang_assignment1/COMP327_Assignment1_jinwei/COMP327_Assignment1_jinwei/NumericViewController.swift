//
//  NumericViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 28/10/2017.
//  Copyright © 2017 zjw. All rights reserved.
//

import UIKit
import SVProgressHUD

//this swift is associate with the numeric view controller 
class NumericViewController: UIViewController {

    //buttons labels and progress bar
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var numberLable: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    //set the default blue colour to the button
    let brightRed = UIColor(displayP3Red: 0.0,
                            green: 122.0/255.0,
                            blue: 1.0,
                            alpha: 1.0)
    //varibales are used to convert the name of the question to be the
    //identifier of next view controller
    var plusOne:Int?
    var currentName: String?
    var nextName: String?
    var nextViewIdentifier:String?
    //this record the last int of the question
    var lastStringToInt:Int?
    
     //this method will called when the page is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //reset the choose number to 0
        chooseNumber = 0
        //load the background picture
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background2")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        // Do any additional setup after loading the view.
        //setup the color of the button border
        numberLable.text = "\(chooseNumber)"
        plusButton.layer.borderColor = brightRed.cgColor
        minusButton.layer.borderColor = brightRed.cgColor
        
         //loop through the questionnare user is current filling
        for item in (questionnarieResult?.questions!)!{
            
            if (item as! Question).type == "numeric"{
                //set the tile of the view controller
                self.navigationItem.title = (item as! Question).name
                
                //reset current title eg. from Q 1 to Q 2 from Q 3 to Q 4
                currentName = (item as! Question).name
                let indexEnd = currentName?.index((currentName?.endIndex)!, offsetBy: -1)
                let lastString = String(currentName![indexEnd!])
                //last int value of the question
                lastStringToInt = Int(lastString)
                let plusOne = String(Int(lastString)! + 1)
                if let index =  indexEnd{
                    currentName?.replaceSubrange(index...index, with: plusOne)
                }
                nextName = currentName
                
                //set the progress bar
                progressBar.setProgress(Float(lastString)!/4, animated: false)
                
                //set the diaplay label to question content
                displayLabel.text = (item as! Question).questionContent

                
            }
            
            
        }
        //assign the next dientifier so that it can load dynamically
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

    //triggered when the plus button is clicked
    @IBAction func plusOne(_ sender: Any) {
        chooseNumber += 1
        numberLable.text = "\(chooseNumber)"
    }
    
    //triggered when the minus button is clicked
    @IBAction func minusOne(_ sender: Any) {
        if(chooseNumber == 0){
            //no choice has been entered
            let alert = UIAlertController(title: "Error",
                                          message: "Number must greater than 0",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: UIAlertActionStyle.default,
                                          handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }else{
            chooseNumber -= 1
            numberLable.text = "\(chooseNumber)"
        }
    }
    
//
//    //when the previous button is pressed move the last one in the answer array
//    override func viewWillDisappear(_ animated:Bool) {
//        super.viewWillDisappear(animated)
//
//        // check if the back button was pressed
//        if (self.isMovingFromParentViewController) {
//            if(nextButton.isSelected){
//                //delete the last element in the array
//                choosenNumberArray.removeLast()
//                print("remove last numeric answer")
//            }
//            nextButton.isSelected = false
//
//        }
//    }

    
    //move to the next view when clicked and check is this page is the last one 
    @IBAction func moveNext(_ sender: Any) {
         nextButton.isSelected = true
        choosenNumberArray.append(String(chooseNumber))
        print(chooseNumber)
        //If the nextViewIdentifier exist which means this is not the last question,
        //this can use for implement multiple same type questions
        //check if this question is the last question. if yes save and generate the report
        //if not jump to the next question.
        if((questionnarieResult?.questions?.count)! > lastStringToInt!){
            //store the respond and put into instance
            
            //navigate to the the viewController
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier:
                nextViewIdentifier!)
            
            // this method contain the activity of stack
            self.navigationController?.pushViewController(nextViewController!, animated: true)
            
            //if the last digit of the question name is greater or equal to
            //the number of the questions
        }else{
            if(saveToCoreData() == true){
                SVProgressHUD.showSuccess(withStatus: "Saving Done")
                SVProgressHUD.dismiss(withDelay: 1)
                //navigate to the the viewController
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier:
                    "ReportViewControllerID")
                
                // this method contain the activity of stack
                let navController = UINavigationController(rootViewController: nextViewController!)
                // Creating a navigation controller with VC1 at the root of the navigation stack.
                self.present(navController, animated:true, completion: nil)
            }else{
                SVProgressHUD.showError(withStatus: "Saving Failed")
                SVProgressHUD.dismiss(withDelay: 1)
            }
        }
    }
}
