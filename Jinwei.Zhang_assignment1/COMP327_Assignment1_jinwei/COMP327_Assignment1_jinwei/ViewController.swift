//
//  ViewController.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 20/10/2017.
//  Copyright © 2017 zjw. All rights reserved.
//
import UIKit
import CoreData
import SVProgressHUD

//set the questionnarieResult as gloable varibale so that it can be used
//through out differnct swift classes
var questionnarieResult:Questionnaire?
var context: NSManagedObjectContext?
var searchResultResponses: [Responses]?
//the choice of the single choice option and the array to store answer of same type
var choosenSingle = 0
var choosenSingleArray = [String]()
//the choice for the mutiple choice and the array to store answer of same type
var choosenMuti = [Int]()
var choosenMutiArray = [String]()
//the choice for the number and the array to store answer of same type
var chooseNumber = 0
var choosenNumberArray = [String]()
//the input comment entered by user and the array to store answer of same type
var inputComment:String?
var choosenCommentArray = [String]()

//this controller is the first controlle class - home page
class ViewController: UIViewController {
    //json result varibales used to store the json file from URL
    var jsonResult:AnyObject?
    //questionnaire entity used as a temperary variable to store in core data and
    //store data from core data
    var questionnarie:Questionnaire?
    var question : Question?
    var choices: Choices?
    var response:Responses?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //URL link
    var URL_1 =
    "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/assignments/questionnaire.json"
    var URL_2 =
    "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP327/assignments/questionnaire2.json"
    var numberExist: Int?
    //counter of the new questionnare index
    var counter = 2
    //first button is for loadin the questionnaire 1 from core data
    @IBAction func questionnaireButton1(_ sender: Any) {
        
       fetchJsonDataFromCore(index: 0)
    }
    
    //second button is for loading the questionnaire 2 from core data
    @IBAction func questionnaire2Button(_ sender: Any) {
    
        fetchJsonDataFromCore(index: 1)
    }
    
    //add button is for add more questionnare into core data and it will
    //appear sooner after hit the confirm buttom
    @IBAction func addQuestionnaire(_ sender: Any) {
        let alertController = UIAlertController(title: "Questionnaire",
                                                message: "Please input new questionnaire URL:",
                                                preferredStyle: .alert)
        
        //if user press the confirm button.
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            if let field = alertController.textFields?[0] {
                // store the link
                let newURL = field.text
                //load a new data into core data
                if(self.loadJsonfile(address: newURL!)){
                    //load json file and present by show up the view controller.
                    self.fetchJsonDataFromCore(index: self.counter)
                }
                
            } else {
                //user did not fill field
            }
        }
        
        //cancel button on the alert input box
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        //place holder
        alertController.addTextField { (textField) in
            textField.placeholder = "questionnaire address"
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        //present the input alert box
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //load the json form the core data and present them in the
    //coorespond view controller.
    func fetchJsonDataFromCore(index:Int){
        //the identifier of the next view
        var identifier:String?
        //fetch result from core data
        let fetchRequestQuestionnaire:NSFetchRequest<Questionnaire> =
            Questionnaire.fetchRequest();
        do{
            let searchResult = try context?.fetch(fetchRequestQuestionnaire)
            if searchResult?.isEmpty == false {
                
                //declear the latest one added and present afterwords if no
                //error happened.
                if(index == 2){
                    questionnarieResult = searchResult![(searchResult?.count)!-1]
                        as Questionnaire
                }else{
                    // give a signal to the user
                    SVProgressHUD.showSuccess(withStatus: "questionnaire load success")
                    SVProgressHUD.dismiss(withDelay: 1)
                    questionnarieResult = searchResult![index] as Questionnaire
                }
                
                for item in (questionnarieResult?.questions!)!{
                    //jump to the question one of the second questionnaire dynamically
                    if (item as! Question).name == "question-1"{
                        identifier = (item as! Question).type
                        print(identifier as Any)
                    }
                }
                //navigate to the the viewController
    
                let secondViewController =
                    self.storyboard?.instantiateViewController(
                        withIdentifier: identifier!)
                self.navigationController?.pushViewController(
                    secondViewController!, animated: true)
                
            }else{
                SVProgressHUD.showError(withStatus:
                    "Questionnaire load failed due to deletion")
                SVProgressHUD.dismiss(withDelay: 2)
            }
        }catch{
            print("error on fetching")
        }
    }
    

    //this method will be called when loaded the view
    override func viewDidLoad() {
        super.viewDidLoad()
        //set up the background image
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "background1")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        //initialise the context variable
        context = appDelegate.persistentContainer.viewContext
        
        //print out the exist data ID
        print("data No. is \(dataAlreadyExist())")
        
        //if there is no data in the core data load both
        if(dataAlreadyExist() == 0){
            _ = loadJsonfile(address: URL_1)
            _ = loadJsonfile(address: URL_2)
            
            //if only questionnaire 1 in the core data
        }else if (dataAlreadyExist() == 1){
            _ = loadJsonfile(address: URL_2)
            
            //if only questionnaire 2 in the core data
        }else if (dataAlreadyExist() == 2){
            _ = loadJsonfile(address: URL_1)
            
            //if all questionnaires are in the core data
        }else{
            SVProgressHUD.showSuccess(withStatus:
                "All questionnaires already in Core data")
            SVProgressHUD.dismiss(withDelay: 2)
            print("data already exist")
        }
        
        do{
            //fetch the response from the main thread and this will be used in
            //the report view controller
            let fetchRequestResponse:NSFetchRequest<Responses> =
                Responses.fetchRequest();
            searchResultResponses = try context?.fetch(fetchRequestResponse)
            
        }catch{
            print("Error occured in iterateAllData()")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //show an wrong URL error alert
    func showUpError(){
        
        //no choice has been entered
        let alert = UIAlertController(title: "Error",
                                      message: "Wrong URL link",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertActionStyle.default,
                                      handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //load up the json file by passing in the URL as string
    func loadJsonfile(address:String)->Bool{
        var flag = false
        
        let url = URL(string: address)
        print(url as Any)
        //check is unwrap the URL succeed
        if(url != nil){
            //this closure request from online json file and execute after
            //resume()
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error as Any)
                //if the url is not valid then print put a warning messang
                self.showUpError()
                flag = true
            } else {
                if let urlContent = data {
                    
                  //print put the json result and put in the core data
                    do {
                        self.jsonResult =
                            try JSONSerialization.jsonObject(
                                with: urlContent, options:
                                JSONSerialization.ReadingOptions.mutableContainers)
                            as AnyObject
                        
                        print(self.jsonResult!)
                        //store the json data into core data
                        self.saveJsonFileToCoreData()
                        flag = true
                        
                    } catch {
                        print("======\nJSON processing Failed\n=======")
                    }
                }
            }
        }
        task.resume()
        //put the while loop to ensure the closure and the main code operate
        //asynchronously and ensure task.resume() has been executed
        while(!flag){
            sleep(1)
            print(url as Any)
        }
            return true
        }else{
            //if URL link is nil give an alert
            showUpError()
            print("nill url")
            return false
        }
        
    }
    
    
    //save the questionnaire and question into core data
    func saveJsonFileToCoreData(){
        
        //questionnaire and question instance initiallisation when adding new data
        questionnarie = NSEntityDescription.insertNewObject(forEntityName:
            "Questionnaire", into: context!) as? Questionnaire
        
        //add the information of the questionnaire
        print(self.questionnarie?.questionnaireID as Any)
        self.questionnarie?.questionnaireID = (jsonResult?["id"] as? String)!
        print(self.questionnarie?.questionnaireID as Any)
        
        print(self.questionnarie?.title as Any)
        self.questionnarie?.title = (jsonResult?["title"] as? String)!
        print(self.questionnarie?.title as Any)
        
        print(self.questionnarie?.decription as Any)
        self.questionnarie?.decription = (jsonResult?["description"]  as? String)!
        print(self.questionnarie?.decription as Any)
        
        //store the question aray in NSArray instance
        let questionArray = self.jsonResult?["questions"] as? NSArray
        //add information to the question
        for questionDetail in questionArray!{
            question = NSEntityDescription.insertNewObject(forEntityName:
                "Question", into: context!) as? Question
            //  let questionDetail = questionArray![index] as? NSDictionary
            print(self.question?.name as Any)
            self.question?.name =
                ((questionDetail as? NSDictionary)?["name"] as? String)!
            print(self.question?.name as Any)
            
            print(self.question?.type as Any)
            self.question?.type =
                ((questionDetail as? NSDictionary)?["type"] as? String)!
            print(self.question?.type as Any)
            
            print(self.question?.title as Any)
            self.question?.title =
                ((questionDetail as? NSDictionary)?["title"] as? String)!
            print(self.question?.title as Any)
            
            print(self.question?.questionContent as Any)
            self.question?.questionContent =
                ((questionDetail as? NSDictionary)?["question"] as? String)!
            print(self.question?.questionContent as Any)
            
            let options =
                (questionDetail as? NSDictionary)?["choices"] as? NSArray
            for option in options!{
                choices = NSEntityDescription.insertNewObject(forEntityName:
                    "Choices", into: context!) as? Choices
                
                print(self.choices?.label as Any)
                self.choices?.label = ((option as? NSDictionary)?["label"] as? String)!
                print(self.choices?.label as Any)
                
                print(self.choices?.value as Any)
                self.choices?.value = ((option as? NSDictionary)?["value"] as? Int16)!
                print(self.choices?.value as Any)
                
                //add all the choices to the question
                choices?.question = self.question
                self.question?.addToChoices(choices!)
                
            }
            //add the question to questionnaire
            question?.questionnaire = self.questionnarie
            self.questionnarie?.addToQuestions(question!)
            //save the data Into core data
            
        }
        
        do {
            //save after added the nsmangable object
            try context?.save()
        }catch{
            print("error in questions")
        }
        
    }
    
    
    //fcuntion that return the ID from core data
    //3 means both questionnaire 1 and 2 are in the core data
    func dataAlreadyExist() -> Int{
        var ID = 0
        let fetchRequest:NSFetchRequest<Questionnaire> =
            Questionnaire.fetchRequest();
        do{
            //get the questionnaire result from core data
            let searchResult = try context?.fetch(fetchRequest)
            if searchResult?.isEmpty == true{
                ID = 0
                //if only one questionnaire exist
            }else if searchResult?.count == 1 {
                let questionnaire1 = searchResult![0] as Questionnaire
                
                //if the exist one is questionnaire 1
                if(questionnaire1.questionnaireID == "questionnaire-1"){
                    ID = 1
                    //if the exist one is questionnaire 2
                }else if (questionnaire1.questionnaireID == "questionnaire-2"){
                    ID = 2
                }
                //if both questionnaires are all in the core data
            }else if searchResult?.count == 2{
                let questionnaire1 = searchResult![0] as Questionnaire
                let questionnaire2 = searchResult![1] as Questionnaire
                if(questionnaire1.questionnaireID == "questionnaire-1"
                    && questionnaire2.questionnaireID == "questionnaire-2"){
                    ID = 3
                }else{
                    print("wrong storage")
                }
                
            }else {
                print("more than 2 been stored")
                ID = 3
            }
        }catch{
            print("Error occured in checkDataAlreadyExist()")
        }
        return ID
    }
    
    
    //delete everythihng including the Questionnaire, Question, Choices and Responses
    func deleteAllData(){
        //fetch different entities from core data
        let fetchRequestQuestionnaire:NSFetchRequest<Questionnaire> =
            Questionnaire.fetchRequest();
        let fetchRequestQuestion:NSFetchRequest<Question> =
            Question.fetchRequest();
        let fetchRequestChoice:NSFetchRequest<Choices> =
            Choices.fetchRequest();
        let fetchRequestResponse:NSFetchRequest<Responses> = 
            Responses.fetchRequest();
        do{
            let searchResult1 = try context?.fetch(fetchRequestQuestionnaire)
            //iterator through the questionnaire
            if (searchResult1?.isEmpty == false){
                for object in searchResult1! {
                    //print(object.questionnaireID!)
                    context?.delete(object)
                }
                
            }
            
            //iterator through the questions
            let searchResult2 = try context?.fetch(fetchRequestQuestion)
            if (searchResult2?.isEmpty == false){
                for object in searchResult2! {
                    // print(object.name!)
                    context?.delete(object)
                }
            }
            
            //iterator through the choices
            let searchResult3 = try context?.fetch(fetchRequestChoice)
            if (searchResult3?.isEmpty == false){
                for object in searchResult3! {
                    //print(object.label!)
                    context?.delete(object)
                }
            }
            
            //iterator through the choices
            let searchResult4 = try context?.fetch(fetchRequestResponse)
            if (searchResult4?.isEmpty == false){
                for object in searchResult4! {
                    // print(object.value)
                    context?.delete(object)
                }
            }
            
            //give out a user prompt when finished
            SVProgressHUD.showSuccess(withStatus: "Delete success")
            SVProgressHUD.dismiss(withDelay: 1)
            print("delete success")
            try context?.save()
            
        }catch{
            print("Error occured in checkDataAlreadyExist()")
        }
        
    }
    
    //this fucntino is for debuging use only used to check the data in core data
    //this function is not inclluded in the code!!
    func iterateAllData(){
        let fetchRequestQuestionnaire:NSFetchRequest<Questionnaire> = Questionnaire.fetchRequest();
        let fetchRequestQuestion:NSFetchRequest<Question> = Question.fetchRequest();
        let fetchRequestChoice:NSFetchRequest<Choices> = Choices.fetchRequest();
        let fetchRequestResponse:NSFetchRequest<Responses> = Responses.fetchRequest();
        do{
            let searchResult1 = try context?.fetch(fetchRequestQuestionnaire)
            
            if (searchResult1?.isEmpty == false){
                print(searchResult1?.count as Any)
                for object in searchResult1! {
                    print(object.questionnaireID!)
                }
            }
            let searchResult2 = try context?.fetch(fetchRequestQuestion)
            if (searchResult2?.isEmpty == false){
                print(searchResult2?.count as Any)
                for object in searchResult2! {
                    print(object.name!)
                }
            }
            
            let searchResult3 = try context?.fetch(fetchRequestChoice)
            if (searchResult3?.isEmpty == false){
                print(searchResult3?.count as Any)
                for object in searchResult3! {
                    print(object.label!)
                    
                }
            }
            let searchResult4 = try context?.fetch(fetchRequestResponse)
            if (searchResult4?.isEmpty == false){
                print(searchResult4?.count as Any)
                for object in searchResult4! {
                    print(object.value)
                }
            }
        }catch{
            print("Error occured in iterateAllData()")
        }
        
        
    }
    
    
}


//save the previous answers to the core data, declear as the gloable function. it
//might be invoked every time the next button been pressed.
//each step may be the last step so once click the move button it should check
//whether or not the page is the last one.
func saveToCoreData()->Bool{
 
    
    //loop through the questionnaire that user choose to filled in and save
    //update the responses to each questions
    for item in (questionnarieResult?.questions!)!{
        if (item as! Question).type == "single-option"{

            let responseSingle = NSEntityDescription.insertNewObject(
                forEntityName: "Responses", into: context!) as? Responses
            //put the choice of the questionnaireID and question name into
            //entity Responses and save it later on
            responseSingle?.questionnaireID = questionnarieResult?.questionnaireID
            responseSingle?.questionName = (item as! Question).type
            //put the choice of the single choice into entity Responses
            //and save it later on
            responseSingle?.value = Int16(choosenSingle)
            //store the choice as string in to response label
            responseSingle?.label = String(chooseNumber)
            
            print(responseSingle?.label as Any)
            //store the question
            responseSingle?.question = (item as! Question)
            (item as! Question).response = responseSingle
            }
        
        if (item as! Question).type == "multi-option"{
 
            let responseMulti = NSEntityDescription.insertNewObject(
                forEntityName: "Responses", into: context!) as? Responses
            //put the choice of the questionnaireID and question name into
            //entity Responses and save it later on
            responseMulti?.questionnaireID = questionnarieResult?.questionnaireID
            responseMulti?.questionName = (item as! Question).type
            //put the choice of the single choice into entity Responses
            //and save it later on
            responseMulti?.value = Int16(0)
            //link the multiple choice as string

            var choiceString = ""
            for choice in choosenMuti {
                choiceString = choiceString + String(choice)
            }
            responseMulti?.label = choiceString
            print(responseMulti?.label as Any)
            //store the question
            responseMulti?.question = (item as! Question)
            (item as! Question).response = responseMulti
     
        }
        
        if (item as! Question).type == "numeric"{

            let responseNumeric = NSEntityDescription.insertNewObject(
                forEntityName: "Responses", into: context!) as? Responses
            //put the choice of the questionnaireID and question name into
            //entity Responses and save it later on
            responseNumeric?.questionnaireID = questionnarieResult?.questionnaireID
            responseNumeric?.questionName = (item as! Question).type
            //put the choice of the numeric choice into entity Responses
            //and save it later on
            responseNumeric?.value = Int16(chooseNumber)
            //store the number been entered as string in to response label
            responseNumeric?.label = String(chooseNumber)
            
            print(responseNumeric?.label as Any)
            //store the question
            responseNumeric?.question = (item as! Question)
            (item as! Question).response = responseNumeric
          
        }
        if (item as! Question).type == "text" {
      
            let responseText = NSEntityDescription.insertNewObject(
                forEntityName: "Responses", into: context!) as? Responses
            //put the choice of the questionnaireID and question name into
            //entity Responses and save it later on
            responseText?.questionnaireID = questionnarieResult?.questionnaireID
            responseText?.questionName = (item as! Question).type
            //put the choice of the numeric choice into entity Responses
            //and save it later on
            responseText?.value = Int16(0)
            //store the number been entered as string in to response label
            responseText?.label = inputComment
            
            print(responseText?.label as Any)
            //store the question
            responseText?.question = (item as! Question)
            (item as! Question).response = responseText
        
        }
    }
    
        do {
            try context?.save()
            //print("Testing: not store at this moment")
        }catch{
            print("error in questions")
        }
        return true

}


