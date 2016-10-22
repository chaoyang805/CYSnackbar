//
//  SnackbarManager.swift
//  DoubanMovie
//
//  Created by chaoyang805 on 16/9/6.
//  Copyright © 2016年 jikexueyuan. All rights reserved.
//

import UIKit

class CYSnackbarManager: NSObject {

    private override init() { super.init() }
    
    private static let instance: CYSnackbarManager = CYSnackbarManager()
    
    static func `default`() -> CYSnackbarManager {
        return instance
    }
    
    fileprivate var currentSnackbar: CYSnackbarRecord?
    private var nextSnackbar: CYSnackbarRecord?
    
    func show(_ r: CYSnackbarRecord) {
        // 如果当前有显示的Snackbar
        if isCurrentSnackbar(r) {
             updateTimeout(r)
        } else if isNextSnackbar(r) {
            // reconfig timeout
            nextSnackbar?.duration = r.duration
        } else {
            nextSnackbar = r
        }
        
        if currentSnackbar != nil {
            cancelCurrentSnackbar()
            return
        } else {
//            currentSnackbar = nil
            showNextSnackbar()
        }
        
    }
    
    func dismiss(_ r: CYSnackbarRecord) {
        if isCurrentSnackbar(r) {
            
            cancelCurrentSnackbar()
            
        } else if isNextSnackbar(r) {
            
            cancelNextSnackbar()
        }
    }
    
    private func cancelCurrentSnackbar() {
        
        let notification = Notification(name: CYSnackbarShouldDismissNotification, object: self, userInfo: [CYSnackbarUserInfoKey: currentSnackbar!.identifier])
        
        NotificationCenter.default.post(notification)
        
    }
    
    private func cancelNextSnackbar() {
        let notification = Notification(name: CYSnackbarShouldDismissNotification, object: self, userInfo: [CYSnackbarUserInfoKey: nextSnackbar!.identifier])
        
        NotificationCenter.default.post(notification)
    }
    
    fileprivate func isCurrentSnackbar(_ r: CYSnackbarRecord) -> Bool {
        if currentSnackbar != nil && currentSnackbar!.identifier == r.identifier {
            return true
        }
        return false
    }
    
    private func isNextSnackbar(_ r: CYSnackbarRecord) -> Bool {
        if nextSnackbar != nil && nextSnackbar!.identifier == r.identifier {
            return true
        }
        return false
    }

    fileprivate func showNextSnackbar() {
        
        if nextSnackbar != nil {

            currentSnackbar = nextSnackbar
            nextSnackbar = nil
            let notification = Notification(name: CYSnackbarShouldShowNotification, object: self, userInfo: [CYSnackbarUserInfoKey: currentSnackbar!.identifier])

            NotificationCenter.default.post(notification)
        }
    }
    
    
    // MARK: - Scheduled Timer
    private var timer: Timer!
    
    fileprivate func scheduleTimeout(_ r: CYSnackbarRecord) {
        let duration = r.duration
        
        timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(CYSnackbarManager.onTimeout(_:)), userInfo: r.identifier, repeats: false)
    }
    
    private func updateTimeout(_ record: CYSnackbarRecord) {
        timer.invalidate()
        scheduleTimeout(record)
    }
    
    @objc private func onTimeout(_ timer: Timer) {
        
        if let identifier = timer.userInfo as? Int {
            self.dismiss(CYSnackbarRecord(duration: 0, identifier: identifier))
        } else {
            NSLog("timeout couldn't find the snackbar in userInfo")
        }
        timer.invalidate()
    }
}
// MARK: - SnackbarDelegate
extension CYSnackbarManager: CYSnackbarDelegate {
    
    func snackbarDidAppear(_ snackbar: CYSnackbar) {
        let r = CYSnackbarRecord(duration: snackbar.duration, identifier: snackbar.hash)
        scheduleTimeout(r)
    }
    
    func snackbarDidDisappear(_ snackbar: CYSnackbar) {
        let r = CYSnackbarRecord(duration: snackbar.duration, identifier: snackbar.hash)
        if isCurrentSnackbar(r) {
            currentSnackbar = nil
        }
        showNextSnackbar()
    }
}
