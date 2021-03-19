//
//  EditProfileCell.swift
//  Finish
//
//  Created by 志村　啓太 on 2021/03/19.
//

import UIKit

class EditProfileCell: UITableViewCell {
    
    //MARK: - Properties
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor(named: "backgroundColor")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers

}
