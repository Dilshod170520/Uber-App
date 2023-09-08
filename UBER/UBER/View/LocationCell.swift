//
//  LocationCell.swift
//  UBER
//
//  Created by MacBook Pro on 08/09/23.
//

import UIKit

class LocationCell: UITableViewCell {
 //MARK: - Poperties
    
    static let reuseIdentifier = "LocationCell"
    
    
 //MARK: - Lifecycle
     
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
