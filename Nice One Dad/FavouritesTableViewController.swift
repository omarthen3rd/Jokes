//
//  FavouritesTableViewController.swift
//  Nice One Dad
//
//  Created by Omar Abbasi on 2016-11-29.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import UIKit

class CustomJokeCell: UITableViewCell {
    
    @IBOutlet weak var setup: UILabel!
    
}

class FavouritesTableViewController: UITableViewController {

    var jokesArray: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = true
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        addBlur()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Functions
    
    func addBlur() {
        
        self.tableView.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        if jokesArray.count > 0 {
            
            tableView.separatorEffect = UIVibrancyEffect(blurEffect: blurEffect)
            
        } else {
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
            messageLabel.text = "No Favourites Added.\nYou can add favourites by tapping the Favourite button."
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            vibrancyView.contentView.addSubview(messageLabel)
            blurEffectView.contentView.addSubview(vibrancyView)
            self.tableView.separatorStyle = .none
            
        }
        
        self.tableView.backgroundView = blurEffectView
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jokesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomJokeCell
        
        cell.backgroundColor = UIColor.clear
        cell.setup.numberOfLines = 0
        cell.setup.textColor = UIColor.white
        cell.setup.text = jokesArray[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            jokesArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } 
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC: ViewController = segue.destination as! ViewController
        let arrayToSend: [String] = jokesArray
        destinationVC.favouriteList = arrayToSend
        
    }

}
