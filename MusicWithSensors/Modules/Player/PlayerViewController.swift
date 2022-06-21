//
//  PlayerViewController.swift
//  MusicWithSensors
//
//  Created by Nikita Luzhbin on 19.06.2022.
//

import UIKit
import AVFoundation
import MBProgressHUD

class PlayerViewController: UIViewController {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var heartImageView: UIImageView!
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?

    var musicFiles = [
        "Hotline",
        "NeverGonnaGiveYouUp",
        "Hydrogen",
        "SmokeOnTheWater",
        "Paris",
        "SafetyDance",
        "ComeWithMeNow",
    ]

    var currentPlayingIndex = 0
    var isPlaying = false

    @objc func didTappedHeart() {
        self.beginAnimation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.heartImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTappedHeart)))

        self.playerItem = AVPlayerItem(url: self.getCurrentMusicURL())
        self.updateMusicData()

        let loadingHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingHUD.label.text = "Detecting AirPods..."


        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            loadingHUD.hide(animated: true)

            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .customView
            hud.animationType = .zoomIn
            hud.customView = UIImageView(image: UIImage(systemName: "checkmark"))
            hud.hide(animated: true, afterDelay: 1)

            DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                let oneMoreHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
                oneMoreHUD.mode = .text
                oneMoreHUD.label.text = "Music added to favourites"
                oneMoreHUD.offset = .init(x: 0, y: -320)

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    oneMoreHUD.hide(animated: true)
                }
            }
        }
    }

    @IBAction func previousButtonTouchUpInside(_ sender: UIButton) {
        if self.currentPlayingIndex - 1 >= 0 {
            self.currentPlayingIndex -= 1
            self.updateMusicData()

            if self.isPlaying {
                self.play()
            }
        }
    }

    @IBAction func mainButtonTouchUpInside(_ sender: UIButton) {
        self.isPlaying.toggle()

        switch self.isPlaying {
        case true:
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)

            self.play()

        case false:
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.player?.pause()
        }

        self.player!.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 30), queue: .main) { [self] time in
            let fraction = CMTimeGetSeconds(self.player!.currentItem!.currentTime()) / CMTimeGetSeconds(self.player!.currentItem!.duration)

            self.durationSlider.value = Float(fraction)
        }
    }

    @IBAction func nextButtonTouchUpInside(_ sender: UIButton) {
        if self.currentPlayingIndex + 1 < self.musicFiles.count {
            self.currentPlayingIndex += 1
            self.updateMusicData()

            if self.isPlaying {
                self.play()
            }
        }
    }

    private func getCurrentMusicURL() -> URL {
        return Bundle.main.url(forResource: self.musicFiles[currentPlayingIndex], withExtension: "mp3")!
    }

    private func play() {
        let playerItem = AVPlayerItem(url: self.getCurrentMusicURL())
        self.playerItem = playerItem
        let metadataList = playerItem.asset.metadata as! [AVMetadataItem]

        try! AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try! AVAudioSession.sharedInstance().setActive(true)

        self.player = try AVPlayer(playerItem: playerItem)
        self.player!.play()
    }

    func beginAnimation() {
        if self.heartImageView.tintColor != .red {
            UIView.animate(withDuration: 0.3, animations: {
                self.heartImageView.tintColor = UIColor.red
            })
        }

        UIView.animate(withDuration: 0.1, delay: 0, animations: {
            self.heartImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: { completion in
            self.heartImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }

    private func updateMusicData() {
        self.playerItem = AVPlayerItem(url: self.getCurrentMusicURL())
        let metadataList = playerItem!.asset.metadata
        print("Metadata count: \(metadataList.count)")

        DispatchQueue.main.async {
            for item in metadataList {
                
                guard let key = item.commonKey?.rawValue, let value = item.value else {
                    self.posterImageView.image = UIImage(named: "album-placeholder")!
                    continue
                }

                if key == "title" {
                    print(value as! String)
                }

                if key == "artwork" {
                    if let valueData = value as? Data, let image = UIImage(data: valueData) {
                        self.posterImageView.image = image
                    } else {
                        self.posterImageView.image = UIImage(named: "album-placeholder")!
                    }
                }
            }
        }
    }
}
