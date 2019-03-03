//
//  FoldersListViewOutput.swift
//  MailDemoApp
//
//  Created by Azat Almeev on 12/02/2019.
//  Copyright © 2019 Azat Almeev. All rights reserved.
//

import UIKit

protocol FoldersListViewOutput {
    
    var groupsCount: Int { get }
    
    func title(at index: Int) -> String?
    
    func isRowEditable(at indexPath: IndexPath) -> Bool
    
    func foldersCount(inGroup: Int) -> Int
    
    subscript (indexPath: IndexPath) -> MDFolder { get }

    func viewIsReady()
    
    func handleAddFolder(name: String)
    
    func handleDeletion(folderId: String) 
}
