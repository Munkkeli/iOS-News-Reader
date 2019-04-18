//
//  SearchTableViewController.swift
//  News
//
//  Created by Tuomas Pöyry on 10/04/2019.
//  Copyright © 2019 Tuomas Pöyry. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    let cellIdentifier = "SearchTableViewCell"
    var tableData = [Article]()
    var filteredTableData = [Article]()
    var resultSearchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableData = News.getLatestCachedArticles()
        
        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return tableData.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchTableViewCell else {
            fatalError("SearchTableViewCell not found.")
        }
        
        if (resultSearchController.isActive) {
            populateCell(cell, filteredTableData[indexPath.row])
            return cell
        }
        else {
            populateCell(cell, tableData[indexPath.row])
            return cell
        }
    }
    
    func populateCell(_ cell: SearchTableViewCell, _ article: Article) {
        cell.articleTitle?.text = article.title
        cell.articleDescription?.text = article.desc
        
        if let url = article.urlToImage {
            cell.articleImage?.imageFromServerURL(urlString: url)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let array = tableData.filter { ($0.title ?? "").contains(searchController.searchBar.text!) }
        filteredTableData = array
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let article: Article;
        if (resultSearchController.isActive) {
            article = filteredTableData[tableView.indexPathForSelectedRow?.row ?? 0]
        } else {
            article = tableData[tableView.indexPathForSelectedRow?.row ?? 0]
        }

        (segue.destination as! ArticleViewController).article = article
    }
}
