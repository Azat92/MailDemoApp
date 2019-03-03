//
//  MailConfigurator.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

final class MailConfigurator {

    static func configureModule(mail: MDMail, isReadonly: Bool) -> UIViewController {
        let view = MailViewController()
        let presenter = MailPresenter(foldersService: Services.shared.foldersService,
                                      mailsService: Services.shared.mailsService,
                                      mail: mail,
                                      isReadonly: isReadonly)
        view.output = presenter
        presenter.view = view
        return view
    }
}
