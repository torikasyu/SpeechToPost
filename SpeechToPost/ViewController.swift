//
//  ViewController.swift
//  SpeechToPost
//
//  Created by TANAKAHiroki on 2017/01/30.
//  Copyright © 2017年 torikasyu. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var tvContent: UITextView!
    @IBOutlet weak var btnSpeech: UIButton!
    @IBOutlet weak var btnTweet: UIButton!
    
    enum Mode {
        case none
        case recording
    }
    fileprivate var mode = Mode.none
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.btnSpeech.isEnabled = true
                    
                case .denied:
                    self.btnSpeech.isEnabled = false
                    self.btnSpeech.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.btnSpeech.isEnabled = false
                    self.btnSpeech.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.btnSpeech.isEnabled = false
                    self.btnSpeech.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    func setMode(_ mode:Mode){
        self.mode = mode
        switch mode {
        case .none:
            btnSpeech.setTitle("開始", for: .normal)
        case .recording:
            tvContent.text = "(音声入力受付中)"
            btnSpeech.setTitle("停止", for: .normal)
        }
    }
    
    fileprivate func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.btnSpeech.isEnabled = false
        setMode(.none)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func startRecording() throws {
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                if (self.mode == .recording) {
                    self.tvContent.text = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnSpeech.isEnabled = true
                self.btnSpeech.setTitle("開始(126)", for: [])
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        self.tvContent.text = "(Go ahead, I'm listening)"
    }
    
    // MARK: SFSpeechRecognizerDelegate
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.btnSpeech.isEnabled = true
            self.btnSpeech.setTitle("開始(144)", for: [])
        } else {
            self.btnSpeech.isEnabled = false
            self.btnSpeech.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    @IBAction func btnSpeechAction(_ sender: Any) {
        
        switch mode {
        case .none:
            do {
                try self.startRecording()
                setMode(.recording)
            } catch {
                
            }
            break
        case .recording:
            stopRecording()
            setMode(.none)
            break
        }
        
        /*
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.btnSpeech.isEnabled = false
            self.btnSpeech.setTitle("Stopping", for: .disabled)
        } else {
            try! startRecording()
            self.btnSpeech.setTitle("Stop recording22", for: [])
        }
         */
    }
    
    @IBAction func btnTweetAction(_ sender: Any) {
        let success = Util.doTweet(self.tvContent.text)
        
        if(success)
        {
            self.tvContent.text = "(Tweetしました)"
        }
        else
        {
            self.tvContent.text = "(Tweet失敗しました)"
        }
        self.setMode(.none)
    }
    
    
    
    
}

