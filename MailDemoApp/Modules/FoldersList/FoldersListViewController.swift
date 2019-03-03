//
//  FoldersListViewController.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 04/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

class FoldersListViewController: UITableViewController {
    
    var output: FoldersListViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localizations.Folders.title
        tableView.register(with: FolderListCell.self)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonDidPress(_:)))
        navigationItem.rightBarButtonItem = addButton
        output.viewIsReady()
    }
    
    @IBAction func addBarButtonDidPress(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: Localizations.Folders.addFolder, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = Localizations.Folders.folderName
        }
        alert.addAction(UIAlertAction(title: Localizations.Common.ok, style: .default) { [weak alert] _ in
            guard let name = alert?.textFields?.first?.text, !name.isEmpty else { return }
            self.output.handleAddFolder(name: name)
        })
        alert.addAction(UIAlertAction(title: Localizations.Common.cancel, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension FoldersListViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return output.groupsCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.foldersCount(inGroup: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(with: FolderListCell.self)
        return cell.configured(with: output[indexPath])
    }
}

extension FoldersListViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return output.title(at: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let dvc = MailsListConfigurator.configureModule(folder: output[indexPath])
        navigationController?.pushViewController(dvc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return output.isRowEditable(at: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FolderListCell else { return }
        output.handleDeletion(folderId: cell.folderId)
    }
}

extension FoldersListViewController: FoldersListViewInput {
    
    func updateUI() {
        tableView.reloadData()
    }
}
