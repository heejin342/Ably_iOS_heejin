//
//  AblyKey.swift
//  Ably
//
//  Created by 김희진 on 2022/09/05.
//

import Foundation


public struct AblyRequest {
    public struct Home {
        private static let `default` = "home"
        public static let home = "\(`default`)"
        public static let goods = "\(`default`)/goods?lastId="
    }
}


public class AblyKey {
    private init() { }    
    public static let urlString = "http://d2bab9i9pr8lds.cloudfront.net/api/"
}
