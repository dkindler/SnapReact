//
//  SnapViewController.swift
//  SnapReaction
//
//  Created by Dan Kindler on 11/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit
import AVFoundation

class SnapViewController: UIViewController {
    
    enum FullScreenContent {
        case videoSnapchat, photoSnapchat, reactionPreview
    }
    
    enum PipContent {
        case cameraPreview, videoSnapchat, photoSnapchat
    }
    
    // Interface Properties
    let imageView = UIImageView()
    let blurView = UIVisualEffectView()
    var pipPlayerLayer = AVPlayerLayer()
    var fullScreenPlayerLayer = AVPlayerLayer()
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var recipientNameLabel: UILabel!
    @IBOutlet weak var sendBar: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!

    // Properties
    var snap: Snap?
    var currentPipContent: PipContent = .cameraPreview
    var currentFullScreenContent: FullScreenContent = .photoSnapchat
    var pipPlayer = AVPlayer()
    var fullScreenPlayer = AVPlayer()

    // Camera Management Properties
    let captureSession = AVCaptureSession()
    let videoFileOutput = AVCaptureMovieFileOutput()
    var cameraPreviewLayer = AVCaptureVideoPreviewLayer()
    var frontCamera: AVCaptureDevice?
    var microphone: AVCaptureDevice?
    var videoSnapIsReadyToPlay = false
    var cameraHasBeenSetup = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let snap = snap, snap.isReactionSnap { setupCamera() }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let snap = snap else { return }
        
        if snap.isReactionSnap {
            captureSession.removeOutput(videoFileOutput)
            
            if snap.type == .Video {
                pipPlayer.pause()
                pipPlayer.removeObserver(self, forKeyPath: "status")
                pipPlayerLayer.removeFromSuperlayer()
            }
        }
        
        if snap.isReactionSnap || snap.type == .Video {
            fullScreenPlayer.pause()
            fullScreenPlayer.removeObserver(self, forKeyPath: "status")
            fullScreenPlayerLayer.removeFromSuperlayer()
        }
    }
    
    func setupUI() {
        guard let snap = snap else { return }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        if snap.isReactionSnap || snap.type == .Video {
            fullScreenPlayerLayer = AVPlayerLayer(player: fullScreenPlayer)
            fullScreenPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            fullScreenPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
            fullScreenPlayerLayer.frame = view.layer.bounds
            view.layer.insertSublayer(fullScreenPlayerLayer, at: 0)
            
            fullScreenPlayer.addObserver(self, forKeyPath: "status", options: [], context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: fullScreenPlayer.currentItem)
        }

        if snap.type == .Video {
            currentFullScreenContent = .videoSnapchat
            guard let videoFileName = snap.mediaFileName else { return }

            // Setup full screen player
            let playerItem = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: videoFileName, ofType: ".mov")!))
            fullScreenPlayer.replaceCurrentItem(with: playerItem)
            
            if snap.isReactionSnap {
                // Setup pip for later use
                pipPlayerLayer = AVPlayerLayer(player: pipPlayer)
                pipPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                pipPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
                pipPlayerLayer.frame = previewView.layer.bounds
                previewView.layer.insertSublayer(pipPlayerLayer, at: 0)
                
                pipPlayer.addObserver(self, forKeyPath: "status", options: [], context: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(notification:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: pipPlayer.currentItem)
            }
        } else {
            if let imageName = snap.mediaFileName {
                imageView.image = UIImage(named: imageName)
            }
            imageView.frame = view.bounds
            view.addSubview(imageView)
        }
        
        if !snap.isReactionSnap {
            previewView.isHidden = true
            blurView.isHidden = true
            if snap.type == .Photo {
                startSnapTimer()
            }
        } else {
            // Blur View to hide snap until camera is ready
            blurView.frame = view.bounds
            blurView.effect = UIBlurEffect(style: .light)
            view.addSubview(blurView)
            view.bringSubview(toFront: blurView)
            
            // Close button shaddows
            closeButton.layer.shadowColor = UIColor.black.cgColor
            closeButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
            closeButton.layer.shadowOpacity = 0.5
            closeButton.layer.shadowRadius = 0.0
            closeButton.imageView?.tintColor = .white
        }
    
        // Hide UI properties for snap replay
        sendBar.isHidden = true
        previewView.alpha = 0
        closeButton.isHidden = true
        
        view.bringSubview(toFront: previewView)
    }
    
    func setupCamera() {
        frontCamera = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        microphone = AVCaptureDevice.defaultDevice(withDeviceType: .builtInMicrophone, mediaType: AVMediaTypeAudio, position: .unspecified)
        if let frontCamera = frontCamera, let microphone = microphone {
            do {
                try captureSession.addInput(AVCaptureDeviceInput(device: frontCamera))
                try captureSession.addInput(AVCaptureDeviceInput(device: microphone))
                cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                
                cameraPreviewLayer.frame = previewView.bounds
                cameraPreviewLayer.cornerRadius = 3
                previewView.layer.cornerRadius = 3
                previewView.layer.addSublayer(cameraPreviewLayer)
                previewView.alpha = 0.7
                previewView.layer.addSublayer(cameraPreviewLayer)
                captureSession.startRunning()
                cameraHasBeenSetup = true
                
                if snap?.type == .Photo {
                    startRecording()
                } else if fullScreenPlayer.status == .readyToPlay {
                    startRecording()
                }
            } catch _ {
                
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func playerItemDidReachEnd(notification: NSNotification) {
        if notification.object as? AVPlayerItem === fullScreenPlayer.currentItem && currentFullScreenContent == .videoSnapchat {
            if let snap = snap, snap.isReactionSnap {
                stopRecording()
            } else {
              self.dismiss(animated: false)
            }
        } else {
            // Either the object is the pip and is playing the recieved snap and must start over, or
            // the fullScreenPlayer is currently showing the user's reaction waiting for input
            let p: AVPlayerItem = notification.object as! AVPlayerItem
            p.seek(to: kCMTimeZero)
            
            if p === fullScreenPlayer.currentItem && currentFullScreenContent == .reactionPreview && currentPipContent == .videoSnapchat {
                pipPlayer.seek(to: kCMTimeZero)
            }
        }
    }
    
    // MARK: - Action
    
    @IBAction func sendButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: false)
    }
    
    @IBAction func closeButtonClicked(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    func startSnapTimer() {
        Timer.scheduledTimer(timeInterval: TimeInterval(self.snap?.length ?? 3), target: self, selector: #selector(SnapViewController.snapShouldFinishDisplay), userInfo: nil, repeats: false);
    }
    
    func snapShouldFinishDisplay() {
        if let snap = snap, snap.isReactionSnap {
            stopRecording()
        } else {
            self.dismiss(animated: false)
        }
    }
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if blurView.isHidden && currentFullScreenContent != .reactionPreview {
            stopRecording()
            if let snap = snap, !snap.isReactionSnap {
                self.dismiss(animated: false)
            } else if currentFullScreenContent == .videoSnapchat {
                fullScreenPlayer.pause()
            }
        }
    }
    
    func startSnapDisplay() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurView.alpha = 0
            self.previewView.alpha = 1
        }) { (completed) in
            self.blurView.isHidden = true
            
            if self.currentFullScreenContent == .photoSnapchat {
                self.startSnapTimer()
            } else if self.currentFullScreenContent == .videoSnapchat {
                self.fullScreenPlayer.play()
            }
        }
    }
    
    func playReaction() {
        sendBar.isHidden = false
        previewView.isHidden = false
        closeButton.isHidden = false
        
        if currentFullScreenContent == .photoSnapchat {
            imageView.removeFromSuperview()
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("reaction.mp4")
        
        fullScreenPlayer.replaceCurrentItem(with: AVPlayerItem(url: filePath))
        fullScreenPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        fullScreenPlayer.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        recipientNameLabel.text = snap?.authorName ?? ""
        fullScreenPlayer.play()
        currentFullScreenContent = .reactionPreview
        
        setupSnapPreviewView()
    }
    
    func setupSnapPreviewView() {
        guard let snap = snap else { return }
        
        if snap.type == .Photo, let imageName = snap.mediaFileName {
            let imageView = UIImageView(frame: previewView.bounds)
            imageView.image = UIImage(named: imageName)
            imageView.contentMode = .scaleAspectFill
            previewView.addSubview(imageView)
        } else if snap.type == .Video {
            guard let videoFileName = snap.mediaFileName else { return }
            let playerItem = AVPlayerItem(url: URL(fileURLWithPath: Bundle.main.path(forResource: videoFileName, ofType: ".mov")!))
            pipPlayer.replaceCurrentItem(with: playerItem)
            pipPlayer.seek(to: kCMTimeZero)
            pipPlayer.volume = 0
            pipPlayer.play()
        }
        
        currentPipContent = (snap.type == .Photo) ? .photoSnapchat : .videoSnapchat
    }
    
    func startRecording() {
        guard cameraHasBeenSetup else { return }
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsURL.appendingPathComponent("reaction.mp4")
        
        captureSession.addOutput(videoFileOutput)
        videoFileOutput.startRecording(toOutputFileURL: filePath, recordingDelegate: self)
    }
    
    func stopRecording() {
        if let snap = snap, snap.isReactionSnap {
            videoFileOutput.stopRecording()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            guard (object as? AVPlayer)?.status == .readyToPlay else { return }
            guard let snap = snap else { return }
            
            if object as? AVPlayer === fullScreenPlayer {
                if currentFullScreenContent == .reactionPreview {
                    fullScreenPlayer.play()
                } else if snap.isReactionSnap && currentFullScreenContent == .videoSnapchat{
                    self.videoSnapIsReadyToPlay = true
                    if cameraHasBeenSetup {
                        self.startRecording()
                    }
                } else if !snap.isReactionSnap && currentFullScreenContent == .videoSnapchat {
                    fullScreenPlayer.play()
                }
            }
        }
    }
}

extension SnapViewController: AVCaptureFileOutputRecordingDelegate {
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        if currentFullScreenContent == .photoSnapchat || (currentFullScreenContent == .videoSnapchat && fullScreenPlayer.status == .readyToPlay) {
            startSnapDisplay()
        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        cameraPreviewLayer.removeFromSuperlayer()
        
        if captureOutput.recordedDuration >= CMTimeMakeWithSeconds(1, 1) {
            playReaction()
        } else {
            self.dismiss(animated: false)
        }
    }
}














