//
//  ViewController.swift
//  MusicWithSensors
//
//  Created by Nikita Luzhbin on 19.06.2022.
//

import UIKit
import SafariServices
import AVFoundation
import MBProgressHUD

class ViewController: UIViewController {

    private enum Constants {
        static let uAuthURL = "https://connect.deezer.com/oauth/auth.php?app_id=547522&redirect_uri=musicwithsensors://MusicWithSensors.com/auth_redirect-callback&perms=basic_access"
    }

    private var safaryVC: SFSafariViewController?
    private var player: AVPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let storyboard = UIStoryboard(name: "Player", bundle: nil)
//            let playerVC = storyboard.instantiateInitialViewController() as! PlayerViewController
//
//            UIApplication.setRootView(playerVC)
//        }
    
        NotificationCenter.default.addObserver(forName: .init(rawValue: "didRecieveUAuthCode"),
                                               object: nil,
                                               queue: nil) { notification in
            let oAuthCode = notification.object as! String

            Task {
                await DefaultNetworkService.shared.getAuthToken(with: oAuthCode)
                self.safaryVC?.dismiss(animated: true)

                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.label.text = "Loading"

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    MBProgressHUD.hide(for: self.view, animated: true)

                    let storyboard = UIStoryboard(name: "Player", bundle: nil)
                    let playerVC = storyboard.instantiateInitialViewController() as! PlayerViewController

                    UIApplication.setRootView(playerVC)
                }
            }
        }
    }

    @IBAction private func onConnectButtonTouchUpInside(_ sender: Any) {
        self.presentSafari()
    }

    private func presentSafari() {
        let safariVC = SFSafariViewController(url: URL(string: Constants.uAuthURL)!)

        safariVC.modalPresentationStyle = .formSheet

        self.safaryVC = safariVC

        self.present(safariVC, animated: true)
    }

    func play(url: URL) {
        print("playing \(url)")

        do {

            let playerItem = AVPlayerItem(url: url)

            self.player = try AVPlayer(playerItem:playerItem)
            player!.volume = 1.0
            player!.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }
    }
}

