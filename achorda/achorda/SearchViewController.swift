
//
//  SearchViewController.swift
//  achorda
//
//  Created by Student on 1/9/16.
//  Copyright © 2016 Ayana. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var ref: FIRDatabaseReference!
    //var ref = FIRDatabase.database().reference()
    
    
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
    
    var greenColor:UIColor = UIColor(hue: 168/360, saturation: 49/100, brightness: 80/100, alpha: 1.0) /* #68ccb8 */
    var brownColor:UIColor = UIColor(red: 147/255, green: 131/255, blue: 132/255, alpha: 1.0)
    var pinkColor:UIColor = UIColor(hue: 339/360, saturation: 58/100, brightness: 93/100, alpha: 1.0) /* #ed6393 */
    var orangeColor:UIColor = UIColor(red: 255/255, green: 150/255, blue: 0/255, alpha: 1.0) /* #ff9600 */
    
    // собираем все тоуны и чорды
    func callServer(){
        
        ref.child("tone").queryOrdered(byChild: "name").observeSingleEvent(of: .value, with: {
            snapshot in
            self.tones = snapshot.value as! [Dictionary<String, String>]
            self.tones.sort(by: { $0["name"]!.localizedCaseInsensitiveCompare($1["name"]!) == ComparisonResult.orderedAscending})
            self.toneTableView.reloadData()
        }, withCancel: { error in
            print(error.localizedDescription)
        })
        
        ref.child("chord").queryOrdered(byChild: "name").observeSingleEvent(of: .value, with: {
            (snapshot) in
            self.chords = snapshot.value as! [Dictionary<String, String>]
            self.chords.sort(by: { $0["name"]!.localizedCaseInsensitiveCompare($1["name"]!) == ComparisonResult.orderedAscending})
            self.chordTableView.reloadData()
        }, withCancel: { error in
            print(error.localizedDescription)
        })
        
        ref.child("song").observe(.value, with: { snapshot in
            for (key, value) in snapshot.value as! NSDictionary{
                self.songs.append(value as Any as AnyObject)
                self.songID.append(key as! String)
            }
        },withCancel: { error in
             print(error.localizedDescription)
        })
    }
    
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        if tableView.isEqual(toneTableView){
            cell.textLabel!.text = self.tones[indexPath.row]["name"] as String!
            cell.backgroundColor = UIColor.white
            cell.textLabel!.textAlignment = .center;
            cell.textLabel?.textColor = orangeColor;
            
        }
        if tableView.isEqual(chordTableView){
            cell.textLabel!.text = self.chords[indexPath.row]["name"] as String!
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = orangeColor;
        }
        if tableView.isEqual(songTableView){
            cell.textLabel!.text = self.neededSongs[indexPath.row]["songName"] as? String
            cell.detailTextLabel?.text = self.neededSongs[indexPath.row]["artist"] as? String
            cell.textLabel?.numberOfLines = 0
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = orangeColor

            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
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
            performSegue(withIdentifier: "viewSongsText", sender: indexPath)
        }
        
        
        
        if((chosenTone==nil) || (chosenChord==nil))
        {
            combinationAlertLabel.text = "You shold choose both parameters"
        }else{
            let dict:Dictionary<String,String> = ["tone": self.chosenTone!, "chord": self.chosenChord!]
            chosenCombinations.append(dict as AnyObject)
            self.labelChords.append(dict as AnyObject)
            
            chosenCombinationsToScroll()
            

            print("ВЫЗЫВАЮ ФУНКЦИЮ combineToSrting!!!")
            combineToString()

            chosenChord = nil
            chosenTone = nil
            chosenCombinations = []
        }
    }
    
    
    
    func chosenCombinationsToScroll(){
        combinationAlertLabel.text = ""
        for i in 0..<labelChords.count {
            let stringForButton:String
            let xForButton:CGFloat
            xForButton = CGFloat(5 + 40*i)
            let xForDeleteButton = CGFloat(31 + 40*i)
            
            
            
            let deleteButton = UIButton(frame: CGRect(x: xForDeleteButton, y: 0, width: 10, height: 10))
            deleteButton.layer.cornerRadius = 0.45 * deleteButton.bounds.size.width
            deleteButton.clipsToBounds = true
            
            chosenCombinationsScrollView.addSubview(deleteButton);
            deleteButton.setTitle("x", for: UIControlState());
           
            deleteButton.backgroundColor = pinkColor
          
            deleteButton.tag = i
            deleteButton.addTarget(self, action: #selector(SearchViewController.deleteButtonClicked(_:)),
                for: UIControlEvents.touchUpInside)
            
            let buttonForChord=UIButton(frame: CGRect(x: xForButton,y: 0,width: 30,height: 30))
            buttonForChord.layer.cornerRadius = 0.45 * buttonForChord.bounds.size.width
            
           buttonForChord.clipsToBounds = true
            buttonForChord.tag = i
            
            chosenCombinationsScrollView.addSubview(buttonForChord)
            stringForButton = combinationAlertLabel.text! + (labelChords[i]["tone"]! as! String) + (labelChords[i]["chord"]! as! String) + "  ";
            buttonForChord.backgroundColor = orangeColor
            buttonForChord.setTitle(stringForButton, for: UIControlState())
            chosenCombinationsScrollView.bringSubview(toFront: deleteButton);
            
        }
    }
    
    func deleteButtonClicked(_ sender: UIButton)
    {
        let button = sender
        let index = button.tag
        
        
        let alert = UIAlertController(title: "Alert", message: "Delete this chord?"
            , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        let destroyAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            
        }
        alert.addAction(destroyAction)
        
        self.chosenToneChord.remove(at: index)
        self.tonechordName.remove(at: index)
        //self.chosenCombinations.remove(at: index)
        //self.chosenChord = nil
        //self.chosenTone = nil
        self.neededSongs.removeAll()
        self.songsChordCompare(self.chosenToneChord)
        
        
        let subViews = self.chosenCombinationsScrollView.subviews
        for subview in subViews {
            if subview.tag == index  {
                subview.removeFromSuperview()
                chosenCombinationsScrollView.reloadInputViews()
            }
        }
        //combineToString()
        
        
    }
    
    
    
    func combineToString() {
        self.chosenToneChord = []
        
        for i in 0..<chosenCombinations.count{
            tonechordName.append((chosenCombinations[i]["tone"]! as! String) + (chosenCombinations[i]["chord"]! as! String))
        }
        print(chosenCombinations)
        print(tonechordName)
        
        ref.child("toneChord").queryOrdered(byChild: "toneChord").observeSingleEvent(of: .value,with: {
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

    
    func songsChordCompare(_ chosenToneChord:[AnyObject]){
        
        var same:Int = 0
        for i in 0..<self.songs.count{
            print(self.songs[i])
            if (self.chosenToneChord.count==((self.songs[i]["chords"]!) as! [NSDictionary]).count){
                print(self.songs[i])
                for k in 0..<self.chosenToneChord.count{
                    for j in 0..<((self.songs[i]["chords"]!) as! [NSDictionary]).count{
                        //если аккорд совпадает то same++ ежже
                        if((((self.songs[i]["chords"]!) as! Array)[j]) == (self.chosenToneChord[k]["numberOfChord"] as! Int)) {
                            same += 1
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
    func transposeIfNotSame(_ chosenToneChord:[AnyObject]){
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
               // arrayForChecking[i] = arrayForChecking[i]-120 //(arrayForChecking[i]+10*numberOfTransitions)%120-10
                 arrayForChecking[i] = (arrayForChecking[i]+10*numberOfTransitions)%120-10
            }
        }
        comparingAndChecking (self.chosenToneChord, arrayForChecking: arrayForChecking)
    }
    
    //ежже сравниваю аrrayForChecking с выбранными
    func comparingAndChecking(_ chosenToneChord:[AnyObject],  arrayForChecking:[Int]){
        print("2!!!!!!!!!!!")
        var same:Int = 0
        
        
        if ( arrayForChecking.count == ((self.currentSong!["chords"]!) as! [AnyObject]).count){
            for k in 0..<arrayForChecking.count{
                for j in 0..<((self.currentSong!["chords"]!) as! [AnyObject]).count{
                    if(((self.currentSong!["chords"]!! as! Array)[j] ) == arrayForChecking[k] as Int){
                        same += 1
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
                    self.numberOfTransitions += 1
                    print("number of transitions",self.numberOfTransitions )
                    print("back to 1!!!!")
                    self.transposeIfNotSame(self.chosenToneChord)
                }
            }
        }
        
        self.songTableView.reloadData()
        
    }
    
    
    
    
    @IBAction func searchTapped(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "searchSegue", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref  = FIRDatabase.database().reference()
        callServer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="viewSongsText"{
            let vc = segue.destination as! SongsTextViewController
            vc.chosenSong = self.chosenSong
            vc.neededSongs = self.neededSongs
            vc.toneChord = self.toneChord
            vc.songID = self.songID
            vc.chosenSongId = self.chosenSongId
            vc.chosenToneChord = self.chosenToneChord
            vc.chosenSongNumberOfTransitions = self.chosenSongNumberOfTransitions
        }
        if segue.identifier=="searchSegue"{
            let vc = segue.destination as! ResultListViewController
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
