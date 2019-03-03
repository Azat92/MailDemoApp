//
//  YapDbService+DataGeneration.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 22.02.19.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

private struct GeneratedUser {
    
    let firstName: String
    let lastName: String
    
    var email: String {
        return "\(firstName.lowercased()).\(lastName.lowercased())@gmx.de"
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

final class DataGenerator {
    
    private let loremIpsum: String = {
        try! String(contentsOf: Bundle.main.url(forResource: "LoremIpsum", withExtension: nil)!)
    }()

    func generateTestData(connection: YapDatabaseConnection,
                          onStore: @escaping (MDMail, MDMailBody, YapDatabaseReadWriteTransaction) -> Void) {
        let me = GeneratedUser(firstName: "Azat", lastName: "Almeev")
        let firstNamesRaw = try! String(contentsOf: Bundle.main.url(forResource: "FirstNames", withExtension: nil)!)
        let firstNames = firstNamesRaw.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let lastNamesRaw = try! String(contentsOf: Bundle.main.url(forResource: "LastNames", withExtension: nil)!)
        let lastNames = lastNamesRaw.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let folderTypes: [FolderType] = [.inbox, .outbox, .drafts]
        let subjectsRaw = try! String(contentsOf: Bundle.main.url(forResource: "MailSubjects", withExtension: nil)!)
        let subjects = subjectsRaw.components(separatedBy: .newlines).filter { !$0.isEmpty }
        let generateUser: () -> GeneratedUser = {
            let firstNameIdx = Int(arc4random_uniform(UInt32(firstNames.count)))
            let lastNameIdx = Int(arc4random_uniform(UInt32(lastNames.count)))
            return GeneratedUser(firstName: firstNames[firstNameIdx], lastName: lastNames[lastNameIdx])
        }
        let generateBody: (String, String?) -> String = { sender, recipient in
            let length = self.loremIpsum.count
            let initial = Int(arc4random_uniform(UInt32(length / 2)))
            let rest = Int(arc4random_uniform(UInt32(length - initial)))
            let start = self.loremIpsum.index(self.loremIpsum.startIndex, offsetBy: initial)
            let end = self.loremIpsum.index(start, offsetBy: rest)
            let text = String(self.loremIpsum[start ..< end])
            let recipientPlace = recipient.flatMap { "Dear \($0),\r\n\r\n" } ?? ""
            return "\(recipientPlace)\(text).\r\n\r\nViele Grüße, \(sender)"
        }
        connection.readWrite { transaction in
            for _ in 0 ..< 100 {
                let folderIdx = Int(arc4random_uniform(UInt32(folderTypes.count)))
                let folderType = folderTypes[folderIdx]
                let subjectIdx = Int(arc4random_uniform(UInt32(subjects.count)))
                let subject = subjects[subjectIdx]
                let mail: MDMail
                let mailBody: String
                switch folderType {
                case .inbox:
                    let sender = generateUser()
                    mail = MDMail(sender: sender.email, subject: subject, recipient: me.email, isIncome: true, folderId: folderType.id)
                    mailBody = generateBody(sender.fullName, me.fullName)
                case .outbox:
                    let recipient = generateUser()
                    mail = MDMail(sender: me.email, subject: subject, recipient: recipient.email, isIncome: false, folderId: folderType.id)
                    mailBody = generateBody(me.fullName, recipient.fullName)
                case .drafts:
                    let recipient = arc4random_uniform(100) > 50 ? generateUser() : nil
                    let subject = arc4random_uniform(100) > 50 ? subject : nil
                    mail = MDMail(sender: me.email, subject: subject, recipient: recipient?.email, isIncome: false, folderId: folderType.id)
                    mailBody = generateBody(me.fullName, recipient?.fullName)
                case .spam:
                    let sender = generateUser()
                    mail = MDMail(sender: sender.email, subject: subject, recipient: me.email, isIncome: true, folderId: folderType.id)
                    mailBody = generateBody(sender.fullName, me.fullName)
                case .trash:
                    let isIncoming = arc4random_uniform(100) > 50
                    let sender = isIncoming ? generateUser() : me
                    let recipient = isIncoming ? me : generateUser()
                    mail = MDMail(sender: sender.email, subject: subject, recipient: recipient.email, isIncome: isIncoming, folderId: folderType.id)
                    mailBody = generateBody(sender.fullName, recipient.fullName)
                default:
                    continue
                }
                onStore(mail, MDMailBody(id: mail.id, body: mailBody), transaction)
            }
        }
    }
}
