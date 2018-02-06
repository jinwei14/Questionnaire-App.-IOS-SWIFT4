//
//  Questionnaire+CoreDataProperties.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 03/11/2017.
//  Copyright © 2017 zjw. All rights reserved.
//
//

import Foundation
import CoreData


extension Questionnaire {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Questionnaire> {
        return NSFetchRequest<Questionnaire>(entityName: "Questionnaire")
    }

    @NSManaged public var decription: String?
    @NSManaged public var questionnaireID: String?
    @NSManaged public var title: String?
    @NSManaged public var questions: NSSet?

}

// MARK: Generated accessors for questions
extension Questionnaire {

    @objc(addQuestionsObject:)
    @NSManaged public func addToQuestions(_ value: Question)

    @objc(removeQuestionsObject:)
    @NSManaged public func removeFromQuestions(_ value: Question)

    @objc(addQuestions:)
    @NSManaged public func addToQuestions(_ values: NSSet)

    @objc(removeQuestions:)
    @NSManaged public func removeFromQuestions(_ values: NSSet)

}
