//
//  CommentCell.swift
//  Parstagrama
//
//  Created by Dinaol Melak on 11/24/19.
//  Copyright © 2019 Dinaol Melak. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameComment: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
