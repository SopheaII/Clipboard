//
//  Store.swift
//  Test_MenuBar_Mac
//
//  Created by Sao Sophea on 4/10/23.
//

import Foundation

class UserDefaultUtils {
    static let shared = UserDefaultUtils()
    
    let defaults = UserDefaults.standard
    
    func storeDataList(data: [String]) {
        defaults.set(data, forKey: "dataList")
    }
    
    func getDataList() -> [String] {
        let dataList = defaults.object(forKey: "dataList") as? [String] ?? [String]()
        return dataList
    }
}
