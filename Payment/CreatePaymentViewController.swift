//
//  CreatePaymentViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 25/6/22.
//

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
    
    
    static func makeViewController() -> CreatePaymentViewController {
        let storyboard = UIStoryboard(name: "CreatePayment", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreatePaymentViewController") as? CreatePaymentViewController
        return vc ?? CreatePaymentViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        prepareView()
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
    }
}
