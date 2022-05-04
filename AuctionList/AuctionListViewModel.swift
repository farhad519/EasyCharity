//
//  AuctionListViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 27/11/21.
//

import CoreData
import UIKit
import ReactiveSwift
import Firebase
import FirebaseStorage

protocol AuctionListViewControllerDelegate {
    func reloadViewController()
}

enum AuctionListViewType {
    case bidListView
    case createdView
    case auctionListView
}

struct AuctionListCellStruct {
    var title: String
    var imageUrlString: String
    var upperString: String
    var lowerString: String
    var sellDescription: String
    init() {
        title = ""
        imageUrlString = ""
        upperString = "0.0$"
        lowerString = "Fixed"
        sellDescription = ""
    }
}

class AuctionListViewModel {
    var auctionListViewType = AuctionListViewType.auctionListView
    var auctionSellItemList: [FireAuctionItem] = []
    var delegate: AuctionListViewControllerDelegate?
    let dataCollector: DataCollector
    var pageNum: Int = 1
    
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    var shouldShowHeaderView: Bool {
        switch auctionListViewType {
        case .auctionListView:
            return true
        default:
            return false
        }
    }
    
    init(auctionListViewType: AuctionListViewType) {
        self.auctionListViewType = auctionListViewType
        self.dataCollector = DataCollector()
        setupMyAuctionListDataSource()
    }
    
    private func setupMyAuctionListDataSource() {
        switch auctionListViewType {
        case .auctionListView:
            getAllSellList()
        case .bidListView:
            getMyBidList()
        case .createdView:
            getMySellList()
        }
    }
    
    private func getAllSellList() {
        guard let ownerId = Auth.auth().currentUser?.uid else {
            print("[AuctionListViewModel][getAllSellList] no auth id.")
            return
        }
        auctionSellItemList = CoreDataManager.shared.getAuctionItemDatas(
            myId: ownerId,
            offset: 0,
            blockCount: 20,
            minV: 0,
            maxV: 200000000,
            searchKey: []
        )
        print("[AuctionListViewModel][getAllSellList] item count from core data \(auctionSellItemList.count)")
    }
    
    private func getMyBidList() {
        dataCollector.getBidItemList().startWithResult { [weak self] result in
            switch result {
            case .success(let myBidList):
                self?.auctionSellItemList = CoreDataManager.shared.getBidAuctionItemDatas(
                    auctionIds: myBidList.map { $0.id },
                    offset: 0,
                    blockCount: myBidList.count,
                    minV: 0,
                    maxV: 200000000,
                    searchKey: []
                )
                DispatchQueue.main.async {
                    self?.delegate?.reloadViewController()
                }
            case .failure(let error):
                print("[AuctionListViewModel][getMyBidList] error at fetching bid data data \(error)")
            }
        }
    }
    
    private func getMySellList() {
        dataCollector.getMySellList { [weak self] result in
            switch result {
            case .success(let auctionList):
                self?.auctionSellItemList = auctionList
                self?.delegate?.reloadViewController()
            case .failure(let error):
                print("[AuctionListViewModel][getMySellList] error at retrieving data with \(error)")
            }
        }
    }
    
    func fetchImageSignal(urlString: String) -> SignalProducer<UIImage, NSError> {
        //print("maddmadd = \(urlString)")
        return SignalProducer { [weak self] observer, disposable in
            self?.dataCollector.getImage(urlString: urlString) { result in
                switch result {
                case .success(let image):
                    observer.send(value: image)
                    observer.sendCompleted()
                case .failure(let error):
                    print("[AuctionListViewModel][fetchImageSignal] error at retrieving image with \(error)")
                    observer.sendCompleted()
                }
            }
        }
    }
    
//    private func getImageFromServer(auctionList: [FireAuctionItem], completion: @escaping ([AuctionListCellStruct]) -> Void) {
//        var cellItemList: [AuctionListCellStruct] = []
//        let workGroup = DispatchGroup()
//        auctionList.forEach {
//            var cellItem = AuctionListCellStruct()
//            cellItem.upperString = "\($0.price)$"
//            cellItem.lowerString = $0.negotiable == false ? "Fixed" : "Negotiable"
//            cellItem.sellDescription = $0.description
//            workGroup.enter()
//            dataCollector.getImage(urlString: $0.imagesUrlStringList.first ?? "") { result in
//                switch result {
//                case .success(let recievedImage):
//                    cellItem.image = recievedImage
//                    print("[AuctionListViewModel][getImageFromServer] image recieved.")
//                case .failure(let error):
//                    print("[AuctionListViewModel][getImageFromServer] error at retrieving image with \(error)")
//                }
//                cellItemList.append(cellItem)
//                workGroup.leave()
//            }
//        }
//        workGroup.notify(queue: DispatchQueue.main, execute: {
//            completion(cellItemList)
//        })
//    }
    
    func getCellItem(at index: Int) -> AuctionListCellStruct {
        guard index < auctionSellItemList.count else { return AuctionListCellStruct() }
        var cellItem = AuctionListCellStruct()
        cellItem.title = auctionSellItemList[index].title
        cellItem.upperString = "\(auctionSellItemList[index].price)$"
        cellItem.lowerString = auctionSellItemList[index].negotiable == false ? "Fixed" : "Negotiable"
        cellItem.sellDescription = auctionSellItemList[index].description
        cellItem.imageUrlString = auctionSellItemList[index].imagesUrlStringList.first ?? ""
        return cellItem
    }
    
    func getFireAuctionItem(at index: Int) -> FireAuctionItem? {
        guard index < auctionSellItemList.count else { return nil }
        return auctionSellItemList[index]
    }

//    func loadDataFromStore() {
//        guard let context = context else { return }
//
//        do {
//            try auctionSellItemList = context.fetch(AuctionSellItem.fetchRequest())
//        } catch {
//            print("error at fetch")
//        }
//    }
//
//    private func imagesFromCoreData(object: Data?) -> [UIImage]? {
//        guard let object = object else { return nil }
//
//        var retrievedImages = [UIImage]()
//
//        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
//            for data in dataArray {
//                if let data = data as? Data, let image = UIImage(data: data) {
//                    retrievedImages.append(image)
//                }
//            }
//        }
//
//        return retrievedImages
//    }
    
    func searchSellItems(minimumValue: String, maximumValue: String, searchKeyStr: String, serachKeyTextColor: UIColor) {
        guard let ownerId = Auth.auth().currentUser?.uid else {
            print("[AuctionListViewModel][searchSellItems] no auth id.")
            return
        }
        
        let trimmedString = String(
            searchKeyStr.filter { !" \n\t\r".contains($0) }
        )
        var keyArrs: [String] = []
        if serachKeyTextColor != .lightGray && trimmedString.isEmpty == false {
            keyArrs = trimmedString.components(separatedBy: ",")
        }
        
        var minV = 0
        var maxV = 2000000000
        if let value = Int(minimumValue) {
            minV = max(0, value)
        }
        if let value = Int(maximumValue) {
            maxV = min(maxV, value)
        }

        auctionSellItemList = CoreDataManager.shared.getAuctionItemDatas(
            myId: ownerId,
            offset: (pageNum - 1) * 2,
            blockCount: 20,
            minV: minV,
            maxV: maxV,
            searchKey: keyArrs
        )
        print("[AuctionListViewModel][getAllSellList] item count from core data \(auctionSellItemList.count)")
    }
}
