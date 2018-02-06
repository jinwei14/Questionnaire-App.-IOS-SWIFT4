//
//  Question+CoreDataProperties.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 03/11/2017.
//  Copyright © 2017 zjw. All rights reserved.
//
//

import Foundation
import CoreData


extension Question {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var name: String?
    @NSManaged public var questionContent: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var choices: NSSet?
    @NSManaged public var response: Responses?
    @NSManaged public var questionnaire: Questionnaire?

}

// MARK: Generated accessors for choices
extension Question {

    @objc(addChoicesObject:)
    @NSManaged public func addToChoices(_ value: Choices)

    @objc(removeChoicesObject:)
    @NSManaged public func removeFromChoices(_ value: Choices)

    @objc(addChoices:)
    @NSManaged public func addToChoices(_ values: NSSet)

    @objc(removeChoices:)
    @NSManaged public func removeFromChoices(_ values: NSSet)

}
