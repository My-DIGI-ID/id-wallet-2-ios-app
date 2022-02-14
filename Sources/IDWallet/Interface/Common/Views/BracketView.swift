//
// Copyright 2022 Bundesrepublik Deutschland
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//


import Foundation
import UIKit

class BracketView: UIView {
    var cornerRadius: CGFloat = 20
    var lineLength: CGFloat = 20
    var lineWidth: CGFloat = 8
    var lineColor: CGColor = UIColor.primaryBlue.cgColor
    
    lazy var shapeLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.strokeColor = lineColor
        layer.lineWidth = lineWidth
        return layer
    }()
    
    lazy var replica: CAReplicatorLayer = {
        let layer = CAReplicatorLayer()
        layer.frame.size = frame.size
        layer.addSublayer(shapeLayer)
        return layer
    }()
    
    init(lineLength: CGFloat = 20, lineWidth: CGFloat = 8, lineColor: UIColor = .primaryBlue, cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
        self.lineWidth = lineWidth
        self.lineLength = lineLength
        self.lineColor = lineColor.cgColor
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let path = UIBezierPath()
        
        let startLinePoint = CGPoint(x: bounds.minX, y: bounds.minY + cornerRadius + lineLength)
        let startRoundedCornerPoint = CGPoint(x: bounds.minX, y: bounds.minY + cornerRadius)
        let endPoint = CGPoint(x: bounds.minX + cornerRadius + lineLength, y: bounds.minY)
        let arcCenter = CGPoint(x: bounds.minX + cornerRadius, y: bounds.minY + cornerRadius)
        
        path.move(to: startLinePoint)
        path.addLine(to: startRoundedCornerPoint)
        path.addArc(withCenter: arcCenter, radius: cornerRadius, startAngle: .pi, endAngle: .pi + (.pi * 0.5), clockwise: true)
        path.addLine(to: endPoint)
        
        shapeLayer.frame = CGRect(origin: .zero, size: CGSize(width: endPoint.x, height: startLinePoint.y))
        shapeLayer.path = path.cgPath
        
        replica.instanceCount = 4
        replica.instanceTransform = CATransform3DMakeRotation(.pi * 0.5, 0, 0, 1)
        
        self.layer.addSublayer(replica)
    }
}
