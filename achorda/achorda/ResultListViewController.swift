 //  ResultListViewController.swift
//  achorda
//
//  Created by Student on 1/9/16.
//  Copyright © 2016 Ayana. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Firebase
 
class ResultListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var songsTable: UITableView!
    var tones:[Dictionary<String,String>] = []
    var chords:[Dictionary<String,String>] = []
    var chosenCombinations:[AnyObject] = []
    var chosenSong:AnyObject?
    var tonechordName:[String]=[]
    var toneChord:[AnyObject] = []
    var chosenToneChord:[AnyObject]=[]
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
    
    
    
    
    //отображение в таблице
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = self.neededSongs[indexPath.row]["songName"] as? String
        cell.detailTextLabel?.text = self.neededSongs[indexPath.row]["artist"] as? String
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.neededSongs.count)
        return self.neededSongs.count
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(self.neededSongs[indexPath.row] )
        self.chosenSong=self.neededSongs[indexPath.row]
        self.chosenSongId=self.neededSongsIDs[indexPath.row]
        self.chosenSongNumberOfTransitions = self.neededSongsNumberOfTransitions[indexPath.row]
        performSegueWithIdentifier("showSongsText", sender: indexPath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! SongsTextViewController
        vc.chosenSong = self.chosenSong
        vc.neededSongs = self.neededSongs
        vc.toneChord = self.toneChord
        vc.songID = self.songID
        vc.chosenSongId = self.chosenSongId
        vc.chosenToneChord = self.chosenToneChord
        vc.chosenSongNumberOfTransitions = self.chosenSongNumberOfTransitions
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}