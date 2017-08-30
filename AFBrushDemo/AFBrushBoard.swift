//
//  AFBrushBoard.swift
//  AFBrushDemo
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 CoderZNBmm. All rights reserved.
//

import UIKit

let size = UIScreen.main.bounds.size
class AFBrushBoard: UIImageView {

    // 存放点集的数组
    var points:[CGPoint] = [CGPoint]()
    
    // 当前半径
    var currentWidth:CGFloat = 10
    
    // 初始图片
    var defaultImage:UIImage?
    
    // 上次图片
    var lastImage:UIImage?
    
    let minWidth:CGFloat = 5
    let maxWidth:CGFloat = 13
    
    // 设置调试
    let DEBUG = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = true
        
        // 清除按钮设置
        let btn = UIButton(frame: CGRect(x: 0, y: self.frame.size.height-50, width: self.frame.size.width, height: 50))
        btn.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Zapfino", size: 18)
        btn.titleEdgeInsets = UIEdgeInsetsMake(20, 0, 0, 0)
        btn.setTitle("Clear", for: .normal)
        btn.addTarget(self, action:#selector(AFBrushBoard.btnClick), for: .touchUpInside)
        addSubview(btn)
        
        // 设置默认图片
        image = UIImage(named: "apple")
        defaultImage = image
        lastImage = image
        if DEBUG {
            points = [CGPoint.init(x: 100, y: 100),CGPoint.init(x: 200, y: 100),CGPoint.init(x: 200, y: 200)]
            currentWidth = 10
            
            changeImage()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func btnClick() {
        image = defaultImage
        lastImage = defaultImage
        currentWidth = 13
    }
    
    
    func changeImage()  {
        UIGraphicsBeginImageContext(frame.size)
        lastImage!.draw(in: self.bounds)
        
        // 贝塞尔曲线的起始点和末尾点
        let tempPoint1 = CGPoint.init(x: (points[0].x + points[1].x)/2, y: (points[0].y+points[1].y)/2)
        let tempPoint2 = CGPoint.init(x: (points[1].x+points[2].x)/2, y: (points[1].y+points[2].y)/2)
        
        if DEBUG {
            var pointPath = UIBezierPath(arcCenter: points[2], radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2, clockwise: true)
            UIColor.red.set()
            pointPath.stroke()
            
            pointPath = UIBezierPath(arcCenter: points[1], radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2, clockwise: true)
            pointPath.stroke()
            
            pointPath = UIBezierPath(arcCenter: points[0], radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            pointPath.stroke()
            
            pointPath = UIBezierPath(arcCenter: tempPoint1, radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            pointPath.stroke()
            
            pointPath = UIBezierPath(arcCenter: tempPoint2, radius: 3, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            pointPath.stroke()
            
        }
        
        // 贝塞尔曲线的估算长度
        let x1 = abs(tempPoint1.x - tempPoint2.x)
        let x2 = abs(tempPoint1.y-tempPoint2.y)
        let len = Int(sqrt(pow(x1, 2) + pow(x2,2))*10)
        
        // 如果仅仅点击一下
        if len == 0 {
            let zeroPath = UIBezierPath(arcCenter: points[1], radius: maxWidth/2-2, startAngle: 0, endAngle: CGFloat(M_PI)*2.0, clockwise: true)
            UIColor.black.setFill()
            zeroPath.fill()
            
            // 绘图
            image = UIGraphicsGetImageFromCurrentImageContext()
            lastImage = image
            UIGraphicsEndImageContext()
            return
        }
        
        // 如果距离过短，直接画线
        if len < 1 {
            let zeroPath = UIBezierPath()
            zeroPath.move(to: tempPoint1)
            zeroPath.addLine(to: tempPoint2)
            
            currentWidth += 0.05
            if currentWidth > maxWidth {currentWidth = maxWidth}
            if currentWidth < minWidth {currentWidth = minWidth}
            
            // 画线
            zeroPath.lineWidth = currentWidth
            zeroPath.lineCapStyle = .round
            zeroPath.lineJoinStyle = .round
            UIColor(white: 0, alpha: (currentWidth-minWidth)/maxWidth*0.6+0.2).setStroke()
            zeroPath.stroke()
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return
        }
        
        // 目标半径
        let aimWidth:CGFloat = CGFloat(300)/CGFloat(len)*(maxWidth-minWidth)
        
        // 获取贝塞尔点集
         let curvePoints = AFBezierPath.curveFactorization(fromPoint: tempPoint1, toPoint: tempPoint2, controlPoints: [points[1]], count: len)
        // 画每条线段
        var lastPoint:CGPoint = tempPoint1

        
        var i = 0
        
        while i < len+1
        {
            let bPath = UIBezierPath()
            bPath.move(to: lastPoint)
            
            // 省略多余的点
            let delta = sqrt(pow(curvePoints[i].x-lastPoint.x, 2) + pow(curvePoints[i].y-lastPoint.y, 2))
            if delta < 1 {
                i += 1
                continue
            }
            
            lastPoint = CGPoint.init(x: curvePoints[i].x, y: curvePoints[i].y)
            
            bPath.addLine(to: CGPoint.init(x: curvePoints[i].x, y: curvePoints[i].y))
            
            // 计算当前点
            if currentWidth > aimWidth {
                currentWidth -= 0.05
            }else{
                currentWidth += 0.05
            }
            if currentWidth > maxWidth {currentWidth = maxWidth}
            if currentWidth < minWidth {currentWidth=minWidth}
            
            // 画线
            bPath.lineWidth = currentWidth
            bPath.lineCapStyle = .round
            bPath.lineJoinStyle = .round
            UIColor(white: 0, alpha: (currentWidth-minWidth)/maxWidth*0.3+0.1).setStroke()
            bPath.stroke()
            i += 1
        }
        
        // 保存图片
        lastImage = UIGraphicsGetImageFromCurrentImageContext()
        
        let pointCount = Int(sqrt(pow(tempPoint2.x-points[2].x,2)+pow(tempPoint2.y-points[2].y,2)))*2
        let delX = (tempPoint2.x-points[2].x)/CGFloat(pointCount)
        let delY = (tempPoint2.y-points[2].y)/CGFloat(pointCount)
        
        var addRadius = currentWidth
        
        var j = 0
        
        while j < pointCount {
            
            let bPath = UIBezierPath()
            bPath.move(to: lastPoint)
            let newPoint = CGPoint.init(x: lastPoint.x - delX, y: lastPoint.y - delY)
            lastPoint = newPoint
            bPath.addLine(to: newPoint)
            
            if addRadius > aimWidth {
                addRadius -= 0.02
            }else {
                addRadius += 0.02
            }
            
            if addRadius > maxWidth {
                addRadius = maxWidth
            }
            if addRadius < 0 {
                addRadius = 0
            }
            bPath.lineWidth = addRadius
            bPath.lineCapStyle = .round
            bPath.lineJoinStyle = .round
            UIColor(white: 0, alpha: (currentWidth-minWidth)/maxWidth*0.05+0.05).setStroke()
            bPath.stroke()
            
            j+=1
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()

    }

}

// 触摸事件
extension AFBrushBoard {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let p = touch!.location(in: self)
        points = [p,p,p]
        
        currentWidth = 13
        changeImage()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let p = touch!.location(in: self)
        
        points = [points[1],points[2],p]
        changeImage()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastImage = image
    }
}

/**
 *分解贝塞尔曲线
 */

class AFBezierPath {
    /**
     fromPoint:起始点
     toPoint:终止点
     controlPoints:控制点数组
     count:分解数量
     返回:分解的点集
     */
    
    class func curveFactorization(fromPoint:CGPoint, toPoint: CGPoint, controlPoints:[CGPoint], count:Int) -> [CGPoint]{
        
        //如果分解数量为0，生成默认分解数量
        var count = count
        if count == 0 {
            let x1 = abs(fromPoint.x-toPoint.x)
            let x2 = abs(fromPoint.y-toPoint.y)
            count = Int(sqrt(pow(x1, 2) + pow(x2,2)))
        }
        
        // 贝赛尔曲线的计算
        var s:CGFloat = 0.0
        var t:[CGFloat] = [CGFloat]()
        let pc:CGFloat = 1/CGFloat(count)
        
        let power = controlPoints.count + 1
        
        for _ in 0...count+1 {t.append(s);s=s+pc}
        
        var newPoint:[CGPoint] = [CGPoint]()
        
        for i in 0...count+1 {
            
            var resultX = fromPoint.x * bezMaker(n: power, k:0, t:t[i])
                + toPoint.x * bezMaker(n: power, k:power, t:t[i])
            
            for j in 1...power-1 {
                resultX += controlPoints[j-1].x * bezMaker(n: power, k:j, t:t[i])
            }
            
            var resultY = fromPoint.y * bezMaker(n: power, k:0, t:t[i])
                + toPoint.y * bezMaker(n: power, k:power, t:t[i])
            
            for j in 1...power-1 {
                resultY += controlPoints[j-1].y * bezMaker(n: power, k:j, t:t[i])
            }
            
            newPoint.append(CGPoint.init(x: resultX, y: resultY))
            
        }
        
        return newPoint
    }
    
    private class func comp(n:Int, k:Int) -> CGFloat{
        var s1:Int = 1
        var s2:Int = 1
        
        if k == 0 {return 1}
        
        
        var i = n
        
        while i>=n-k+1 {
            s1=s1*i
            i -= 1
        }
        var j = k
        
        while j >= 2 {
           s2=s2*j
            j -= 1
        }
       
        
        return CGFloat(s1/s2)
    }
    
    private class func realPow(n:CGFloat, k:Int) -> CGFloat{
        if k==0 {return 1.0}
        return pow(n, CGFloat(k))
    }
    
    private class func bezMaker(n:Int, k:Int, t:CGFloat) -> CGFloat{
        return comp(n: n, k: k) * realPow(n: 1-t, k: n-k) * realPow(n: t, k: k)
    }
}
