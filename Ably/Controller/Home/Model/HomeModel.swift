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
//    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted var id: Int = -1
//    @Persisted var id: String = ""
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


//struct HealthVideo: Codable {
//    var exerciseContentList: [ExerciseContentList]?
//    var biomakerCategoryInfoList: [BiomakerCategoryInfoList]?
//
//    enum CodingKeys: String, CodingKey {
//        case exerciseContentList = "exercise_content_list"
//        case biomakerCategoryInfoList = "biomaker_category_info_list"
//    }
//}
//
//struct ExerciseContentList: Codable {
//    let orderNo: Int
//    let diseaseType: Int?
//    let diseaseName: String?
//    let contents: [ContentsDetailList]
//
//    enum CodingKeys: String, CodingKey {
//        case orderNo = "order_no"
//        case diseaseType = "disease_type"
//        case diseaseName = "disease_name"
//        case contents = "contents"
//    }
//}


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

