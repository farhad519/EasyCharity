//
//  SellDetailsViewModel.swift
//  Buy And Sell App
//
//  Created by Farhad Chowdhury on 5/11/21.
//

import UIKit
import CoreData
import Firebase
import FirebaseStorage

enum SellDetailsViewType {
    case forCreate
    case forModify
    case forBid
}

enum SellDetailsEditedEnum {
    case title
    case type
    case price
    case negotiable
    case description
}

struct SellDetailsEditedValue {
    var title: String
    var type: String
    var price: String
    var negotiable: String
    var description: String
}

struct ImageUrlCouple {
    var image: UIImage
    var url: URL
    var isFromCloud: Bool
}

final class SellDetailsViewModel {
    let descriptionTextViewPlaceHolder = TextViewPlaceHolder("Write description here .....")
    var editedValue: SellDetailsEditedValue
    var imageUrlCoupleList: [ImageUrlCouple] = []
    var videoList: [URL] = []
    
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    var buttonTitle: String {
        switch viewType {
        case .forCreate:
            return "Post"
        case .forBid:
            if isAlreadyBid { return "Already Bid." }
            else { return "Bid" }
        default:
            return "Modify"
        }
    }
    
    var viewType: SellDetailsViewType
    var fireAuctionItem: FireAuctionItem?
    
    var getToId: String? { fireAuctionItem?.ownerId }
    var auctionId: String? { fireAuctionItem?.id }
    var isAlreadyBid: Bool {
        guard let auctionId = auctionId else { return false }
        for item in CommonData.shared.myBidList {
            if item.id == auctionId { return true }
        }
        return getIsBidItemToUserDefault(itemId: auctionId)
    }
    
    init(viewType: SellDetailsViewType) {
        editedValue = SellDetailsEditedValue(
            title: "",
            type: "",
            price: "",
            negotiable: "",
            description: ""
        )
        self.viewType = viewType
    }
    
    init(
        viewType: SellDetailsViewType,
        imageUrlCoupleList: [ImageUrlCouple],
        fireAuctionItem: FireAuctionItem
    ) {
        self.fireAuctionItem = fireAuctionItem
        editedValue = SellDetailsEditedValue(
            title: fireAuctionItem.title,
            type: fireAuctionItem.type,
            price: String(fireAuctionItem.price),
            negotiable: fireAuctionItem.negotiable ? "yes" : "no",
            description: fireAuctionItem.description
        )
        self.viewType = viewType
        self.imageUrlCoupleList = imageUrlCoupleList
    }
    
    func isAnyFieldEmpty() -> String? {
        if imageUrlCoupleList.isEmpty {
            return "Need at least one image of the product."
        }
        if editedValue.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need description about the product."
        }
        if editedValue.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need title about the product."
        }
        if editedValue.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need type about the product."
        }
        if editedValue.price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need price for the product."
        }
        return nil
    }
    
    func isEmpty(string: String) -> Bool {
        for ch in string {
            if ch != "\n" && ch != " " {
                return false
            }
            return true
        }
        return true
    }
    
    func getEditedText(for editedEnum: SellDetailsEditedEnum) -> String {
        switch editedEnum {
        case .title:
            return isEmpty(string: editedValue.title) ? "" : editedValue.title
        case .type:
            return isEmpty(string: editedValue.type) ? "" : editedValue.type
        case .price:
            return isEmpty(string: editedValue.price) ? "" : editedValue.price
        case .negotiable:
            return isEmpty(string: editedValue.negotiable) ? "" : editedValue.negotiable
        case .description:
            return isEmpty(string: editedValue.description) ? "" : editedValue.description
        }
    }
    
//    func saveDataToStore(completion: () -> Void) {
//        guard let context = context else { return }
//        let auctionSellItem = AuctionSellItem(context: context)
//        auctionSellItem.title = editedValue.title
//        auctionSellItem.type = editedValue.type
//        auctionSellItem.price = Double(editedValue.price) ?? 0.0
//        auctionSellItem.negotiable = (editedValue.negotiable.lowercased() == "yes") ? true : false
//        auctionSellItem.sellDescription = editedValue.description
//        auctionSellItem.image = coreDataObjectFromImages()
//        auctionSellItem.video = coreDataObjectFromVideo()
//        do {
//            try context.save()
//            completion()
//        } catch {
//            print("could not save to store. \(error)")
//            completion()
//        }
//        saveDataToFireStore()
//    }
    
    private func coreDataObjectFromVideo() -> Data? {
        guard let url = videoList.first else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("error caught \(error)")
            return nil
        }
    }
    
//    private func coreDataObjectFromImages() -> Data? {
//        let dataArray = NSMutableArray()
//
//        for image in imageList {
//            if let data = image.pngData() {
//                dataArray.add(data)
//            }
//        }
//
//        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
//    }
    
    func saveDataToFireStore(completion: @escaping (String) -> Void) {
        let workGroup = DispatchGroup()
        var videoUrlString: String = ""
        var imageUrlStringList: [String] = []
        
        workGroup.enter()
        getSavedUrlForVideo { url in
            videoUrlString = url?.absoluteString ?? ""
            workGroup.leave()
        }
        
        workGroup.enter()
        getSavedUrlForImages { imagesUrlList in
            imageUrlStringList = imagesUrlList.compactMap { $0.absoluteString }
            workGroup.leave()
        }
        
        let negotiableValue = (editedValue.negotiable.lowercased() == "yes") ? true : false
        let priceValue = Double(editedValue.price) ?? 0.0
        guard let ownerId = Auth.auth().currentUser?.uid else { return }
        
        workGroup.notify(queue: DispatchQueue.main, execute: { [weak self] in
            guard let editedValue = self?.editedValue else {
                completion("Error while saving data.")
                return
            }
            let db = Firestore.firestore()
            switch self?.viewType {
            case .forCreate:
                db
                    .collection(MyKeys.AuctionSellItem.rawValue)
                    .addDocument(
                        data: [
                            MyKeys.AuctionSellItemField.title.rawValue: editedValue.title,
                            MyKeys.AuctionSellItemField.sellDescription.rawValue: editedValue.description,
                            MyKeys.AuctionSellItemField.type.rawValue: editedValue.type,
                            MyKeys.AuctionSellItemField.negotiable.rawValue: negotiableValue,
                            MyKeys.AuctionSellItemField.price.rawValue: priceValue,
                            MyKeys.AuctionSellItemField.ownerId.rawValue: ownerId,
                            MyKeys.AuctionSellItemField.video.rawValue: videoUrlString,
                            MyKeys.AuctionSellItemField.images.rawValue: imageUrlStringList,
                        ]
                    ) { error in
                        if let error = error {
                            completion("Error with \(error)")
                        } else {
                            completion("Data saved successfully.")
                        }
                    }
            default:
                db
                    .collection(MyKeys.AuctionSellItem.rawValue)
                    .document(self?.fireAuctionItem?.id ?? "")
                    .setData(
                        [
                            MyKeys.AuctionSellItemField.title.rawValue: editedValue.title,
                            MyKeys.AuctionSellItemField.sellDescription.rawValue: editedValue.description,
                            MyKeys.AuctionSellItemField.type.rawValue: editedValue.type,
                            MyKeys.AuctionSellItemField.negotiable.rawValue: negotiableValue,
                            MyKeys.AuctionSellItemField.price.rawValue: priceValue,
                            MyKeys.AuctionSellItemField.ownerId.rawValue: ownerId,
                            MyKeys.AuctionSellItemField.video.rawValue: videoUrlString,
                            MyKeys.AuctionSellItemField.images.rawValue: imageUrlStringList,
                        ]
                    ){ error in
                        if let error = error {
                            completion("Error with \(error)")
                        } else {
                            completion("Data modified successfully.")
                        }
                    }
            }
        })
        
    }
    
    func getSavedUrlForImages(completion: @escaping ([URL]) -> Void) {
        let workGroup = DispatchGroup()
        var urlList: [URL] = []
        let storage = Storage.storage()
        imageUrlCoupleList.forEach {
            guard $0.isFromCloud == false else {
                urlList.append($0.url)
                return
            }
            guard let imageData = try? Data(contentsOf: $0.url), let compressedImageData = UIImage(data: imageData)?.jpegData(compressionQuality: 0) else {
                print("[SellDetailsViewModel][getSavedUrlForImages] can not convert to data for \($0.url).")
                return
            }
            
            let imageUID = UUID().uuidString
            let storageRef = storage.reference()
                .child(MyKeys.imagesFolder.rawValue)
                .child(imageUID)
            workGroup.enter()
            //storageRef.putFile(from: $0.url, metadata: nil) { (metadata, error) in
            storageRef.putData(compressedImageData, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    workGroup.leave()
                    return
                }
                storageRef.downloadURL { (url, error) in
                    guard let url = url else {
                        workGroup.leave()
                        return
                    }
                    urlList.append(url)
                    workGroup.leave()
                }
            }
        }
        
        workGroup.notify(queue: DispatchQueue.main, execute: {
            completion(urlList)
        })
    }
    
    func getSavedUrlForVideo(completion: @escaping (URL?) -> Void) {
        guard let url = videoList.first else {
            completion(nil)
            return
        }
        let storage = Storage.storage()
        let videoUID = UUID().uuidString
        let storageRef = storage.reference()
            .child(MyKeys.videoFolder.rawValue)
            .child(videoUID)
        storageRef.putFile(from: url, metadata: nil) { (metadata, error) in
            guard error == nil else { return }
            storageRef.downloadURL { (url, error) in
                guard let url = url else { return }
                completion(url)
            }
        }
    }
    
    func setBidItemToUserDefault(itemId: String) {
        UserDefaults.standard.set(itemId, forKey: itemId)
        UserDefaults.standard.synchronize()
    }
    
    func getIsBidItemToUserDefault(itemId: String) -> Bool {
        guard let value = UserDefaults.standard.value(forKey: itemId) as? String else {
            return false
        }
        return itemId == value
    }

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
}
