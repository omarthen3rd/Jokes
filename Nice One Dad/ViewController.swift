//
//  ViewController.swift
//  Nice One Dad
//
//  Created by Omar Abbasi on 2018-02-09.
//  Copyright © 2018 Omar Abbasi. All rights reserved.
//

import UIKit
import ChameleonFramework

struct Joke {
    
    let setup: String
    let punchline: String
    
}

extension Array{
    
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
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

class ViewController: UIViewController {
    
    @IBOutlet var jokeView: UITextView!
    @IBOutlet var browse: UIButton!
    @IBOutlet var heart: UIButton!
    @IBOutlet var random: UIButton!
    @IBOutlet var settings: UIButton!
    
    var jokesLocal = [Joke]()
    var jokesRemote = [Joke]()
    var jokesFinal = [Joke]()
    var currentJoke: Joke!
    var jokeString = String()
    var contrast = UIColor()
    var newIndex = 0
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchLocalJokes()
        fetchRemoteJokes { (success) in
            if success {
                
                self.jokesFinal = self.jokesLocal + self.jokesRemote
                self.loadRandomJoke()
                
            } else {
                
                self.jokesFinal = self.jokesLocal
                
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
        heart.contentMode = .scaleAspectFit
        heart.imageView?.contentMode = .scaleAspectFit
        
        let randomImage = #imageLiteral(resourceName: "shuffle").withRenderingMode(.alwaysTemplate)
        random.setImage(randomImage, for: .normal)
        random.imageView?.contentMode = .scaleAspectFit
        
        let browseImage = #imageLiteral(resourceName: "browse").withRenderingMode(.alwaysTemplate)
        browse.setImage(browseImage, for: .normal)
        browse.imageView?.contentMode = .scaleAspectFit
        
        let settingsImage = #imageLiteral(resourceName: "settings").withRenderingMode(.alwaysTemplate)
        settings.setImage(settingsImage, for: .normal)
        settings.imageView?.contentMode = .scaleAspectFit
        
        random.addTarget(self, action: #selector(loadRandomJoke), for: .touchUpInside)
        
    }
    
    func setTint(with color: UIColor) {
        
        view.backgroundColor = color
        
        contrast = ContrastColorOf(color, returnFlat: true)
        let tintColor = contrast.withAlphaComponent(0.5)
        
        setStatusBarStyle(UIStatusBarStyleContrast)
        
        jokeView.textColor = contrast
        
        heart.tintColor = tintColor
        heart.imageView?.tintColor = tintColor
        
        random.tintColor = tintColor
        random.imageView?.tintColor = tintColor
        
        browse.tintColor = tintColor
        browse.imageView?.tintColor = tintColor
        
        settings.tintColor = tintColor
        settings.imageView?.tintColor = tintColor
        
    }
    
    func setFont() {
        
        // getFontNames()
        let fonts = ["LuckiestGuy-Regular", "TitanOne", "Chango-Regular", "RammettoOne-Regular", "Lemon-Regular", "SansitaOne"]
        let randomIndex = Int(arc4random_uniform(UInt32(fonts.count)))
        let fontString = fonts[randomIndex]
        let font = UIFont(name: fontString, size: 30)
        
        let text = jokeString
        let range = NSRange(location: 0, length: (text as NSString).length)
        
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(NSAttributedStringKey.font, value: font!, range: range)
        attrString.setColorForRange(range, with: contrast)
        jokeView.attributedText = attrString
        
    }
    
    func getFontNames() {
        
        for name in UIFont.familyNames {
            print(UIFont.fontNames(forFamilyName: name))
        }
        
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
    
    @objc func loadRandomJoke() {
        
        let jokes = jokesFinal
        
        let newJoke = jokes.random()
        currentJoke = newJoke
        
        jokeString = newJoke.setup + "\n\n" + newJoke.punchline
        
        DispatchQueue.main.async {
            let bgColor = UIColor.randomFlat
            self.setTint(with: bgColor)
            self.setFont()
            self.jokeView.centerVertically()
        }
        
    }
    
    func isInFavourites() -> Bool {
        
        let favouritesExist = defaults.object(forKey: "favourites") != nil
        
        if favouritesExist {
            
            guard let joke = currentJoke else { return false }
            guard let decodedArr = defaults.object(forKey: "favourites") as? Data else { return false }
            guard let decodedJokes = NSKeyedUnarchiver.unarchiveObject(with: decodedArr) as? [Joke] else { return false }
            if (decodedJokes.contains(where: { $0.setup == joke.setup } )) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
        
    }


}

