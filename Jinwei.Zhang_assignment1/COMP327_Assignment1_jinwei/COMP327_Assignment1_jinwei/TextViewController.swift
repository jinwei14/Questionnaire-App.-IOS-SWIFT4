//
//  TextViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 28/10/2017.
//  Copyright © 2017 zjw. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreData

//this swift is associate with the text view controller
class TextViewController: UIViewController, UITextViewDelegate {

     //buttons labels and progress bar
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var commentField: UITextView!
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
        //use to let the keyboard dispear
        commentField.delegate = self
        
        //load the background image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background2")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        //loop through the questionnare user is current filling
        for item in (questionnarieResult?.questions!)!{
            
            if (item as! Question).type == "text"{
                //set the tile of the view controller
                self.navigationItem.title = (item as! Question).name
                
                //reset current title eg. from Q 1 to Q 2 or Q 3 to Q 4
                currentName = (item as! Question).name
                //the last positon off the String.
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
    
    // hide the keyboard when usr touch outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //this method check if user press the enter key and check if the character
    //number is greater than 5 and less than 100
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if (text == "\n") {
            commentField.resignFirstResponder()
            return false
        }
        //if the input character is greater 100 then remove the text
        if(commentField.text.count >= 100){
            commentField.text.removeAll()
            //no choice has been entered
            let alert = UIAlertController(title: "Error", message: "Should not comment more than 100 words", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
        return true
    }
    
//    //when the previous button is pressed move the last one in the answer array
//    override func viewWillDisappear(_ animated:Bool) {
//        super.viewWillDisappear(animated)
//
//        // check if the back button was pressed
//        if (self.isMovingFromParentViewController) {
//            if(nextButton.isSelected){
//                //delete the last element in the array
//                choosenCommentArray.removeLast()
//                print("remove last text answer")
//            }
//            nextButton.isSelected = false
//
//        }
//    }

     //move to the next view when clicked and check is this page is the last one 
    @IBAction func saveAndMoveToReport(_ sender: Any) {
        nextButton.isSelected = true
        //store the comment into inputComment
        inputComment = commentField.text
        if(commentField.text.count < 5){
            //no choice has been entered
            SVProgressHUD.showError(withStatus: "Please comment at least 5 characters")
            SVProgressHUD.dismiss(withDelay: 2)
            
        }else{
            choosenCommentArray.append(inputComment!)
            //check if this question is the last question. if yes save and generate the report
            //if not jump to the next question.
            if((questionnarieResult?.questions?.count)! > lastStringToInt!){
                //store the respond and put into instance
                
                //navigate to the the viewController
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: nextViewIdentifier!)
                
                // this method contain the activity of stack
                self.navigationController?.pushViewController(nextViewController!, animated: true)
                
                //if the last digit of the question name is greater or equal to
                //the number of the question
            }else{
                if(saveToCoreData() == true){
                    SVProgressHUD.showSuccess(withStatus: "Saving Done")
                    SVProgressHUD.dismiss(withDelay: 1)
                    //navigate to the the viewController
                    let nextViewController = self.storyboard?.instantiateViewController(withIdentifier:"ReportViewControllerID")
                    
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
}
