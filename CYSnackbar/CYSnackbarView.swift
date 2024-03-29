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

internal let snackbarHeight: CGFloat = 44

class CYSnackbarView: UIView {
    
    
    var messageView: UILabel!
    
    var actionButton: UIButton!
    var actionBlock: ((_ sender: Any) -> Void)?
    
    var snackbar: CYSnackbar?
    
    convenience init() {

        let x: CGFloat = 0
        let y = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        self.init(frame: CGRect(x: x, y: y, width: width, height: snackbarHeight))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 2
        self.layer.shadowOpacity = 0.5
        
        // 初始化messageView 用于显示提示信息
        messageView = UILabel()
        messageView.frame = CGRect(x: 0, y: 0, width: 200, height: snackbarHeight)
        
        messageView.backgroundColor = UIColor.clear
        messageView.font = UIFont(name: "PingFang SC", size: 14)
        messageView.text = "Placeholder text"
        messageView.sizeToFit()
        messageView.textColor = UIColor.white
        self.addSubview(messageView)
        
        actionButton = UIButton(type: .system)
        actionButton.setTitle("OK", for: .normal)
        actionButton.tintColor = UIColor(red: 0.188, green: 0.688, blue: 0.296, alpha: 1)
        actionButton.sizeToFit()
    }
    
    internal func setAction(with title: String, block: @escaping (_ sender: Any) -> Void) {
        self.actionBlock = block
        var newTitle = title
        if title.characters.count >= 3 {
             newTitle = title.substring(to: title.index(title.startIndex, offsetBy: 2)) + "..."
        }
        
        actionButton.setTitle(newTitle, for: .normal)
        actionButton.sizeToFit()
        if actionButton.superview == nil {
            self.addSubview(actionButton)
        }
        self.actionButton.addTarget(self, action: #selector(CYSnackbarView.actionSelector(_:)), for: .touchUpInside)
    }
    
    @objc private func actionSelector(_ sender: Any) {
        self.actionBlock?(sender)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var x: CGFloat = 8 + messageView.bounds.width / 2
        let y = self.bounds.midY
//        var y = self.bounds.height / 2 - self.messageView.bounds.height / 2
        messageView.center = CGPoint(x: x, y: y)
//        messageView.frame.origin = CGPoint(x: x, y: y)
        
        x = self.bounds.width - actionButton.bounds.width / 2 - 8
//        y = self.bounds.height / 2 - actionButton.bounds.height / 2
        actionButton.center = CGPoint(x: x, y: y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
