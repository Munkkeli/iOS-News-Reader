//
//  FeedTableViewController.swift
//  News
//
//  Created by Tuomas Pöyry on 10/04/2019.
//  Copyright © 2019 Tuomas Pöyry. All rights reserved.
//

import UIKit
import WebKit
import CoreData

class FeedTableViewController: UITableViewController, WKUIDelegate, NSFetchedResultsControllerDelegate {
    let cellIdentifier = "FeedTableViewCell"
    
    var fetchedResultsController : NSFetchedResultsController<Article>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fetchRequest: NSFetchRequest<Article> = Article.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "source", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.viewContext, sectionNameKeyPath: "source", cacheName: "articleCache")
        
        fetchedResultsController?.delegate = self as NSFetchedResultsControllerDelegate
        try? fetchedResultsController?.performFetch()
        
        /*
        self.list = News.getLatestCachedArticles()
        
        if self.list.count == 0 {
            loadNewsList()
        }
        */
    }
    
    func loadArticle(_ article: Article) {
        let webView: ArticleViewController = ArticleViewController()
        webView.article = article
        self.present(webView, animated: true, completion: nil)
    }
    
    /*
    func loadNewsList() {
        News.fetchLatestArticles(callback: { latestArticles, error in
            if error != nil {
                print("Error: \(error ?? "Unknown error")")
            } else {
                self.list = latestArticles ?? []
                self.tableView.reloadData()
            }
        })
    }
    */
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return (sections[section].objects![0] as! Article).source
        } else {
            return "Unknown"
        }
    }
    
    @IBAction func refresh(_ sender: Any) {
        // loadNewsList()
        
        // Callback not used due to NSFetchedResultsController approach
        News.fetchLatestArticles(callback: { _, _ in });
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? FeedTableViewCell else {
            fatalError("FeedTableViewCell not found.")
        }
        
        guard let article = self.fetchedResultsController?.object(at: indexPath) else {
            fatalError("News article not found")
        }
        
        cell.articleTitle?.text = article.title
        cell.articleDescription?.text = article.desc
        
        if let url = article.urlToImage {
            cell.articleImage?.imageFromServerURL(urlString: url)
        }

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let article = self.fetchedResultsController?.object(at: tableView.indexPathForSelectedRow!) else {
            fatalError("News article not found")
        }

        (segue.destination as! ArticleViewController).article = article
    }
}

extension UIImageView {
    public func imageFromServerURL(urlString: String) {
        self.image = nil

        guard let url = URL(string: urlString.replacingOccurrences(of: " ", with: "%20")) else {
            return
        }
        
        if url.scheme == "http" {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error  in
            if error != nil {
                return
            }

            DispatchQueue.main.async {
                let image = UIImage(data: data!)
                self.image = image
            }
        }
        
        task.resume()
    }
}
