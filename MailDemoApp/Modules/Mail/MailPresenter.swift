//
//  MailPresenter.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

final class MailPresenter {

    weak var view: MailViewInput?
    
    private let foldersService: FoldersService
    private let mailsService: MailsService
    private var mail: MDMail
    private var body: MDMailBody
    private let isReadonly: Bool
    
    private var mailWasMovedOrDeleted: Bool = false
    
    init(foldersService: FoldersService, mailsService: MailsService, mail: MDMail, isReadonly: Bool) {
        self.foldersService = foldersService
        self.mailsService = mailsService
        self.mail = mail
        self.body = mailsService.bodyFor(mail: mail)
        self.isReadonly = isReadonly
    }
}

extension MailPresenter: MailViewOutput {
    
    func viewIsReady() {
        view?.updateUI(mail: mail, body: body.body, isReadonly: isReadonly)
    }
    
    func handleUpdateMail(recipient: String?, subject: String?, body: String) {
        guard !isReadonly && !mailWasMovedOrDeleted else { return }
        mail = mail.updated(recipient: recipient, subject: subject)
        self.body = self.body.updated(body: body)
        mailsService.update(mail: mail, body: self.body)
    }
    
    func availableActions() -> [MailAction] {
        let hasCustomFolders = foldersService.hasCustomFolders()
        switch mail.folderId {
        case FolderType.inbox.id:
            return [.reply, .forward, hasCustomFolders ? .moveToFolder : nil, .markAsSpam, .delete].compactMap { $0 }
        case FolderType.outbox.id:
            return [.reply, .forward, .delete]
        case FolderType.drafts.id:
            return [mail.readyToSend ? .send : nil, .delete].compactMap { $0 }
        case FolderType.spam.id, FolderType.trash.id:
            return [.moveToFolder, .delete]
        default:
            return [.reply, .forward, .moveToFolder, .markAsSpam, .delete]
        }
    }
    
    func handle(action: MailAction) {
        switch action {
        case .markAsSpam:
            mailsService.move(mail: mail, toFolder: FolderType.spam.id)
            mailWasMovedOrDeleted = true
            view?.dismiss()
        case .delete:
            mailsService.deleteMail(id: mail.id)
            mailWasMovedOrDeleted = true
            view?.dismiss()
        case .send:
            if mail.readyToSend {
                mailsService.move(mail: mail, toFolder: FolderType.outbox.id)
                mailWasMovedOrDeleted = true
                view?.dismiss()
            }
        case .reply:
            view?.handleCompose(mail: mailsService.compose(reply: mail))
        case .forward:
            view?.handleCompose(mail: mailsService.compose(forward: mail, body: body.body))
        case .moveToFolder:
            if !mail.isIncome && mail.folderId == FolderType.trash.id {
                if let outbox = foldersService.getAllFolders().first(where: { $0.folderType == .outbox }) {
                    view?.handleMoveMail(toFolders: [outbox])
                }
            } else {
                var folders = foldersService.getCustomFolders()
                if let inbox = foldersService.getAllFolders().first(where: { $0.folderType == .inbox }) {
                    folders = [inbox] + folders
                }
                let available = folders.filter { $0.id != mail.folderId }
                view?.handleMoveMail(toFolders: available)
            }
        }
    }
    
    func handleMove(toFolder: MDFolder) {
        mailsService.move(mail: mail, toFolder: toFolder.id)
        mailWasMovedOrDeleted = true
        view?.dismiss()
    }
}
