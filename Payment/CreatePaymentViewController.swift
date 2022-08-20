//
//  CreatePaymentViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 25/6/22.
//

import ReactiveSwift
import Stripe
import UIKit

final class CreatePaymentViewController: UIViewController {
    private let color = CustomColor(colorSpectrumValue: Int.random(in: CustomColor.colorRange)).value
    private let mainContainerView = UIView()
    private let textFieldContainerView = UIView()
    private let topHeight: CGFloat = 100
    private let textFieldContainerHeight: CGFloat = 400
    
    @IBOutlet weak var gmailLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var gmailTF: UITextField!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var currencyTF: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var disposables: Disposable?
    
    var viewModel: CreatePaymentViewModel!
    
    static func makeViewController(fireAuctionItem: FireAuctionItem?) -> CreatePaymentViewController {
        let storyboard = UIStoryboard(name: "CreatePayment", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreatePaymentViewController") as? CreatePaymentViewController
        vc?.viewModel = CreatePaymentViewModel(fireAuctionItem: fireAuctionItem)
        return vc ?? CreatePaymentViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        prepareView()
        
        disposables = viewModel.observeOutputSignal.startWithValues { [weak self] res in
            guard let self = self else { return }
            switch res {
            case .showErrorAlert(title: let title, message: let message):
                self.displayAlert(title: title ?? "", message: message)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposables?.dispose()
    }
    
    private func prepareView() {
        gmailLabel.textColor = .white
        amountLabel.textColor = .white
        currencyLabel.textColor = .white
        
        currencyTF.text = "USD"
        currencyTF.isEnabled = false
        
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitleColor(.lightGray, for: .highlighted)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = color.secondLevelColor
        confirmButton.clipsToBounds = true
        confirmButton.layer.cornerRadius = 5
    }
    
    private func setupNavigationBar() {
        self.view.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @IBAction func confirmButtonAction(_ sender: UIButton) {
        guard viewModel.isOnlySpaceAndNewLineOrEmpty(text: gmailTF.text) == false else {
            displayAlert(title: "Error", message: "Gmail can not be empty.")
            return
        }
        guard viewModel.isOnlySpaceAndNewLineOrEmpty(text: amountTF.text) == false else {
            displayAlert(title: "Error", message: "Amount can not be empty.")
            return
        }
        guard let _ = amountTF.text, viewModel.isAmountValid(text: amountTF.text) else {
            displayAlert(title: "Error", message: "Amount not valid. Minimum 0.5 dollar")
            return
        }
        guard let amount100 = viewModel.multiplyBy100(text: amountTF.text) else {
            displayAlert(title: "Error", message: "Amount not valid. Minimum 0.5 dollar")
            return
        }
        
        GlobalUITask.showSpinner(viewController: self)
        viewModel.fetchPaymentIntent(amount: amount100) { [weak self] in
            guard let self = self else { return }
            GlobalUITask.removeSpinner(viewController: self)
            self.showPaymentView()
        }
        //self.navigationController?.present(CheckoutViewController2(), animated: true)
    }
    
    func showPaymentView() {
        guard let paymentIntentClientSecret = viewModel.paymentIntentClientSecret else {
            return
        }

        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Card Details"

        let paymentSheet = PaymentSheet(
            paymentIntentClientSecret: paymentIntentClientSecret,
            configuration: configuration
        )

        paymentSheet.present(from: self) { [weak self] (paymentResult) in
            switch paymentResult {
            case .completed:
                self?.displayAlert(title: "Payment complete!")
            case .canceled:
                self?.displayAlert(title: "Payment cancelled!")
            case .failed(let error):
                self?.displayAlert(title: "Payment failed", message: error.localizedDescription)
            }
        }
    }
    
    func displayAlert(title: String? = nil, message: String? = nil) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
}
