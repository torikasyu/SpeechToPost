//
//  InterfaceController.swift
//  SpeechToPost WatchKit Extension
//
//  Created by TANAKAHiroki on 2017/01/30.
//  Copyright © 2017年 torikasyu. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var lblTest: WKInterfaceLabel!

    @IBAction func btnInput() {
        //入力画面を開く
        presentTextInputController(
            withSuggestions: ["あつい", "さむい"],     //第一引数（suggestions）
            allowedInputMode: .plain,    //第二引数（allowedInputMode）
            completion: { (str) -> Void in    //第三引数（completion）
                if str != nil {
                    self.lblTest.setText("\(str)")
                }
        }
        )
    }
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        self.lblTest.setText("ほげほげ")
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
