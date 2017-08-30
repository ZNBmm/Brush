//
//  ViewController.swift
//  AFBrushDemo
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 CoderZNBmm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(AFBrushBoard(frame: self.view.frame))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

