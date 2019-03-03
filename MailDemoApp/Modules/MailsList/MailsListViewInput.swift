//
//  MailsListViewInput.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 21/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

protocol MailsListViewInput: class {
    
    var title: String? { get set }

    func updateUI()
    
    func setupComposeButton()
}
