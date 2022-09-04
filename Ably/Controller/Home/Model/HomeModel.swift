//
//  HomeModel.swift
//  Ably
//
//  Created by 김희진 on 2022/09/02.
//

import Foundation
import Realm
import RealmSwift

struct HomeModel: Codable {
    var banners: [Banners]
    var goods: [Goods]
}

struct Banners: Codable {
    var id: Int
    var image: String
}

struct Goods: Codable {
    var id: Int
    var name: String
    var image: String
    var actualPrice: Int
    var price: Int
    var isNew: Bool
    var sellCount: Int

    enum CodingKeys: String, CodingKey {
        case actualPrice = "actual_price"
        case price = "price"
        case isNew = "is_new"
        case sellCount = "sell_count"
        case id, name, image
    }
}

struct HomeModelOnlyGoods: Codable {
    var goods: [Goods]
}


class GoodsViewModel: Object {
    @Persisted var id: Int = -1
    @Persisted var name: String = ""
    @Persisted var image: String = ""
    @Persisted var actualPrice: Int = 0
    @Persisted var price: Int = 0
    @Persisted var isNew: Bool = false
    @Persisted var sellCount: Int = 0
    @Persisted var isLike: Bool = false

    convenience init(id: Int, name: String, image: String, actualPrice: Int, price: Int, isNew:Bool, sellCount: Int, isLike: Bool) {
        self.init()
        self.id = id
        self.name = name
        self.image = image
        self.actualPrice = actualPrice
        self.price = price
        self.isNew = isNew
        self.sellCount = sellCount
        self.isLike = isLike
    }
}



//struct ArticleListViewModel {
//    let articlesVM: [ArticleViewModel]
//}
//
//extension ArticleListViewModel {
//
//    init(_ articles: [Article]){
//        self.articlesVM = articles.compactMap(ArticleViewModel.init)
//    }
//
//}
//
//extension ArticleListViewModel {
//    func articleAt(_ index: Int) -> ArticleViewModel {
//        return self.articlesVM[index]
//    }
//}
//
//struct ArticleViewModel {
//    let article: Article
//
//    init(_ article: Article){
//        self.article = article
//    }
//}
//
//extension ArticleViewModel {
//
//    var title: Observable<String>{
//        return Observable<String>.just(article.title)
//    }
//    var description: Observable<String>{
//        return Observable<String>.just(article.description ?? "")
//    }
//}

