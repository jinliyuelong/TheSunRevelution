//
//  ViewController.swift
//  TheSunRevelution
//
//  Created by Liyanjun on 2017/9/12.
//  Copyright © 2017年 liyanjun. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func gotoAr(_ sender: Any) {
        
        self.present(SunRevolutionViewController(), animated: true, completion: nil)
    }
}

