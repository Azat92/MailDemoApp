//
//  MailViewInput.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

protocol MailViewInput: class {

    func updateUI(mail: MDMail, body: String, isReadonly: Bool)
    
    func dismiss()
    
    func handleCompose(mail: MDMail)
    
    func handleMoveMail(toFolders: [MDFolder])
}
