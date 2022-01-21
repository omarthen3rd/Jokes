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
    
    let id: String
    let joke: String
    
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
    @IBAction func loadRandomJoke(_ sender: UIButton) {
        
        fetchRandomJoke { (_) in
            
        }
        
    }
    
    var jokesFinal = [Joke]()
    var currentJoke: Joke!
    var jokeString = String()
    var contrast = UIColor()
    var newIndex = 0
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        fetchRandomJoke { (success) in
            
        }
        
        for family: String in UIFont.familyNames
        {
            print(family)
            for names: String in UIFont.fontNames(forFamilyName: family) {
                print("== \(names)")
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
        
//        random.addTarget(self, action: #selector(loadRandomJoke), for: .touchUpInside)
        
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
    
    func fetchRandomJoke(completionHandler: @escaping (Bool) -> ()) {
        
        guard let url = URL(string: "https://icanhazdadjoke.com/") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                print("error loading jokes")
            }
            
            guard let data = data else { completionHandler(false); return }
            
            print(String(data: data, encoding: .utf8)!)
            
            do {
                let json = try JSON(data: data)
                let jokeString = json["joke"].stringValue
                let jokeId = json["id"].stringValue
                
                print(json)
                
                let newJoke = Joke(id: jokeId, joke: jokeString)
                
                self.loadRandomJoke(joke: newJoke)
            } catch {
                print("error")
            }
            
        }
        
        session.resume()
        
    }
    
    func loadRandomJoke(joke: Joke) {
        
        currentJoke = joke
        jokeString = joke.joke
        
        print("loading joke: " + jokeString)
        
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
            if (decodedJokes.contains(where: { $0.id == joke.id } )) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
        
    }


}

