//
//  ViewController.swift
//  Nice One Dad
//
//  Created by Omar Abbasi on 2018-02-09.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import UIKit

struct Joke {
    
    let setup: String
    let punchline: String
    
}

extension NSMutableAttributedString {
    
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
    
    func setColorForRange(_ range: NSRange, with color: UIColor) {
        if range.location != NSNotFound {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        }
    }
    
    func boldTextIn(_ range: NSRange, size: CGFloat) {
        
        if range.location != NSNotFound {
            let attrs = [NSAttributedStringKey.font : UIFont(name: "NotoSerif-Bold", size: size)]
            addAttributes(attrs, range: range)
        }
        
    }
    
    func setSizeForText(_ textToFind: String, with font: UIFont) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            let attrs = [NSAttributedStringKey.font : font]
            addAttributes(attrs, range: range)
        }
        
    }
    
}

extension String {
    
    func countInstances(of stringToFind: String) -> Int {
        var stringToSearch = self
        var count = 0
        while let foundRange = stringToSearch.range(of: stringToFind, options: .diacriticInsensitive) {
            stringToSearch = stringToSearch.replacingCharacters(in: foundRange, with: "")
            count += 1
        }
        return count
    }
    
}


extension UITextView {
    
    func centerVertically() {
        
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
        
    }
    
    func textExceedsBounds() -> Bool {
        let textHeight = self.contentSize.height
        return textHeight > self.bounds.height
    }
    
}

extension UILabel {
    
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: CGFloat(self.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(self.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(self.font.pointSize))
        return rHeight / charSize
    }
    
}

extension UIColor {
    
    static let darkBackgroundColor = UIColor(red:0.18, green:0.21, blue:0.26, alpha:1.0) // #2f3542
    static let darkTextColor = UIColor(red:0.95, green:0.95, blue:0.96, alpha:1.0) // #f1f2f6
    static let darkTintColor = UIColor(red:0.64, green:0.69, blue:0.75, alpha:1.0) // #a4b0be
    
    static let lightBackgroundColor = UIColor(red:0.99, green:0.99, blue:0.99, alpha:1.0) // #FCFCFC
    static let lightTextColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:1.0) // #464646
    static let lightTintColor = UIColor.gray // gray ¯\_(ツ)_/¯
    
}

class ViewController: UIViewController {
    
    @IBOutlet var jokeLabel: UILabel!
    @IBOutlet var browse: UIButton!
    @IBOutlet var heart: UIButton!
    @IBOutlet var random: UIButton!
    @IBOutlet var settings: UIButton!
    
    var jokesLocal = [Joke]()
    var jokesRemote = [Joke]()
    var newIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchLocalJokes()
        fetchRemoteJokes { (success) in
            if success {
                
                let jokesFinal = self.jokesLocal + self.jokesRemote
                
                self.loadRandomJoke(jokesFinal)
                
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        
        let favouritesImage = #imageLiteral(resourceName: "happyHeart").withRenderingMode(.alwaysTemplate)
        heart.setImage(favouritesImage, for: .normal)
        heart.tintColor = UIColor.gray
        heart.imageView?.tintColor = UIColor.gray
        heart.contentMode = .scaleAspectFit
        heart.imageView?.contentMode = .scaleAspectFit
        
        let randomImage = #imageLiteral(resourceName: "shuffle").withRenderingMode(.alwaysTemplate)
        random.setImage(randomImage, for: .normal)
        random.tintColor = UIColor.gray
        random.imageView?.tintColor = UIColor.gray
        random.imageView?.contentMode = .scaleAspectFit
        
        let browseImage = #imageLiteral(resourceName: "browse").withRenderingMode(.alwaysTemplate)
        browse.setImage(browseImage, for: .normal)
        browse.tintColor = UIColor.gray
        browse.imageView?.tintColor = UIColor.gray
        browse.imageView?.contentMode = .scaleAspectFit
        
        let settingsImage = #imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate)
        settings.setImage(settingsImage, for: .normal)
        settings.tintColor = UIColor.gray
        settings.imageView?.tintColor = UIColor.gray
        settings.imageView?.contentMode = .scaleAspectFit
        
    }
    
    func fetchRemoteJokes(completionHandler: @escaping (Bool) -> ()) {
        
        guard let url = URL(string: "https://www.reddit.com/r/dadjokes/top/.json?count=20&raw_json=1") else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if error != nil {
                print("error")
            }
            
            guard let dataToUse = data else { completionHandler(false); return }
            
            let json = JSON(dataToUse)
            
            let dataArr = json["data"]["children"].arrayValue
            
            for child in dataArr {
                
                let score = child["data"]["score"].intValue
                let isSelfPost = child["data"]["is_self"].boolValue
                
                if isSelfPost && score >= 20 {
                    // only proceed if child is a self post to avoid links and etc...
                    // set score threshold for score for maximum joke effect
                    
                    let title = child["data"]["title"].stringValue
                    let punchline = child["data"]["selftext"].stringValue
                    
                    let newJoke = Joke(setup: title, punchline: punchline)
                    self.jokesRemote.append(newJoke)
                    
                }
                
            }
            
            completionHandler(true)
            
        }
        
        task.resume()
        
    }
    
    func fetchLocalJokes() {
        
        let filePath = Bundle.main.path(forResource: "jokes", ofType: "json")
        let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filePath!))
        
        do {
            
            let json = try JSON(data: jsonData!)
            
            for joke in json.arrayValue {
                
                let title = joke["setup"].stringValue
                let punchline = joke["punchline"].stringValue
                
                let newJoke = Joke(setup: title, punchline: punchline)
                self.jokesLocal.append(newJoke)
                
            }
            
        } catch {
            
            print("you done fucked up")
            
        }
        
    }
    
    func loadRandomJoke(_ jokes: [Joke]) {
        
        var newJoke: Joke
        
        let randomIndex = Int(arc4random_uniform(UInt32(jokes.count)))
        if newIndex == randomIndex {
            
            let newRandomIndex = Int(arc4random_uniform(UInt32(jokes.count)))
            newJoke = jokes[newRandomIndex]
            
        } else {
            
            let newIndex = randomIndex
            loadRandomJoke(jokes)
            
        }
        newJoke = jokes[randomIndex]
        
        jokeLabel.text = newJoke.setup + "\n\n" + newJoke.punchline
        
    }


}

