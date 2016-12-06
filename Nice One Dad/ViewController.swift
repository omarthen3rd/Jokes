//
//  ViewController.swift
//  Nice One Dad
//
//  Created by Omar Abbasi on 2016-11-26.
//  Copyright © 2016 Omar Abbasi. All rights reserved.
//

import UIKit
import SwiftyJSON
import DynamicColor
import Spring

class ViewController: UIViewController {

    @IBOutlet var backView: UIView!
    @IBOutlet var mainView: SpringView!
    @IBOutlet weak var setup: UILabel!
    @IBOutlet weak var setupSpring: SpringLabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var alertView: SpringView!
    @IBOutlet weak var alertViewLabel: UILabel!
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    @IBAction func copyText(_ sender: Any) {
        
        copy(label: setup)
        
        alertView.isHidden = false
        alertView.animation = "slideLeft"
        alertViewLabel.text = "This amazing joke has been copied!"
        alertView.animate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
            
            self.alertView.animation = "fadeOut"
            self.alertView.animate()
            
        })
    }

    let jokes = [Joke]()
    var isFavourite = false
    var favouriteList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        alertView.isHidden = true
        
        // Font stuff
        setup.shadowColor = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.2)
        setup.shadowOffset = CGSize.init(width: 2, height: 2)
        
        // alertView Stuff
        alertView.layer.shadowColor = UIColor.black.cgColor
        alertView.layer.shadowOpacity = 0.30
        alertView.layer.shadowOffset = CGSize.init(width: 2, height: 2)
        alertView.layer.shadowRadius = 8
        alertView.layer.shouldRasterize = false
        
        // Add favourite gesture to favourite button
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapPress))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.nextJoke))
        swipeGesture.direction = UISwipeGestureRecognizerDirection.left
        mainView.addGestureRecognizer(swipeGesture)
        favButton.addGestureRecognizer(tapGesture)
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.mainView.backgroundColor = getColor()
        getJokes()
        
    }
    
    func setFavourite() -> Bool {
        
        isFavourite = true
        return isFavourite
        
    }
    
    func tapPress() {
        
        if favouriteList.contains(setup.text!) {
            
            alertView.isHidden = false
            alertView.animation = "slideLeft"
            alertViewLabel.text = "Joke is already in Favourites!"
            alertView.animate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                
                self.alertView.animation = "fadeOut"
                self.alertView.animate()
                
            })

            
        } else {
            
            let favVC = FavouritesTableViewController()
            favVC.jokesArray.append(setup.text!)
            favouriteList.append(setup.text!)
            alertView.isHidden = false
            alertView.animation = "slideLeft"
            alertViewLabel.text = "Joke added to Favourites!"
            alertView.animate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                
                self.alertView.animation = "fadeOut"
                self.alertView.animate()
                
            })
            
        }
        
    }
    
    func getJokes() {
        
        let filePath = Bundle.main.path(forResource: "jokes", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        let json = JSON(data: jsonData!)
        
        let randomIndex = Int(arc4random_uniform(UInt32(json.count)))
        let newJoke: Joke = Joke(setup: json[randomIndex]["setup"].stringValue, punchline: json[randomIndex]["punchline"].stringValue)
        
        setup.text = newJoke.setup + "\n" + "\n" + newJoke.punchline

    }
    
    func nextJoke() {
        
        let tintColor = getColor().shaded(amount: 0.1)
        let tintBackColor = tintColor.shaded(amount: 0.4)
        self.mainView.backgroundColor = tintColor
        self.backView.backgroundColor = tintBackColor
        mainView.animation = "slideLeft"
        mainView.animate()
        getJokes()
        
    }
    
    func copy(label: UILabel) {
        let pboard = UIPasteboard.general
        pboard.string = label.text
    }
    
    func getColor() -> UIColor {
        
        let red:CGFloat = CGFloat(drand48())
        let green:CGFloat = CGFloat(drand48())
        let blue:CGFloat = CGFloat(drand48())

        return UIColor(red:red, green: green, blue: blue, alpha: 1.0)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationVC: FavouritesTableViewController = (segue.destination as! UINavigationController).topViewController as! FavouritesTableViewController
        let arrayToSend: [String] = favouriteList
        destinationVC.jokesArray = arrayToSend
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

