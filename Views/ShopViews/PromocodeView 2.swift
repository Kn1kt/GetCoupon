//
//  PromocodeView.swift
//  GetCoupon
//
//  Created by Nikita Konashenko on 07.12.2019.
//  Copyright © 2019 Nikita Konashenko. All rights reserved.
//

import UIKit

class PromocodeView: UIView {

    let promocodeLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(promocodeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//    override func layoutSubviews() {
    override func updateConstraints() {
        promocodeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        promocodeLabel.font = UIFont.preferredFont(forTextStyle: .body)
        promocodeLabel.adjustsFontForContentSizeCategory = true
        promocodeLabel.textAlignment = .center
        promocodeLabel.textColor = UIColor(named: "BlueTintColor")
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "BlueTintColor")?.cgColor
        layer.cornerRadius = 6
        clipsToBounds = true
        
        NSLayoutConstraint.activate([
            promocodeLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: 10),
            promocodeLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -10),
            promocodeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5 ),
            promocodeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
        
//        promocodeLabel.frame = CGRect(x: 15, y: 5, width: bounds.size.width - 30 , height: bounds.size.height - 10)
//
//        let _ = layer.sublayers?.filter({$0.name == "DashBorder"}).map({$0.removeFromSuperlayer()})
//        addDashBorder()
        
        super.updateConstraints()
    }
}

//extension UIView {
//    func addDashBorder() {
//        let color = UIColor(named: "BlueTintColor")?.cgColor
//
//        let shapeLayer:CAShapeLayer = CAShapeLayer()
//
//        let frameSize = self.frame.size
//        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
//
//        shapeLayer.bounds = shapeRect
//        shapeLayer.name = "DashBorder"
//        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        shapeLayer.strokeColor = color
//        shapeLayer.lineWidth = 1.5
//        shapeLayer.lineJoin = .round
//        shapeLayer.lineDashPattern = [2,4]
//        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 10).cgPath
//
//        self.layer.masksToBounds = false
//
//        self.layer.addSublayer(shapeLayer)
//    }
//}
