/* Copyright 2016 chaoyang805 zhangchaoyang805@gmail.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

let CYSnackbarShouldShowNotification = Notification.Name("show snackbar")
let CYSnackbarShouldDismissNotification = Notification.Name("dismiss snackbar")
let CYSnackbarUserInfoKey = "targetSnackbar"

@objc protocol CYSnackbarDelegate: NSObjectProtocol {
    
    @objc optional func snackbarWillAppear(_ snackbar: CYSnackbar)
    @objc optional func snackbarDidAppear(_ snackbar: CYSnackbar)
    @objc optional func snackbarWillDisappear(_ snackbar: CYSnackbar)
    @objc optional func snackbarDidDisappear(_ snackbar: CYSnackbar)
}

public enum CYSnackbarDuration: TimeInterval {
    case short = 1.5
    case long = 3
}

public class CYSnackbar: NSObject {
    
    private(set) lazy var view: CYSnackbarView = {
        let _barView = CYSnackbarView()
        // 为了Snackbar不被销毁
        _barView.snackbar = self
        return _barView
    }()
    
    private var showing: Bool = false
    
    private var dismissHandler: (() -> Void)?
    
    var duration: TimeInterval!
    
    private weak var delegate: CYSnackbarDelegate?
    
    public class func make(text: String, duration: CYSnackbarDuration) -> CYSnackbar {
        return make(text, duration: duration.rawValue)
    }
    
    private class func make(_ text: String, duration: TimeInterval) -> CYSnackbar {
        let snackbar = CYSnackbar()
        
        snackbar.setSnackbarText(text: text)
        snackbar.duration = duration
        snackbar.registerNotification()
        snackbar.delegate = CYSnackbarManager.default()
    
        return snackbar
    }
    
    public func show() {
        
        let record = CYSnackbarRecord(duration: duration, identifier: hash)
        CYSnackbarManager.default().show(record)
    }
    
    private func dispatchDismiss() {
        let record = CYSnackbarRecord(duration: duration, identifier: hash)
        CYSnackbarManager.default().dismiss(record)
    }
    
    // MARK: - Notification
    private func registerNotification() {
        
        let manager = CYSnackbarManager.default()
        NotificationCenter.default.addObserver(self, selector: #selector(CYSnackbar.handleNotification(_:)), name: CYSnackbarShouldShowNotification, object: manager)
        NotificationCenter.default.addObserver(self, selector: #selector(CYSnackbar.handleNotification(_:)), name: CYSnackbarShouldDismissNotification, object: manager)
    }
    
    private func unregisterNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleNotification(_ notification: NSNotification) {
        guard let identifier = notification.userInfo?[CYSnackbarUserInfoKey] as? Int else {
            NSLog("not found snackbar in notification's userInfo")
            return
        }
        
        guard identifier == self.hash else {
            NSLog("not found specified snackbar:\(identifier)")
            return
        }
        
        switch notification.name {
        case CYSnackbarShouldShowNotification:
            
            handleShowNotification()
            
        case CYSnackbarShouldDismissNotification:
            
            handleDismissNotification()
            
        default:
            break
        }
    }
    
    private func handleShowNotification() {
        
        self.showView()
    }
    
    private func handleDismissNotification() {
        
        self.dismissView()
    }
    
    // MARK: - Configure Snackbar
    public func setSnackbarText(text: String) {
        view.messageView.text = text
        view.messageView.sizeToFit()
    }
    
    public func action(with title: String, action: @escaping ((_ sender: Any) -> Void)) -> CYSnackbar {
        
        view.setAction(with: title, block: {
            action($0)
            self.dispatchDismiss()
        })
    
        return self
    }
    
    public func dismissHandler(block: @escaping (() -> Void)) -> CYSnackbar {
        self.dismissHandler = block
        return self
    }
    
    // MARK: - Snackbar View show & dismiss
    
    private func showView() {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        self.delegate?.snackbarWillAppear?(self)
        
        window.addSubview(view)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn,
            animations: { [weak self] in
            
                guard let `self` = self else { return }
                self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -snackbarHeight)
            },
            completion: { (done ) in
                    
                self.delegate?.snackbarDidAppear?(self)
                self.showing = true
            })
        
    }
    
    private func dismissView() {
        
        guard self.showing else { return }
        self.delegate?.snackbarWillDisappear?(self)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: UIViewAnimationOptions.curveEaseIn,
                animations: { [weak self] in
                    
                    guard let `self` = self else { return }
                    self.view.frame = self.view.frame.offsetBy(dx: 0, dy: snackbarHeight)
                    
                },
                completion: { (done) in
                    
                    self.showing = false
                    
                    self.view.snackbar = nil
                    self.view.removeFromSuperview()
                    
                    self.dismissHandler?()
                    
                    self.delegate?.snackbarDidDisappear?(self)
                    self.delegate = nil
                    
                    self.unregisterNotification()
                    
            } )
        
    }
}
