//
//  CreatePaymentViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 7/8/22.
//

import Foundation
import ReactiveSwift
import Stripe

final class CreatePaymentViewModel {
    enum EventUI {
        case showErrorAlert(title: String?, message: String?)
    }
    
    private let backendUrlString = "https://first-heroku-project-stripe.herokuapp.com"
    private let (observeOutput, sendInput) = Signal<EventUI, Never>.pipe()
    
    var paymentIntentClientSecret: String?
    var receivedToken: String?
    var fireAuctionItem: FireAuctionItem?
    
    var observeOutputSignal: SignalProducer<CreatePaymentViewModel.EventUI, Never> {
        observeOutput.producer
    }
    
    init(fireAuctionItem: FireAuctionItem?) {
        StripeAPI.defaultPublishableKey = "pk_test_51Hz6JlDZ7iVchg0Ba5xl3MfEtLKvyDnAap1LXw2YvUw7R7N8Gz8EIED446Tzf4OYPyRgfcldNoFlbuNnyVB1JrGY00n7ZEPonP"
        self.fireAuctionItem = fireAuctionItem
    }
    
    func fetchPaymentIntent(amount: String, onCompletion: @escaping () -> Void) {
        guard let backendUrl = URL(string: backendUrlString) else {
            print("[CreatePaymentViewModel][fetchPaymentIntent] in fetchPaymentIntent url is invalid.")
            onCompletion()
            return
        }
        let url = backendUrl.appendingPathComponent("/create-payment-intent")

        let shoppingCartContent: [String: Any] = [
            "amount": amount
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: shoppingCartContent)

        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                let clientSecret = json["clientSecret"] as? String,
                let receivedToken = json["token"] as? String
            else {
                let message = error?.localizedDescription ?? "Failed to decode response from server."
                DispatchQueue.main.async {
                    onCompletion()
                    self?.sendInput.send(value: .showErrorAlert(title: "Error loading page", message: message))
                }
                return
            }

            self?.paymentIntentClientSecret = clientSecret
            self?.receivedToken = receivedToken
            
            print("[CreatePaymentViewModel][fetchPaymentIntent] receivedToken = \(receivedToken)")

            DispatchQueue.main.async {
                onCompletion()
            }
        })

        task.resume()
    }
    
    func isOnlySpaceAndNewLineOrEmpty(text: String?) -> Bool {
        guard let text = text, text.isEmpty == false else {
            return true
        }
        
        for c in text {
            if c != " " && c != "\n" {
                return false
            }
        }
        return true
    }
    
    func isAmountValid(text: String?) -> Bool {
        guard let text = text, text.isEmpty == false else {
            return false
        }
        guard let value = Double(text), value >= 0.5 else {
            return false
        }
        return true
    }
    
    func multiplyBy100(text: String?) -> String? {
        guard let text = text, text.isEmpty == false else {
            return nil
        }
        guard let value = Double(text), value >= 0.5 else {
            return nil
        }
        return String(Int(value*100))
    }
}
