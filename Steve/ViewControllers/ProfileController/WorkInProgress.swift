//
//  WorkInProgress.swift
//  Steve
//
//  Created by Sudhir Kumar on 22/05/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class WorkInProgress: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func logoutTapped(_ sender: Any) {
        Utilities.logOutUser("Logout")
    }
    

}
