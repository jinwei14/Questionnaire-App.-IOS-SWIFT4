//
//  Choices+CoreDataProperties.swift
//  COMP327_Assignment1_jinwei
//
//  Created by Jinwei Zhang on 03/11/2017.
//  Copyright © 2017 zjw. All rights reserved.
//
//

import Foundation
import CoreData


extension Choices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Choices> {
        return NSFetchRequest<Choices>(entityName: "Choices")
    }

    @NSManaged public var label: String?
    @NSManaged public var value: Int16
    @NSManaged public var question: Question?

}
