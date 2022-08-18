//
//  CollectedAmountViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 18/8/22.
//

import Foundation



final class CollectedAmountViewModel {
    struct CellItem {
        var receivedToken: String
        var payedAmount: String
    }
    
    private var data: [CellItem] = []
    var filteredData: [CellItem] = []
    
    
    init() {
        data = [
            CellItem(receivedToken: "123456", payedAmount: "20"),
            CellItem(receivedToken: "129078", payedAmount: "30"),
            CellItem(receivedToken: "452178", payedAmount: "10"),
            CellItem(receivedToken: "412647", payedAmount: "100"),
            CellItem(receivedToken: "129456", payedAmount: "1200"),
            CellItem(receivedToken: "416498", payedAmount: "30"),
            CellItem(receivedToken: "123451", payedAmount: "20"),
            CellItem(receivedToken: "567126", payedAmount: "15"),
            CellItem(receivedToken: "416495", payedAmount: "5")
        ]
        filteredData = data
    }
    
    func filterData(str: String) {
        filteredData = data.filter({ $0.receivedToken.hasPrefix(str) })
    }
}
