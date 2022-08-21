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
    
    
    init(fireCollectedAmount: [FireCollectedAmount]) {
        data = fireCollectedAmount.map {
            CellItem(
                receivedToken: $0.token,
                payedAmount: $0.amount
            )
        }
    }
    
    func filterData(str: String) {
        filteredData = data.filter({ $0.receivedToken.hasPrefix(str) })
    }
}
