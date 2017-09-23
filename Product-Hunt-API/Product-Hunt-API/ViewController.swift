//
//  ViewController.swift
//  Product-Hunt-API
//
//  Created by Elmer Astudillo on 9/20/17.
//  Copyright © 2017 Elmer Astudillo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
        
        NetworkProduct.networking { (allProducts) in
            self.products = allProducts
            DispatchQueue.main.async {
                self.productsTableView.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ViewController : UITableViewDataSource
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

extension ViewController : UITableViewDelegate
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


