//
//  ProductsViewController.swift
//  Product-Hunt-API
//
//  Created by Elmer Astudillo on 9/20/17.
//  Copyright © 2017 Elmer Astudillo. All rights reserved.
//

import UIKit

class ProductsViewController: UIViewController {

    @IBOutlet weak var productsTableView: UITableView!
    
    var products : [Product] = []
    {
        didSet{
            DispatchQueue.main.async {
                self.productsTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        Networking.shared.fetch(route: .post) { (data) in
            let producthunt = try? JSONDecoder().decode(Producthunt.self, from: data)
            guard let newPosts = producthunt?.posts else{return}
            self.products = newPosts
            DispatchQueue.main.async {
                self.productsTableView.reloadData()
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ProductsViewController : UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let product = products[indexPath.row]
        print(products)
        if product.name != nil {
            cell.textLabel?.text = product.name
            cell.detailTextLabel?.text = product.tagline
        }
        if product.imageURL == "image"
        {
            DispatchQueue.main.async {
                
                cell.imageView?.image = UIImage(named: "image.jpg")
            }
        }
        if let profileImageURL = product.imageURL {
            
            if product.imageURL != "image"
            {
                DispatchQueue.main.async {
                    
                    cell.imageView?.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                }
            }
        }
        
        return cell
        
    }
}

extension ProductsViewController : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[indexPath.row]
        let postID = product.postID
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let commentsTableVC = storyboard.instantiateViewController(withIdentifier: "CommentsTableViewController") as! CommentsTableViewController
        commentsTableVC.postID = postID
        navigationController?.pushViewController(commentsTableVC, animated: true)
        
    }
}


