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
    
    var greenColor:UIColor = UIColor(hue: 168/360, saturation: 49/100, brightness: 80/100, alpha: 1.0) /* #68ccb8 */
    var brownColor:UIColor = UIColor(red: 147/255, green: 131/255, blue: 132/255, alpha: 1.0)
    var pinkColor:UIColor = UIColor(hue: 339/360, saturation: 58/100, brightness: 93/100, alpha: 1.0) /* #ed6393 */
    
    
    
    //отображение в таблице
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = (self.neededSongs[indexPath.row] as! NSDictionary)["songName"] as? String
        cell.detailTextLabel?.text = (self.neededSongs[indexPath.row] as! NSDictionary)["artist"] as? String
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = brownColor
        cell.textLabel?.textColor = UIColor.white
        //cell.detailTextLabel?.textColor = greenColor
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.neededSongs.count)
        return self.neededSongs.count
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.neededSongs[indexPath.row] )
        self.chosenSong=self.neededSongs[indexPath.row]
        self.chosenSongId=self.neededSongsIDs[indexPath.row]
        self.chosenSongNumberOfTransitions = self.neededSongsNumberOfTransitions[indexPath.row]
        performSegue(withIdentifier: "showSongsText", sender: indexPath)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SongsTextViewController
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
