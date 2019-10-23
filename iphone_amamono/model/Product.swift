//
//  Product.swift
//  iphone_amamono
//
//  Created by P1506 on 2019/10/23.
//  Copyright © 2019 archive-asia. All rights reserved.
//

import RealmSwift

class Product: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var createdAt: Double = 0
}
