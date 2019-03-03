//
//  MDMailBody.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

struct MDMailBody: Codable {
    
    let id: String
    let body: String

    func updated(body: String) -> MDMailBody {
        return MDMailBody(id: id, body: body)
    }
}
