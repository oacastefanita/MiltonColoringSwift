//
//  Translation.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 18.01.2022.
//

import Foundation

class Translation{
    var code: String
    var isRTL: Bool
    var languageAddon:String
    var id:String
    var addon:String
    var name:String
    
    init(code: String, isRTL: Bool, languageAddon:String, id:String, addon:String, name:String){
        self.code = code
        self.isRTL = isRTL
        self.languageAddon = languageAddon
        self.id = id
        self.addon = addon
        self.name = name
    }
    
    convenience init (dictionary: Dictionary<String, Any>){
        if let code = dictionary["code"] as? String,  let languageAddon = dictionary["languageAddon"] as? String,  let id = dictionary["id"] as? String,  let addon = dictionary["addon"] as? String,  let name = dictionary["name"] as? String{
            var rtl = false
            if let isRTL = dictionary["RTL"] as? Bool{
                rtl = isRTL
            }
            self.init(code: code, isRTL: rtl, languageAddon: languageAddon, id: id, addon: addon, name: name)
        }else{
            self.init(code: "", isRTL: false, languageAddon: "", id: "", addon: "", name: "")
        }
    }
}
