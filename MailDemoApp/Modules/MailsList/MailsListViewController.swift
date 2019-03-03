//
//  MailsListViewController.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 21/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

class MailsListViewController: UITableViewController {

    var output: MailsListViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(with: MailListCell.self)
        output.viewIsReady()
    }
    
    @IBAction func composeButtonDidPress(_ sender: UIBarButtonItem) {
        let mail = output.handleComposeMail()
        let dvc = MailConfigurator.configureModule(mail: mail, isReadonly: false)
        navigationController?.pushViewController(dvc, animated: true)
    }
}

extension MailsListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.mailsCount
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(with: MailListCell.self)
        return cell.configured(with: output[indexPath.row], showsIcon: output.showsMailIcons)
    }
}

extension MailsListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dvc = MailConfigurator.configureModule(mail: output[indexPath.row], isReadonly: output.areMailsReadonly)
        navigationController?.pushViewController(dvc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? MailListCell else { return }
        output.handleDeletion(mailId: cell.mailId)
    }
}

extension MailsListViewController: MailsListViewInput {
    
    func updateUI() {
        tableView.reloadData()
    }
    
    func setupComposeButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeButtonDidPress(_:)))
    }
}
