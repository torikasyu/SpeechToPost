//
//  Util.swift
//  SpeechToPost
//
//  Created by TANAKAHiroki on 2017/01/30.
//  Copyright © 2017年 torikasyu. All rights reserved.
//

import Foundation
import Accounts
import Social

class Util
{
    static func doTweet(_ status:String)->Bool
    {
        var success = true
        // アカウントを取得する
        let defaults = UserDefaults()
        var twAccount:ACAccount?;
        
        let acs = ACAccountStore()
        if let t = defaults.string(forKey: "TwitterAcId1")
        {
            twAccount = acs.account(withIdentifier: t)
        }
        
        // 投稿パラメータ設定
        let URL = Foundation.URL(string: "https://api.twitter.com/1.1/statuses/update.json")
        let params:Dictionary = ["status" : status]
        
        
        // リクエストを生成
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .POST,
                                url: URL,
                                parameters: params as [AnyHashable: Any])
        
        // 取得したアカウントをセット
        if let t = twAccount
        {
            request?.account = t
            
            // APIコールを実行
            request?.perform { (responseData, urlResponse, error) -> Void in
                
                if error != nil {
                    print("error is \(error)")
                    success = false
                }
                else {
                    // 結果の表示
                    do {
                        let result = try JSONSerialization.jsonObject(with: responseData!, options: .mutableContainers) as! NSDictionary
                        print("result is \(result)")
                        print(params)
                        
                        // エラーが起こらなければ後続の処理...
                    } catch  {
                        // エラーが起こったらここに来るのでエラー処理などをする
                        success = false
                    }
                }
            }
        }
        
        return success
    }
}
