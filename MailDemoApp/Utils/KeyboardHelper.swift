//
//  KeyboardHelper.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 24/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

final class KeyboardHelper {

    private var observers: [NSObjectProtocol?] = []
    
    func observeHeight(onChange: @escaping (CGFloat) -> Void) {
        let center = NotificationCenter.default
        let onAppear: (Notification) -> Void = { note in
            guard let keyboardSize = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
            onChange(keyboardSize.height)
        }
        let onShow = center.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil, using: onAppear)
        let onHide = center.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { _ in
            onChange(0)
        }
        observers.append(contentsOf: [onShow, onHide])
    }
    
    deinit {
        observers.forEach { observer in
            observer.flatMap(NotificationCenter.default.removeObserver)
        }
    }
}
