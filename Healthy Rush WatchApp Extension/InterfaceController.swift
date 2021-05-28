//
//  InterfaceController.swift
//  Healthy Rush WatchApp Extension
// 
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate, WKExtendedRuntimeSessionDelegate {

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        print("Session stopped at", Date())
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Session started at", Date())
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
    }
    
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }
    
    var extendedSession : WKExtendedRuntimeSession!
    var session: WCSession!
    var motionManager : CMMotionManager!
    var oldX : Double = 0.0
    @IBOutlet weak var startOutlet: WKInterfaceButton!
    @IBOutlet weak var stopOutlet: WKInterfaceButton!
    @IBOutlet weak var trackingLabel: WKInterfaceLabel!
    @IBOutlet weak var jumpLabel: WKInterfaceLabel!
    
    @IBAction func startButton() {
        
        extendedSession = WKExtendedRuntimeSession()
        extendedSession.delegate = self
        extendedSession.start()
        self.motionManager = CMMotionManager()
        if self.motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60
            
            trackingLabel.setText("I am tracking jumps. Enjoy your gaming session!")
            startOutlet.setEnabled(false)
            stopOutlet.setEnabled(true)
            
            self.motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
                if let myData = data{
                    if myData.acceleration.x - self.oldX < -0.5 {
                        //send jump
                        self.session.sendMessage(["movement" : true], replyHandler: nil, errorHandler: nil)
                        self.jumpLabel.setHidden(false)
                        self.jumpLabel.setText("Jump detected!")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.jumpLabel.setHidden(true)
                        }
                    }
                    self.oldX = myData.acceleration.x
                }
            }
        }
    }
    
    @IBAction func stopButton() {
        
        motionManager.stopAccelerometerUpdates()
        extendedSession.invalidate()
        
        stopOutlet.setEnabled(false)
        startOutlet.setEnabled(true)
        
        trackingLabel.setText("Not tracking jumps at the moment.")
    }
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
    }
    
    override func willActivate() {
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
    }
}

