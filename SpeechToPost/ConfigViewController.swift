//
//  ConfigViewController.swift
//  SpeechToPost
//
//  Created by TANAKAHiroki on 2017/01/30.
//  Copyright © 2017年 torikasyu. All rights reserved.
//

import UIKit
import Social
import Accounts

class ConfigViewController: UIViewController {

    var accountStore = ACAccountStore()
    
    @IBOutlet weak var lblTwitter1: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let ud = UserDefaults()
        
        if let t:String = ud.string(forKey: "TwitterAcName1")
        {
            lblTwitter1.text = "@" + t
        }
        else
        {
            lblTwitter1.text = "No Twitter Account"
        }
        
        if let t:String = ud.string(forKey: "TwitterAcId1")
        {
            //labelAccountID.text = t
            print(t)
        }
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
    @IBAction func btnBackAction(_ sender: Any) {
        self.dismiss(animated:true, completion: nil)
    }
    @IBAction func btnConfigTwetter1(_ sender: Any) {
        self.configureTwitter()
    }
    
    // MARK: Twitterアカウントセットアップ
    func configureTwitter()
    {
        var isError = false
        var errMsg = ""
        
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter))
        {
            let accountType = accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
            
            //accountStore.requestAccessToAccounts(with: accountType, options: nil) { (granted:Bool, error:NSError?) -> Void in
            accountStore.requestAccessToAccounts(with: accountType, options: nil) { (success:Bool, error:Error?) -> Void in
                if error != nil {
                    // エラー処理
                    print("error! \(error)")
                    //return
                    isError = true
                    //errMsg = "本体の「設定」でTwitterアカウントを設定してください"
                    errMsg = "Configure Twitter with iPhone Config."
                }
                else if !success {
                    print("error! Twitterアカウントの利用が許可されていません")
                    //return
                    isError = true
                    //errMsg = "本体の「設定」でTwitterアカウントの利用を許可してください"
                    errMsg = "Allow Using Twitter Acctoun with iPhone Config."
                }
                else
                {
                    // 設定されているTwitterアカウントを取得
                    let accounts = self.accountStore.accounts(with: accountType) as! [ACAccount]
                    
                    if accounts.count == 0 {
                        print("error! 設定画面からアカウントを設定してください")
                        return
                    }
                    
                    // 保存されたusernameが存在すればそれを使用してアカウントを選択
                    //if(self.twName != nil)
                    //{
                    //    for account in accounts{
                    //        if account.username == self.twName
                    //        {
                    //            self.twAccount = account
                    //        }
                    //    }
                    //}
                    
                    if(accounts.count > 1)
                    {
                        self.showAccountSelectSheet(accounts)
                    }
                    else
                    {
                        let ud = UserDefaults()
                        ud.set(accounts[0].username, forKey: "TwitterAcName1")
                        ud.set(accounts[0].identifier, forKey: "TwitterAcId1")
                        
                        self.lblTwitter1.text = "@" + accounts[0].username
                    }
                    
                }
            }
        }
        else
        {
            isError = true
            errMsg = "Configure Twitter with iPhone's Config."
        }
        
        if(isError)
        {
            let alert = UIAlertController(title:"Twitter",message: errMsg,preferredStyle:UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert,animated:true,completion:nil)
            
            isError = false
        }
    }
    
    // MARK: Twitterアカウントが複数設定されている時に選択させる
    fileprivate func showAccountSelectSheet(_ accounts: [ACAccount]) {
        
        let alert = UIAlertController(title: "Twitter",
                                      //message: "アカウントを選択してください",
            message: "Select Account",
            preferredStyle: .actionSheet)
        
        // アカウント選択のActionSheetを表示するボタン
        for account in accounts {
            alert.addAction(UIAlertAction(title: account.username,
                                          style: .default,
                                          handler: { (action) -> Void in
                                            //
                                            print("your select account is \(account)")
                                            //self.twAccount = account
                                            
                                            let ud = UserDefaults()
                                            ud.set(account.username, forKey:"TwitterAcName1")
                                            ud.set(account.identifier, forKey:"TwitterAcId1")
                                            
                                            self.lblTwitter1.text = account.username
                                            //self.labelAccountID.text = account.identifier as String?
            }))
        }
        
        // キャンセルボタン
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { (action) -> Void in
                                        //
                                        //self.switchRelationTwitter.setOn(false, animated: true)
                                        //let ud = UserDefaults()
                                        //ud.set(false, forKey: "RelationTwitter")
                                        //
        }))
        
        // 表示する
        self.present(alert, animated: true, completion: nil)
    }

}
