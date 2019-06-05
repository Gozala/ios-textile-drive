//
//  TextileThread.swift
//  TextileProvider
//
//  Created by Irakli Gozalishvili on 6/5/19.
//  Copyright © 2019 Ray Wenderlich. All rights reserved.
//
import UIKit
import Textile

struct TextileThread {
  let key: String
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TextileDelegate {
  var window: UIWindow?
  var recoveryPhrase:String?
  func applicationDidFinishLaunching(_ application: UIApplication) {
    do {
      // recoveryPhrase should be optional here, fix coming asap
      self.recoveryPhrase = try Textile.initialize(withDebug: false, logToDisk: false)
      // Return phrase to the user for secure, out of app, storage
      
      // Set the Textile delegate to self so we can make use of events such nodeStarted
      Textile.instance().delegate = self as TextileDelegate
    } catch {
      print("Unexpected error: \(error).")
    }
  }
  func nodeStarted() {
    print("Textile - node started.")
  }
  func nodeStopped() {
    print("Textile - node stopped.")
  }
  private func nodeFailedToStartWithError(error:NSError) {
    print("Textile - node failed to start: \(error).")
  }
  private func nodeFailedToStopWithError(error:NSError) {
    print("Textile -  node failed to stop: \(error).")
  }
  func nodeOnline() {
    print("Textile - node online")
    var error: NSError? = nil
    let threads = Textile.instance().threads.list(&error)
    if let reason = error {
      print("Threads Error: \(reason).")
    } else {
      print("Threads: \(threads) \(threads.itemsArray_Count).")
      for thread in threads.itemsArray {
        print("Thread: \((thread as! TextileCore.Thread).id_p)")
      }
    }
  }
  private func willStopNodeInBackgroundAfterDelay(seconds:TimeInterval) {
    print("Textile - will stop node after delay: %f", seconds)
  }
  func canceledPendingNodeStop() {
    print("Textile - canceled pending stop")
  }
}
