//
//  MailListCell.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 23/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

class MailListCell: UITableViewCell {
    
    private (set) var mailId: String!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configured(with mail: MDMail, showsIcon: Bool) -> Self {
        mailId = mail.id
        textLabel?.text = mail.subject ?? Localizations.Mail.noSubject
        let detailText = mail.isIncome ? mail.sender : mail.recipient
        let dateText = DateFormatter.localizedString(from: mail.date, dateStyle: .short, timeStyle: .short)
        detailTextLabel?.text = detailText.flatMap { "\($0) \(Localizations.Common.at) \(dateText)" } ?? dateText
        accessoryType = .disclosureIndicator
        imageView?.image = showsIcon ? (mail.isIncome ? #imageLiteral(resourceName: "ic_income.png") : #imageLiteral(resourceName: "ic_outcome.png")) : nil
        return self
    }
}
