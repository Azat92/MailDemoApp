//
//  FoldersConfigurator.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 12/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

final class FoldersListConfigurator {

    static func configureModule() -> UIViewController {
        let view = FoldersListViewController(style: .plain)
        let presenter = FoldersListPresenter(dbService: Services.shared.dbService, foldersService: Services.shared.foldersService)
        view.output = presenter
        presenter.view = view
        return view
    }
}
