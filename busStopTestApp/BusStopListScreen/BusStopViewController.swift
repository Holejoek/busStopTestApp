//
//  BusStopViewController.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 24.02.2022.
//

import Foundation
import UIKit

protocol BusStopViewControllerProtocol: AnyObject {
    var presenter: BusStopPresenterProtocol! { get set }
    
    func updateCells()
    func showError(with: Error?, orSomeErrorText: String?)
}

final class BusStopViewController: UIViewController {
    
    var presenter: BusStopPresenterProtocol!
    lazy var tableView: UITableView = makeTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Выберите остановку"
        view.backgroundColor = .systemBackground
        presenter.notifyThatViewDidLoad()
    }
    
    private func makeTableView() -> UITableView {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "BusStopTableViewCell", bundle: nil), forCellReuseIdentifier: BusStopTableViewCell.identifier)
        tableView.frame = view.frame
        view.addSubview(tableView)
        return tableView
    }
}

//MARK: - BusStopViewControllerProtocol
extension BusStopViewController: BusStopViewControllerProtocol {
    
    func showError(with error: Error?, orSomeErrorText: String?) {
        let errorNetAlert: UIAlertController!
        if error != nil {
            let alert = UIAlertController(title: "Ошибка", message: error?.localizedDescription, preferredStyle: .alert)
            errorNetAlert = alert
        } else {
            let alert = UIAlertController(title: "Ошибка", message: orSomeErrorText, preferredStyle: .alert)
            errorNetAlert = alert
        }
        let errorNetAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        errorNetAlert.addAction(errorNetAction)
        present(errorNetAlert, animated: true, completion: nil)
    }
    
    func updateCells() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource

extension BusStopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.getNumberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: BusStopTableViewCell.identifier, for: indexPath) as! BusStopTableViewCell
        
        let model = presenter.getModelForCellAt(indexPath)
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        presenter.getHeightForRowAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectedRowAt(indexPath: indexPath)
    }
}
 
