//
//  ViewController.swift
//  SpeechDemo
//
//  Created by Gabriel Theodoropoulos on 2/10/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation

class ViewController: UIViewController,AVSpeechSynthesizerDelegate,SettingsViewDelegate {

    @IBOutlet weak var tvEditor: UITextView!
    
    @IBOutlet weak var btnSpeak: UIButton!
    
    @IBOutlet weak var btnPause: UIButton!
    
    @IBOutlet weak var btnStop: UIButton!
    
    @IBOutlet weak var pvSpeechProgress: UIProgressView!
    
    var speechSynthesizer = AVSpeechSynthesizer()
    
    var rate: Float!
    var pitch: Float!
    var volume: Float!
    
    var totalUtterances: Int! = 0
    var currentUtterance: Int! = 0
    
    var totalTextLength: Int = 0
    var spokenTextLengths: Int = 0
    
    var preferredVoiceLanguageCode: String! = ""
    
    var previosSelectedRange: NSRange!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        speechSynthesizer.delegate = self
        
        //
        setInitialFontAttribute()
        
        //load values
        if !loadSettings(){
            registerDefaultSettings()
        }
        
        // Make the corners of the textview rounded and the buttons look like circles.
        tvEditor.layer.cornerRadius = 15.0
        btnSpeak.layer.cornerRadius = 40.0
        btnPause.layer.cornerRadius = 40.0
        btnStop.layer.cornerRadius = 40.0
        
        // Set the initial alpha value of the following buttons to zero (make them invisible).
        btnPause.alpha = 0.0
        btnStop.alpha = 0.0
        
        // Make the progress view invisible and set is initial progress to zero.
        pvSpeechProgress.alpha = 0.0
        pvSpeechProgress.progress = 0.0
        
        
        // Create a swipe down gesture for hiding the keyboard.
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDownGesture(gestureRecognizer:)))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    // MARK: Custom method implementation
    
    func handleSwipeDownGesture(gestureRecognizer: UISwipeGestureRecognizer) {
        tvEditor.resignFirstResponder()
    }
    
    func registerDefaultSettings(){
        
        rate = AVSpeechUtteranceDefaultSpeechRate
        pitch = 1.0
        volume = 1.0
        
        let defaultSpeechSettings:Dictionary<String,AnyObject>  = ["rate":rate,"pitch":pitch,"volume":volume]
        UserDefaults.standard.register(defaults: defaultSpeechSettings)
        
        
    }
    
    func loadSettings() -> Bool{
        
        let uDefaults = UserDefaults.standard as UserDefaults
        
        if let theRate = uDefaults.value(forKey: "rate") as? Float{
            rate = theRate
            pitch = uDefaults.value(forKey: "pitch") as! Float
            volume = uDefaults.value(forKey: "volume") as! Float
            return true
        }
        return false
        
    }
    
    // MARK: IBAction method implementation
    
    @IBAction func speak(_ sender: AnyObject) {
        
//        if !speechSynthesizer.isSpeaking{
//            let speechUtterance = AVSpeechUtterance(string: tvEditor.text)
//            
//            speechUtterance.rate = rate
//            speechUtterance.pitchMultiplier = pitch
//            speechUtterance.volume = volume
//            
//            speechSynthesizer.speak(speechUtterance)
//
//        }else{
//            speechSynthesizer.continueSpeaking()
//        }
        
        if !speechSynthesizer.isSpeaking{
            
            let paragraph = tvEditor.text .components(separatedBy: CharacterSet.newlines)
            totalUtterances = paragraph.count
            currentUtterance = 0
            totalTextLength = 0
            spokenTextLengths = 0
            
            for  pieceofText in paragraph{
                
                let speechUtterance = AVSpeechUtterance(string: pieceofText)
                speechUtterance.rate = rate
                speechUtterance.pitchMultiplier = pitch
                speechUtterance.volume = volume
                speechUtterance.postUtteranceDelay = 0.005
                
                //
                totalTextLength = totalTextLength + pieceofText.utf16.count
                
                //
                if let voiceLanguageCode = preferredVoiceLanguageCode{
                    let voice = AVSpeechSynthesisVoice(language: voiceLanguageCode)
                    speechUtterance.voice = voice
                    
                }
                speechSynthesizer.speak(speechUtterance)
            }
        }else{
            speechSynthesizer.continueSpeaking()
            
        }
        
        animateActionButtonAppearance(shouldHideSpeakButton: true)
    }
    
    
    
    @IBAction func pauseSpeech(_ sender: AnyObject) {
        
        speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.word)
        animateActionButtonAppearance(shouldHideSpeakButton: false)
        //
        //AVSpeechBoundaryImmediate: Using this, the pause happens instantly.
        //AVSpeechBoundaryWord: With this, the pause happens once the current word has been spoken.

    }
    
    
    @IBAction func stopSpeech(_ sender: AnyObject) {
        
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        animateActionButtonAppearance(shouldHideSpeakButton: false)
    }
    
    func animateActionButtonAppearance(shouldHideSpeakButton:Bool){
        
        var speakButtonAlphaValue:CGFloat = 1.0
        var pauseStopButtonsAlphaValue:CGFloat = 0.0
        
        if shouldHideSpeakButton{
            speakButtonAlphaValue = 0.0
            pauseStopButtonsAlphaValue = 1.0
        }
        
        UIView.animate(withDuration: 0.25) { 
            
            self.btnSpeak.alpha = speakButtonAlphaValue
            self.btnStop.alpha = pauseStopButtonsAlphaValue
            self.btnPause.alpha = pauseStopButtonsAlphaValue
            self.pvSpeechProgress.alpha = pauseStopButtonsAlphaValue
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "idSegueSettings"{
            let settingsVC = segue.destination as! SettingsViewController
            settingsVC.delegate = self
        }
    }
    
    //MARK: Settings View Controller delegate
    func didSaveSettings() {
        
        let settings = UserDefaults.standard as UserDefaults!
        
        rate = settings?.value(forKey: "rate") as! Float
        pitch = settings?.value(forKey: "pitch") as! Float
        volume = settings?.value(forKey: "volume") as! Float
        
        preferredVoiceLanguageCode  = settings?.value(forKey: "languageCode") as! String
        
        
    }
    
    //MARK: Speech synthesizer delegate Methods
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        
        currentUtterance = currentUtterance + 1
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        
        spokenTextLengths = spokenTextLengths + utterance.speechString.utf16.count + 1
        
        let progress:Float = Float(spokenTextLengths * 100 / totalTextLength)
        pvSpeechProgress.progress = progress/100
        
        if currentUtterance == totalUtterances{
            animateActionButtonAppearance(shouldHideSpeakButton: false)
            
            unSelectedLastWord()
            previosSelectedRange = nil
        }
        
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        
        let progress:Float = Float(spokenTextLengths + characterRange.location) * 100 / Float(totalTextLength)
        pvSpeechProgress.progress = progress/100
        
        
        // Determine the current range in the whole text (all utterances), not just the current one.
        let rangeInTotalText = NSMakeRange(spokenTextLengths + characterRange.location, characterRange.length)
        
        // Select the specified range in the textfield.
        tvEditor.selectedRange = rangeInTotalText
        
        // Store temporarily the current font attribute of the selected text.
        
        let currentAttributes = tvEditor.attributedText.attributes(at: rangeInTotalText.location, effectiveRange: nil)
        
        let fontAttribute:AnyObject? = currentAttributes[NSFontAttributeName]
        
        // Assign the selected text to a mutable attributed string.
        
        let attributedString = NSMutableAttributedString(string: tvEditor.attributedText.attributedSubstring(from: rangeInTotalText).string)
        
        // Make the text of the selected area orange by specifying a new attribute.
        
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.orange, range: NSMakeRange(0, attributedString.length))
        
        // Make sure that the text will keep the original font by setting it as an attribute.
        attributedString.addAttribute(NSFontAttributeName, value: fontAttribute!, range: NSMakeRange(0, attributedString.string.utf16.count))
        
        // In case the selected word is not visible scroll a bit to fix this.
        tvEditor.scrollRangeToVisible(rangeInTotalText)
        
        //Begin editing the text view
        tvEditor.textStorage.beginEditing()
        
        //// Replace the selected text with the new one having the orange color attribute
        tvEditor.textStorage.replaceCharacters(in: rangeInTotalText, with: attributedString)
        
        // If there was another highlighted word previously (orange text color), then do exactly the same things as above and change the foreground color to black.
        if let previousRange  = previosSelectedRange{
            
            let previousAttributedText = NSMutableAttributedString(string: tvEditor.attributedText.attributedSubstring(from: previousRange).string)
            
            // Make the text of the selected area orange by specifying a new attribute.
            
            previousAttributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, previousAttributedText.length))
            
            // Make sure that the text will keep the original font by setting it as an attribute.
            previousAttributedText.addAttribute(NSFontAttributeName, value: fontAttribute!, range: NSMakeRange(0, previousAttributedText.length))
            
            tvEditor.textStorage.replaceCharacters(in: previousRange, with: previousAttributedText)
        }
        tvEditor.textStorage.endEditing()
        previosSelectedRange = rangeInTotalText
        
        
    }
    
    
    //Attributed 
    
    func setInitialFontAttribute(){
        
        let rangeOfWholeText = NSMakeRange(0, tvEditor.text.utf16.count)
        
        let attributedText = NSMutableAttributedString(string: tvEditor.text)
        
        attributedText.addAttribute(NSFontAttributeName, value: UIFont(name: "Arial",size: 18.0)!, range: rangeOfWholeText)
        
        tvEditor.textStorage.beginEditing()
        tvEditor.textStorage.replaceCharacters(in: rangeOfWholeText
            , with: attributedText)
        tvEditor.textStorage.endEditing()
        
        
    }
    
    func unSelectedLastWord(){
        
        if let selectedRange = previosSelectedRange{
            
            let currentAttributes = tvEditor.attributedText.attributes(at: selectedRange.location
                , effectiveRange: nil)
            
            let fontAttribute = currentAttributes[NSFontAttributeName]
            
            let attributedWord = NSMutableAttributedString(string: tvEditor.attributedText.attributedSubstring(from: selectedRange).string)
            attributedWord.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, attributedWord.length))
            
            attributedWord.addAttribute(NSFontAttributeName, value: fontAttribute!, range: NSMakeRange(0, attributedWord.length))
            
            tvEditor.textStorage.beginEditing()
            tvEditor.textStorage.replaceCharacters(in: selectedRange, with: attributedWord)
            tvEditor.textStorage.endEditing()
            
            
            
        }
    }
    
}

