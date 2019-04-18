//
//  News.swift
//  News
//
//  Created by Tuomas Pöyry on 10/04/2019.
//  Copyright © 2019 Tuomas Pöyry. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct NewsResponse: Codable {
    var status: String
    var totalResults: Int
    var articles: [NewsArticle]
}

struct NewsArticle: Codable {
    var source: NewsSource
    var author: String?
    var title: String
    var description: String
    var url: String
    var urlToImage: String?
    var publishedAt: String
    var content: String?
}

struct NewsSource: Codable {
    var id: String?
    var name: String
}

class News {
    public private(set) var latestArticles: [Any] = []
    
    static private let APIKey = "87d89a03e30341f7a23ca1d5f1473866";
    
    static func fetchLatestArticles(callback: @escaping ([Article]?, String?) -> ()) {
        guard let url = URL(string: "https://newsapi.org/v2/everything?q=bitcoin&sortBy=publishedAt&apiKey=\(APIKey)") else {
            fatalError("Failed to create URL")
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    callback(nil, "Error: \(error)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    callback(nil, "Error: Could not fetch articles")
                }
                return
            }
            
            guard let newsResponse = data else {
                DispatchQueue.main.async {
                    callback(nil, nil)
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let feed = try decoder.decode(NewsResponse.self, from: newsResponse)
                
                DispatchQueue.main.async {
                    let cachedList = cacheLatestArticles(feed)
                    callback(cachedList, nil)
                }
            } catch let parseError {
                DispatchQueue.main.async {
                    callback(nil, "Error: \(parseError)")
                }
                return
            }
        }
        
        task.resume()
    }
    
    static func cacheLatestArticles(_ list: NewsResponse) -> [Article] {
        let managedObjectContext = AppDelegate.viewContext
        
        var cachedList = [Article]()
        
        clearLatestArticleCache()
        
        for article in list.articles {
            let cachedArticle = Article(context: managedObjectContext)
            cachedArticle.author = article.author
            cachedArticle.content = article.content
            cachedArticle.desc = article.description
            cachedArticle.publishedAt = article.publishedAt
            cachedArticle.source = article.source.name
            cachedArticle.title = article.title
            cachedArticle.url = article.url
            cachedArticle.urlToImage = article.urlToImage
            
            cachedList.append(cachedArticle)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        return cachedList
    }
    
    static func clearLatestArticleCache() {
        let managedObjectContext = AppDelegate.viewContext

        let list = getLatestCachedArticles()
        
        if list.count > 0 {
            for article in list {
                managedObjectContext.delete(article)
            }
        }
    }
    
    static func getLatestCachedArticles() -> [Article] {
        let managedObjectContext = AppDelegate.viewContext

        let articleRequest: NSFetchRequest<Article> = Article.fetchRequest()
        
        if let list = try? managedObjectContext.fetch(articleRequest) {
            return list
        }
        
        return []
    }
}
