//
//  MailViewController.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

class MailViewController: UIViewController {
    
    var output: MailViewOutput!

    @IBOutlet weak var senderTextField: UITextField!
    @IBOutlet weak var recipientTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    private let keyboardHelper = KeyboardHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localizations.Mail.title
        keyboardHelper.observeHeight { [weak self] kbHeight in
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbHeight, right: 0)
            self?.bodyTextView.contentInset = insets
            self?.bodyTextView.scrollIndicatorInsets = insets
        }
        let replyButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(actionButtonDidPress(_:)))
        navigationItem.rightBarButtonItem = replyButton
        output.viewIsReady()
        bodyTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        syncToPresenter()
    }
    
    @IBAction func actionButtonDidPress(_ sender: UIBarButtonItem) {
        syncToPresenter()
        let actionSheet = UIAlertController(title: Localizations.Common.chooseAction, message: nil, preferredStyle: .actionSheet)
        for action in output.availableActions() {
            let handler: (UIAlertAction) -> Void = { _ in
                self.output.handle(action: action)
            }
            switch action {
            case .reply, .forward, .moveToFolder, .send:
                actionSheet.addAction(UIAlertAction(title: action.title, style: .default, handler: handler))
            case .markAsSpam, .delete:
                actionSheet.addAction(UIAlertAction(title: action.title, style: .destructive, handler: handler))
            }
        }
        actionSheet.addAction(UIAlertAction(title: Localizations.Common.cancel, style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func syncToPresenter() {
        let map: (String?) -> String? = { input in
            guard let input = input else { return nil }
            return input.isEmpty ? nil : input
        }
        output.handleUpdateMail(recipient: map(recipientTextField.text), subject: map(subjectTextField.text), body: bodyTextView.text)
    }
}

extension MailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case senderTextField:
            recipientTextField.becomeFirstResponder()
        case recipientTextField:
            subjectTextField.becomeFirstResponder()
        case subjectTextField:
            bodyTextView.becomeFirstResponder()
        default:
            break
        }
        return false
    }
}

extension MailViewController: MailViewInput {
    
    func updateUI(mail: MDMail, body: String, isReadonly: Bool) {
        senderTextField.text = mail.sender
        recipientTextField.text = mail.recipient
        subjectTextField.text = mail.subject
        bodyTextView.text = body
        [recipientTextField, subjectTextField].forEach { view in
            view?.isUserInteractionEnabled = !isReadonly
        }
        bodyTextView.isEditable = !isReadonly
    }
    
    func dismiss() {
        navigationController?.popViewController(animated: true)
    }
    
    func handleCompose(mail: MDMail) {
        if let controllers = navigationController?.viewControllers.filter({ $0 != self }) {
            let dvc = MailConfigurator.configureModule(mail: mail, isReadonly: false)
            navigationController?.setViewControllers(controllers + [dvc], animated: true)
        }
    }
    
    func handleMoveMail(toFolders: [MDFolder]) {
        let actionSheet = UIAlertController(title: Localizations.Folders.chooseFolder, message: nil, preferredStyle: .actionSheet)
        for folder in toFolders {
            actionSheet.addAction(UIAlertAction(title: folder.title, style: .default) { _ in
                self.output.handleMove(toFolder: folder)
            })
        }
        actionSheet.addAction(UIAlertAction(title: Localizations.Common.cancel, style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
}
