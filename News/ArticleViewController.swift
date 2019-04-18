//
//  ArticleViewController.swift
//  News
//
//  Created by Tuomas Pöyry on 11/04/2019.
//  Copyright © 2019 Tuomas Pöyry. All rights reserved.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController {
    @IBOutlet weak var webViewArticle: WKWebView!
    
    var article: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let initial = article {
            loadArticle(initial)
        }
    }
    
    func loadArticle(_ article: Article) {
        guard let url = URL(string: article.url ?? "") else {
            fatalError("Failed to create URL")
        }

        let request = URLRequest(url: url)
        webViewArticle.load(request)
    }
}
