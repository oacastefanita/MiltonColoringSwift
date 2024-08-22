//
//  PassThroughImageView.swift
//  Milton-Coloring
//
//  Created by Stefanita Oaca on 21.08.2024.
//

import UIKit

class PassThroughImageView: UIImageView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
}
