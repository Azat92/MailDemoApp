//
//  MailsListViewOutput.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 21/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

protocol MailsListViewOutput {
    
    var areMailsReadonly: Bool { get }
    
    var showsMailIcons: Bool { get }
    
    var mailsCount: Int { get }
    
    subscript (index: Int) -> MDMail { get }

    func viewIsReady()
    
    func handleDeletion(mailId: String)
    
    func handleComposeMail() -> MDMail
}
