//
//  CollectedAmountViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 18/8/22.
//

import UIKit

class CollectedAmountViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var viewModel: CollectedAmountViewModel!
    private let tableViewCellId = "CollectedAmountCell"
    private let color = CustomColor(colorSpectrumValue: Int.random(in: CustomColor.colorRange)).value
    private let searchController = UISearchController(searchResultsController: nil)
    
    static func makeViewController(fireCollectedAmount: [FireCollectedAmount]) -> CollectedAmountViewController {
        let storyboard = UIStoryboard(name: "CollectedAmount", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CollectedAmountViewController") as? CollectedAmountViewController
        vc?.viewModel = CollectedAmountViewModel(fireCollectedAmount: fireCollectedAmount)
        return vc ?? CollectedAmountViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.filterData(str: "")
    }
    
    private func setupNavigationBar() {
        self.view.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        //navigationController?.navigationItem.searchController = searchController
        //navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search ...."
        definesPresentationContext = true
    }
    
    private func setupTableView() {
        tableView.backgroundColor = color.groundLevelColor
        self.view.backgroundColor = color.groundLevelColor
        
        tableView.delegate = self
        tableView.dataSource = self
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CollectedAmountCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: tableViewCellId)
    }
}

extension CollectedAmountViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellId, for: indexPath) as! CollectedAmountCell
        
        let cellItem = viewModel.filteredData[indexPath.item]
        
        cell.backgroundColor = color.groundLevelColor
        
        cell.receivedToken.text = cellItem.receivedToken
        cell.amountPayed.text = "$\(cellItem.payedAmount)"
        
        cell.receivedToken.textAlignment = .left
        cell.amountPayed.textAlignment = .right
        
        cell.receivedToken.textColor = .white
        cell.amountPayed.textColor = .white
        
        cell.containerView.backgroundColor = color.firstLevelColor
        cell.containerView.layer.masksToBounds = true
        cell.containerView.layer.cornerRadius = 10
        
        return cell
    }
}

extension CollectedAmountViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = color.groundLevelColor
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = color.groundLevelColor
        return view
    }
}

extension CollectedAmountViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        //print("\(text)")
        viewModel.filterData(str: text ?? "")
        tableView.reloadData()
    }
}
