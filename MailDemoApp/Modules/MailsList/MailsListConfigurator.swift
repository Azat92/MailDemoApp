//
//  MailsListConfigurator.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 21/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

final class MailsListConfigurator {

    static func configureModule(folder: MDFolder) -> UIViewController {
        let view = MailsListViewController(style: .plain)
        let presenter = MailsListPresenter(dbService: Services.shared.dbService, mailsService: Services.shared.mailsService, folder: folder)
        view.output = presenter
        presenter.view = view
        return view
    }
}
