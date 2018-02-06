//
//  Responses+CoreDataProperties.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 03/11/2017.
//  Copyright © 2017 zjw. All rights reserved.
//
//

import Foundation
import CoreData


extension Responses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Responses> {
        return NSFetchRequest<Responses>(entityName: "Responses")
    }

    @NSManaged public var label: String?
    @NSManaged public var questionnaireID: String?
    //question is the type of the question
    @NSManaged public var questionName: String?
    @NSManaged public var value: Int16
    @NSManaged public var question: Question?

}
