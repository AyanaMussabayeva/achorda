  

//
//  SearchViewController.swift
//  achorda
//
//  Created by Student on 1/9/16.
//  Copyright © 2016 Ayana. All rights reserved.
//

import UIKit

import Bolts
import Firebase


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{


    //@IBOutlet var combinationAlertLabel: UILabel!
    @IBOutlet var songTableView: UITableView!
    @IBOutlet var toneTableView: UITableView!
    @IBOutlet var chordTableView: UITableView!
    @IBOutlet var chosenCombinationsScrollView: UIScrollView!
    @IBOutlet var combinationAlertLabel: UILabel!
   
    var cellsCount:Int!
    var chosenTone:String?
    var chosenChord:String?
    var tones:[Dictionary<String, String>] = []
    var chords:[Dictionary<String, String>] = []
    var toneChord:[AnyObject] = []
    var chosenCombinations:[AnyObject] = []
    var tonechordName:[String]=[]
    var chosenToneChord:[AnyObject]=[]
    var chosenSong:AnyObject?
    var songsChord:[AnyObject]=[]
    var songs:[AnyObject]=[]
    var currentSong:AnyObject?
    var currentSongId:String?
    var neededSongs:[AnyObject]=[]
    var songID:[String]=[]
    var neededSongsIDs:[String]=[]
    var chosenSongId:String?
    var numberOfTransitions:Int = 1
    var neededSongsNumberOfTransitions:[Int]=[]
    var chosenSongNumberOfTransitions:Int!
    var labelChords:[AnyObject] = []
    
    // собираем все тоуны и чорды
    func callServer(){
        
        let myRootRef = Firebase(url:"https://achorda-ayana.firebaseio.com/tone")
        myRootRef.queryOrderedByChild("name").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            self.tones = snapshot.value as! [Dictionary<String, String>]
            self.tones.sortInPlace({ $0["name"]!.localizedCaseInsensitiveCompare($1["name"]!) == NSComparisonResult.OrderedAscending})
            self.toneTableView.reloadData()
        })
        
        let myRootRef2 = Firebase(url:"https://achorda-ayana.firebaseio.com/chord")
        myRootRef2.queryOrderedByChild("name").observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            self.chords = snapshot.value as! [Dictionary<String, String>]
            self.chords.sortInPlace({ $0["name"]!.localizedCaseInsensitiveCompare($1["name"]!) == NSComparisonResult.OrderedAscending})
            self.chordTableView.reloadData()
        })
        
        let songsRoot = Firebase(url:"https://achorda-ayana.firebaseio.com/song")
        songsRoot.observeEventType(.Value, withBlock: { snapshot in
            for (key,value) in snapshot.value as! NSDictionary {
                self.songs.append(value)
                self.songID.append(key as! String)
                
            }
            }, withCancelBlock: { error in
                print(error.description)
        })

    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        if tableView.isEqual(toneTableView){
            cell.textLabel!.text = self.tones[indexPath.row]["name"] as String!
            //cell.textLabel!.textAlignment = NSTextAlignment.Center;
            cell.textLabel!.textAlignment = .Center;
        }
        if tableView.isEqual(chordTableView){
            cell.textLabel!.text = self.chords[indexPath.row]["name"] as String!
        }
        if tableView.isEqual(songTableView){
            cell.textLabel!.text = self.neededSongs[indexPath.row]["songName"] as? String
            cell.detailTextLabel?.text = self.neededSongs[indexPath.row]["artist"] as? String
            cell.textLabel?.numberOfLines = 0
            
        }
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("____________________________________", "/n", self.neededSongs.count)
        if tableView.isEqual(toneTableView){
            cellsCount = tones.count
            print(tones.count)
        }
        if tableView.isEqual(chordTableView){
            cellsCount = chords.count
            print(chords.count)
        }
        if tableView.isEqual(songTableView){
            
            cellsCount = self.neededSongs.count
        }
        return cellsCount
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if(tableView.isEqual(toneTableView)){
            self.chosenTone = self.tones[indexPath.row]["name"] as String!
        }
        if(tableView.isEqual(chordTableView)){
            self.chosenChord = self.chords[indexPath.row]["name"] as String!
        }
        if(tableView.isEqual(songTableView)){
            self.chosenSong=self.neededSongs[indexPath.row]
            self.chosenSongId=self.neededSongsIDs[indexPath.row]
            self.chosenSongNumberOfTransitions = self.neededSongsNumberOfTransitions[indexPath.row]
            performSegueWithIdentifier("viewSongsText", sender: indexPath)
        }
        
        
        
        if((chosenTone==nil) || (chosenChord==nil))
        {
            combinationAlertLabel.text = "You shold choose both parameters"
        }else{
            let dict:Dictionary<String,String> = ["tone": self.chosenTone!, "chord": self.chosenChord!]
            chosenCombinations.append(dict)
            chosenCombinationsToScroll()
            self.labelChords.append(dict)
           
            

            //////////////////////////////////////////////////////////////////////////
            print("ВЫЗЫВАЮ ФУНКЦИЮ combineToSrting!!!")
            combineToString()
            
            ////////////////////////////////////////////////////////////////////////
            //self.neededSongs = []
            chosenChord = nil
            chosenTone = nil
            chosenCombinations = []
            //self.songTableView.reloadData()

            
        }
        //print(chosenCombinations)
        
    }
    func chosenCombinationsToScroll(){
        combinationAlertLabel.text = ""
        for i in 0..<labelChords.count {
            let stringForButton:String
            let xForButton:CGFloat
            xForButton = CGFloat(5 + 40*i)
            
            let buttonForChord=UIButton(frame: CGRectMake(xForButton,0,30,30))
            chosenCombinationsScrollView.addSubview(buttonForChord)
            stringForButton = combinationAlertLabel.text! + (labelChords[i]["tone"]! as! String) + (labelChords[i]["chord"]! as! String) + "  ";
            buttonForChord.backgroundColor = UIColor.grayColor()
            buttonForChord.setTitle(stringForButton, forState: UIControlState.Normal)
            
            
        }
    }
    
    /*func swipeFromScrollView(){
        let chordButtonSwipeRecognizer : UISwipeGestureRecognizer;
        if (UISwipeGestureRecognizerDirection.Up == true){
            
        }
        
    }*/
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    func combineToString() {
        self.chosenToneChord = []
        
        for i in 0..<chosenCombinations.count{
            tonechordName.append((chosenCombinations[i]["tone"]! as! String) + (chosenCombinations[i]["chord"]! as! String))
        }
        print(chosenCombinations)
        print(tonechordName)
        
        let RootToneChord = Firebase(url: "https://achorda-ayana.firebaseio.com/toneChord")
        RootToneChord.queryOrderedByChild("toneChord").observeSingleEventOfType(.Value,withBlock: {
            snapshot in
            self.toneChord=snapshot.value as! [AnyObject]
            for i in 0..<self.toneChord.count{
                for j in 0..<self.tonechordName.count{
                    if (self.toneChord[i]["toneChord"] as! String==self.tonechordName[j] as String){
                        self.chosenToneChord.append(self.toneChord[i])
                        print("____________________", self.toneChord[i])
                    }
                }
            }
            self.songsChordCompare(self.chosenToneChord)
        
            
        })
        
    }
    
    func songsChordCompare(chosenToneChord:[AnyObject]){
        
        print("0!!!!!!!!!!!")
        
        var same:Int = 0
        for i in 0..<self.songs.count{
            print(self.songs[i])
            if (self.chosenToneChord.count==((self.songs[i]["chords"]!) as! [AnyObject]).count){
                print(self.songs[i])
                for k in 0..<self.chosenToneChord.count{
                    for j in 0..<((self.songs[i]["chords"]!) as! [AnyObject]).count{
                        //если аккорд совпадает то same++ ежже
                        if((self.songs[i]["chords"]!![j] as! Int) == (self.chosenToneChord[k]["numberOfChord"] as! Int) ){
                            same++
                            print(same, " - same ")
                        }
                    }
                }
                if(same==((self.songs[i]["chords"]!) as! [AnyObject]).count){
                    print("same")
                    self.currentSong=self.songs[i]
                    self.currentSongId=self.songID[i]
                    self.neededSongs.append(self.currentSong!)
                    self.neededSongsIDs.append(self.currentSongId!)
                    self.numberOfTransitions=0
                    self.neededSongsNumberOfTransitions.append(self.numberOfTransitions)
                    same=0
                    
                }else{
                    same=0
                    self.currentSong=self.songs[i]
                    self.currentSongId=self.songID[i]
                    //print(self.currentSong)
                    self.numberOfTransitions=1
                    self.transposeIfNotSame(self.chosenToneChord) //в противном случае вызываем функцию,которая отвечает за сдвиг
                }
            }
            
        }
        self.songTableView.reloadData()
    }
    
    //функция отвечающая за сдвиг
    func transposeIfNotSame(chosenToneChord:[AnyObject]){
        print("1!!!!!!!!!!!!")
        var arrayForChecking:[Int] = []
        
        for i in 0..<self.chosenToneChord.count{
            arrayForChecking.append(chosenToneChord[i]["numberOfChord"] as! Int)
        }
        
        
        for i in 0..<arrayForChecking.count{
            arrayForChecking[i]+=10*numberOfTransitions
        }
        
        for i in 0..<arrayForChecking.count{
            if(arrayForChecking[i] > 120){
                arrayForChecking[i] = arrayForChecking[i]-120 //(arrayForChecking[i]+10*numberOfTransitions)%120-10
            }
        }
        comparingAndChecking (self.chosenToneChord, arrayForChecking: arrayForChecking)
    }
    
    //ежже сравниваю аrrayForChecking с выбранными
    func comparingAndChecking(chosenToneChord:[AnyObject],  arrayForChecking:[Int]){
        print("2!!!!!!!!!!!")
        var same:Int = 0
        
        
        if ( arrayForChecking.count == ((self.currentSong!["chords"]!) as! [AnyObject]).count){
            for k in 0..<arrayForChecking.count{
                for j in 0..<((self.currentSong!["chords"]!) as! [AnyObject]).count{
                    if((self.currentSong!["chords"]!![j] as! Int) == arrayForChecking[k] as Int){
                        same++
                    }
                }
            }
            
            if (same==((self.currentSong!["chords"]!) as! [AnyObject]).count){
                print("THIS SONG IS NEEDED!")
                self.neededSongs.append(self.currentSong!)
                self.neededSongsIDs.append(self.currentSongId!)
                print("number of trans", numberOfTransitions)
                self.neededSongsNumberOfTransitions.append(self.numberOfTransitions)
                same=0
                self.currentSongId=nil
                self.currentSong=nil
                
            } else {
                print("not enough same")
                if (self.numberOfTransitions<11){
                    self.numberOfTransitions++
                    print("number of transitions",self.numberOfTransitions )
                    print("back to 1!!!!")
                    self.transposeIfNotSame(self.chosenToneChord)
                }
            }
        }
        
        
        self.songTableView.reloadData()
        //print(self.neededSongs)
        
    }
    
    
    
    
    @IBAction func searchTapped(sender: AnyObject) {
        self.performSegueWithIdentifier("searchSegue", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        callServer()
        var swipeUp = UISwipeGestureRecognizer(target: chosenCombinationsScrollView,  action: "respondToSwipeGesture:")
        swipeUp.direction = UISwipeGestureRecognizerDirection.Up
        self.view.addGestureRecognizer(swipeUp)

        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier=="viewSongsText"{
            let vc = segue.destinationViewController as! SongsTextViewController
            vc.chosenSong = self.chosenSong
            vc.neededSongs = self.neededSongs
            vc.toneChord = self.toneChord
            vc.songID = self.songID
            vc.chosenSongId = self.chosenSongId
            vc.chosenToneChord = self.chosenToneChord
            vc.chosenSongNumberOfTransitions = self.chosenSongNumberOfTransitions
        }
        if segue.identifier=="searchSegue"{
            let vc = segue.destinationViewController as! ResultListViewController
            vc.toneChord = self.toneChord
            vc.chosenToneChord = self.chosenToneChord
            vc.chosenCombinations = self.chosenCombinations
            vc.neededSongs = self.neededSongs
            vc.neededSongsIDs = self.neededSongsIDs
            vc.neededSongsNumberOfTransitions = self.neededSongsNumberOfTransitions
        }
        
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}
