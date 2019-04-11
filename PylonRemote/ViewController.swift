//
//  ViewController.swift
//  PylonRemote
//
//  Created by Cory D. Wiles on 4/10/19.
//  Copyright © 2019 Cory Wiles. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {

    var player: AVPlayer!
    var playerItem: AVPlayerItem!
    
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let path = Bundle.main.path(forResource: "test", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        setupAudioSession()
    }
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: .allowAirPlay)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting the AVAudioSession:", error.localizedDescription)
        }
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
    
    func play() {
        player.play()
        setupNowPlaying()
        setupRemoteCommandCenter()
    }
    
    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "My Song"
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        let image = UIImage(named: "obi-wan.jpg")!
        let artwork = MPMediaItemArtwork.init(boundsSize: CGSize(width: 400, height: 400), requestHandler: { (size) -> UIImage in
            return image
        })
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        MPNowPlayingInfoCenter.default().playbackState = .playing
    }
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.player.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.player.pause()
            return .success
        }
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        self.play()
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        print("what is my remoteControlReceived \(String(describing: event))")
    }
}


