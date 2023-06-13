//
//  RingtoneSelectionVC.swift
//  RTCPhone
//
//  Created by Md. Yamin on 4/6/22.
//  Copyright © 2022 Mamun Ar Rashid. All rights reserved.
//

import UIKit
import AVFoundation

class RingtoneSelectionVC: UIViewController {
    ///File Manager allows us access to the device's files to which we are allowed.
    let fileManager: FileManager = FileManager()

    ///The directories where sound files are located.
    var ringtoneDirectory: String = "/Library/Ringtones"
    
    var player = AVAudioPlayer()
    var ringtoneItems = [
        LocalRingtone(ringtoneTitle: "Test Audio", ringtoneFileName: "hello16000", ringtoneType: "wav", directory: ""),
        LocalRingtone(ringtoneTitle: "Ringtone Audio", ringtoneFileName: "Ringtone", ringtoneType: "aif", directory: ""),
        LocalRingtone(ringtoneTitle: "Test Audio-1", ringtoneFileName: "hello8000", ringtoneType: "wav", directory: ""),
        LocalRingtone(ringtoneTitle: "Water Drop", ringtoneFileName: "incoming_chat", ringtoneType: "wav", directory: ""),
        LocalRingtone(ringtoneTitle: "Toy Mono", ringtoneFileName: "toy-mono", ringtoneType: "wav", directory: ""),
        LocalRingtone(ringtoneTitle: "Old Phone Long", ringtoneFileName: "oldphone-mono-30s", ringtoneType: "caf", directory: ""),
        LocalRingtone(ringtoneTitle: "Old Phone Short Mono", ringtoneFileName: "oldphone-mono", ringtoneType: "wav", directory: "")]

    @IBOutlet weak var ringtonesListTableView: UITableView!
    
    var selectedIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //getDeviceRingtones()
        
        //ringtonesListTableView.reloadData()
        
        configureAudioSession()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if player.isPlaying {
            player.stop()
        }
    }
    
    private func playRingTone(ringtone: LocalRingtone) {
        if player.isPlaying {
            player.stop()
        }
        
        if ringtone.directory.isEmpty {
            let path = Bundle.main.path(forResource: ringtone.ringtoneFileName, ofType : ringtone.ringtoneType)!
            let url = URL(fileURLWithPath : path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player.volume = 1
                player.play()
            } catch {
                print("Sound Play Error -> \(error)")
            }
        } else {
            //Play the sound
            let fileURL: URL = URL(fileURLWithPath: "\(ringtone.directory)/\(ringtone.ringtoneFileName).\(ringtone.ringtoneType)")
            do {
                player = try AVAudioPlayer(contentsOf: fileURL)
                player.play()
            } catch {
                debugPrint("\(error)")
            }
        }
    }
    
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: [])
        }
        catch( let error) {
            print(error)
        }
        
    }
    
    private func setAsRingTone(ringtone: LocalRingtone) {
        UserDefaults.standard.set("\(ringtone.ringtoneFileName).\(ringtone.ringtoneType)", forKey: AppConstants.keySelectedRingtone)
        UserDefaults.standard.set(ringtone.directory, forKey: AppConstants.keySelectedRingtoneDirectory)
        
        print("Selected Ringtone: \(UserDefaults.standard.string(forKey: AppConstants.keySelectedRingtone) ?? "N/A")")
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate, let theLinphoneManager = appdelegate.theLinphoneManager else {
            print("appdelegate is missing")
            return
        }
        appdelegate.providerDelegate = ProviderDelegate(callManager: appdelegate.callManager, theLinphoneManager: theLinphoneManager)
    }
    
    /**
     For each directory, it looks at each item (file or directory) and only appends the sound files to the soundfiles[i]files array.
     
     - URLs: All of the contents of the directory (files and sub-directories).
     */
    func getDeviceRingtones() {
        let directoryURL: URL = URL(fileURLWithPath: ringtoneDirectory, isDirectory: true)
        
        do {
            var URLs: [URL]?
            URLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [URLResourceKey.isDirectoryKey], options: FileManager.DirectoryEnumerationOptions())
            var urlIsaDirectory: ObjCBool = ObjCBool(false)
            var soundPaths: [String] = []
            for url in URLs! {
                fileManager.fileExists(atPath: url.path, isDirectory: &urlIsaDirectory)
                if !urlIsaDirectory.boolValue {
                    soundPaths.append("\(url.lastPathComponent)")
                    let soundPath = url.lastPathComponent
                    let tempArray = soundPath.components(separatedBy: ".")
                    if tempArray.count == 2 {
                        ringtoneItems.append(LocalRingtone(ringtoneTitle: tempArray[0], ringtoneFileName: tempArray[0], ringtoneType: tempArray[1], directory: ringtoneDirectory))
                    }
                }
            }
        } catch {
            debugPrint("\(error)")
        }
    }

}

extension RingtoneSelectionVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ringtoneItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RingtoneTableViewCell", for: indexPath) as! RingtoneTableViewCell
        cell.ringtoneTitle.text = ringtoneItems[indexPath.row].ringtoneTitle
        let ringtoneItem = ringtoneItems[indexPath.row]
        let ringtone = "\(ringtoneItem.ringtoneFileName).\(ringtoneItem.ringtoneType)"
        if let savedRingtone = UserDefaults.standard.string(forKey: AppConstants.keySelectedRingtone), savedRingtone.elementsEqual(ringtone) {
            cell.accessoryType = .checkmark
            selectedIndexPath = indexPath
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let preSelectedIndexPath = selectedIndexPath {
            tableView.cellForRow(at: preSelectedIndexPath)?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        playRingTone(ringtone: ringtoneItems[indexPath.row])
        setAsRingTone(ringtone: ringtoneItems[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
