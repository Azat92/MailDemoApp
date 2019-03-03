//
//  Services.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 06/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

class Services {
    
    static let shared = Services()
    
    private lazy var yapDbService = YapDbService()
    
    var dbService: YapDbServices {
        return yapDbService
    }

    lazy var foldersService: FoldersService = {
        return DefaultFoldersService(db: yapDbService.db)
    }()
    
    lazy var mailsService: MailsService = {
        return DefaultMailsService(db: yapDbService.db)
    }()
    
    private init() {
        // Uncomment the following line to generate some data
//        DataGenerator().generateTestData(connection: yapDbService.db.newConnection(), onStore: DefaultMailsService.store)
    }
}
