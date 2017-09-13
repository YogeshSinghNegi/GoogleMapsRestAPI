//
//  CustomCell.swift
//  GoogleMapsRestAPI
//
//  Created by appinventiv on 12/09/17.
//  Copyright © 2017 yogesh singh negi. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var startLocation: UILabel!
    
    @IBOutlet weak var endLocation: UILabel!
    
    @IBOutlet weak var latStart: UILabel!
    
    @IBOutlet weak var lngStart: UILabel!
    
    @IBOutlet weak var lngEnd: UILabel!
    
    @IBOutlet weak var latEnd: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
