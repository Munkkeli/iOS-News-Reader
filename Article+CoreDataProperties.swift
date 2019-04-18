//
//  Article+CoreDataProperties.swift
//  News
//
//  Created by Tuomas Pöyry on 11/04/2019.
//  Copyright © 2019 Tuomas Pöyry. All rights reserved.
//
//

import Foundation
import CoreData


extension Article {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
        return NSFetchRequest<Article>(entityName: "Article")
    }

    @NSManaged public var source: String?
    @NSManaged public var author: String?
    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var url: String?
    @NSManaged public var urlToImage: String?
    @NSManaged public var publishedAt: String?
    @NSManaged public var content: String?

}
