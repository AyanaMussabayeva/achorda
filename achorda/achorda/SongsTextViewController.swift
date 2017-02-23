//
//  SongsTextViewController.swift
//  achorda
//
//  Created by Student on 1/16/16.
//  Copyright © 2016 Ayana. All rights reserved.
//

import UIKit
//import Parse
//import Bolts
import Firebase


class SongsTextViewController: UIViewController {
    
     var ref = FIRDatabase.database().reference()
    
    @IBOutlet weak var songTextView: UITextView!
    @IBOutlet var songsNameLabel: UILabel!
    var toneChord:[AnyObject] = []
    var neededSongs:[AnyObject]=[]
    var chosenSong:AnyObject?
    var text: String = ""
    var songID:[String]=[]
    var chosenSongId:String!
    var chosenToneChord:[AnyObject]=[]
    var chosenSongsInitialChords:[String]=[]
    var chosenSongNumberOfTransitions:Int!
    var newNeededChords:[Int] = []
    var newNeededChordsNames:[String]=[]
    var InitialVsNewDict = [String: String]()
    //var chordsLabel:UILabel!
    var neededChordsString:String!
    var greenColor:UIColor = UIColor(hue: 168/360, saturation: 49/100, brightness: 80/100, alpha: 1.0) /* #68ccb8 */
    var brownColor:UIColor = UIColor(red: 147/255, green: 131/255, blue: 132/255, alpha: 1.0)
    var pinkColor:UIColor = UIColor(hue: 339/360, saturation: 58/100, brightness: 93/100, alpha: 1.0) /* #ed6393 */
    var orangeColor:UIColor = UIColor(red: 255/255, green: 150/255, blue: 0/255, alpha: 1.0) /* #ff9600 */
    
    func showText(){
        //print(chosenSong)
        print("NUMBER OF TRANSITIONS",self.chosenSongNumberOfTransitions)
        songsNameLabel.text = (((chosenSong as! NSDictionary)["artist"] as! String) + " - " + ((chosenSong as! NSDictionary)["songName"] as! String))
 
        ref.child("songText/" + self.chosenSongId).observe(.value, with: { snapshot in
            let chosenSongText = snapshot.value as! NSDictionary
            self.text = chosenSongText["text"] as! String
            self.songTextView.text=self.text
            self.songTextView.textColor = self.orangeColor
            self.findSubstr()
        }, withCancel: { error in
            print(error.localizedDescription)
        })
    }
 

    func findSubstr(){
  
        print(chosenSongsInitialChords)
        for i in 0..<chosenSongsInitialChords.count {
            
            let textString = self.text as NSString
            var range = textString.range(of: chosenSongsInitialChords[i], options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(0, textString.length))
            print(range.length)
            
            while (range.length>0){
                songTextView.layoutManager.ensureLayout(for: songTextView.textContainer)
                let start = songTextView.position(from: songTextView.beginningOfDocument, offset: range.location)!
                let end = songTextView.position(from: start, offset: range.length)!
                
                let tRange = songTextView.textRange(from: start, to: end)
                
                let rect = songTextView.firstRect(for: tRange!)
                let view:UILabel = UILabel(frame: rect)
                view.backgroundColor = UIColor.white
                view.textColor = orangeColor
                
                for dict in InitialVsNewDict{
                    if(chosenSongsInitialChords[i]==dict.0){
                        print( dict.1)
                        
                        neededChordsString = dict.1
                    }
                }
                view.text = neededChordsString
                //chordsLabel.text =  neededChordsString
                //view.addSubview(chordsLabel)
                songTextView.addSubview(view)
                let newStart = range.location+range.length;
                range = textString.range(of: chosenSongsInitialChords[i], options: NSString.CompareOptions.caseInsensitive, range: NSMakeRange(range.location+range.length, textString.length-newStart))
            }
        }
        
        
    }
    
    func takeChordsAndNumbers(){
        for j in 0..<((self.chosenSong! as! NSDictionary)["chords"] as! NSArray).count{
            for i in 0..<self.toneChord.count{
                if ((((self.chosenSong! as! NSDictionary)["chords"]! as! NSArray)[j] as! Int)==((toneChord[i] as! NSDictionary)["numberOfChord"] as! Int)){
                    chosenSongsInitialChords.append("///" + ((toneChord[i] as! NSDictionary)["toneChord"] as! String) + "///")
                }
            }
        }
        print(chosenSongsInitialChords)
       
        for i in 0..<((self.chosenSong! as! NSDictionary)["chords"] as! NSArray).count{
            
            if ((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions) as Int>120){
                newNeededChords.append((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions) - 120)
            }
            else{
                newNeededChords.append((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions))
            }
             
        }
        print("newNeededChords", newNeededChords)
        
        for i in 0..<self.newNeededChords.count{
            for j in 0..<self.toneChord.count{
                if(self.newNeededChords[i]==((self.toneChord[j] as! NSDictionary)["numberOfChord"] as! Int)){
                    self.newNeededChordsNames.append((toneChord[j] as! NSDictionary)["toneChord"] as! String)
                }
            }
            
        }
        for (key, value) in zip(self.chosenSongsInitialChords, self.newNeededChordsNames) {
            self.InitialVsNewDict[key] = value
        }
        print(InitialVsNewDict)
        
        //print(newNeededChordsNames)
        findSubstr()
    }
        
    
    @IBAction func tonalityUpButton(_ sender: AnyObject) {
        self.chosenSongNumberOfTransitions = chosenSongNumberOfTransitions - 1
        print(chosenSongNumberOfTransitions)
        for i in 0..<self.newNeededChords.count{
            if ((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions) as Int>120){
                newNeededChords[i]=((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions) - 120)
            }
            else{
                newNeededChords[i]=((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions))
            }
        }
        self.newNeededChordsNames=[]
        for i in 0..<self.newNeededChords.count{
            for j in 0..<self.toneChord.count{
                if(self.newNeededChords[i]==((self.toneChord[j] as! NSDictionary)["numberOfChord"] as! Int)){
                    self.newNeededChordsNames.append((toneChord[j] as! NSDictionary)["toneChord"] as! String)
                }
            }
        }
        print(newNeededChords)
        self.InitialVsNewDict = [String: String]()
        for (key, value) in zip(self.chosenSongsInitialChords, self.newNeededChordsNames) {
            self.InitialVsNewDict[key] = value
        }
        print(InitialVsNewDict)
        findSubstr()
        
    }
    
    @IBAction func tonalityDownButton(_ sender: AnyObject) {
        self.chosenSongNumberOfTransitions = chosenSongNumberOfTransitions + 1
        print(chosenSongNumberOfTransitions)
        for i in 0..<self.newNeededChords.count{
            if ((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions) as Int>120){
                newNeededChords[i]=((((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions) - 120)
            }
            else{
                newNeededChords[i]=(((((self.chosenSong! as! NSDictionary)["chords"] as! NSArray )[i] as! Int)+120) - 10*self.chosenSongNumberOfTransitions)
            }
        }
        self.newNeededChordsNames=[]
        for i in 0..<self.newNeededChords.count{
            for j in 0..<self.toneChord.count{
                if(self.newNeededChords[i]  == ((self.toneChord[j] as! NSDictionary)["numberOfChord"] as! Int)){
                    self.newNeededChordsNames.append((toneChord[j] as! NSDictionary)["toneChord"] as! String)
                }
            }
        }
        print(newNeededChords)
        self.InitialVsNewDict = [String: String]()
        for (key, value) in zip(self.chosenSongsInitialChords, self.newNeededChordsNames) {
            self.InitialVsNewDict[key] = value
        }
        print(InitialVsNewDict)
        findSubstr()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showText()
        takeChordsAndNumbers()
        //self.songTextView.text=self.text
        //findSubstr()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
