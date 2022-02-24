//
//  BusStopViewController.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 24.02.2022.
//

import Foundation

protocol BusStopViewControllerProtocol {
    var presenter: ArticlePresenterProtocol! { get }
    
    func updateCells()
    func showError(with: Error)
    func showActivityIndicator(isActive: Bool)
}

class BusStopViewController: UIViewController, BusStopViewControllerProtocol {
    
    var viewModel: SourcesViewModelProtocol!
    lazy var collectionView: UICollectionView = makeCollectionView()
    var sourceNames = [String]()
    var sourceCategories = [String]()
    // Animations
    // Свойства для анимации перехода
    var selectedIndexOfCell: IndexPath?
    var selectedCell: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        makeDataBinding()
        collectionView.reloadData()
        viewModel.getSources()
        //Animation
        self.navigationController?.delegate = self
    }
    
    private func configureViewController() {
        navigationItem.title = "Выберите источник новостей"
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont(name: "Baskerville", size: 20) ?? UIFont.systemFont(ofSize: 20)]
        view.createGradient(firstColor: .startFirstMainBack, secondColor: .startSecondMainBack, startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1), isAnimated: true, finalGradien: [.firstMainBack, .secondMainBack])
    }
    
    private func makeCollectionView() -> UICollectionView{
        let layer = UICollectionViewFlowLayout()
        layer.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: view.frame, collectionViewLayout: layer)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UINib(nibName: "SourcesCell", bundle: nil), forCellWithReuseIdentifier: "SourceCell")
        // constaints
        let safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets.top + (navigationController?.navigationBar.frame.height ?? 0)  // Необходимо найти альтернативу
        collectionView.frame.origin.y = safeAreaInsets
        collectionView.frame.size.height -= safeAreaInsets
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        return collectionView
    }
    
    private func makeDataBinding() {
        viewModel.sourceNames.bind { [weak self] names in
            guard let strongSelf = self else { return }
            strongSelf.sourceNames = names
        }
        viewModel.sourceCategories.bind { [weak self] categories in
            guard let strongSelf = self else { return }
            strongSelf.sourceCategories = categories
        }
    }
}

//MARK: - Extension Output
extension SourcesViewController: SourcesViewProtocol {
    func showError(error: Error?, orSomeErrorText: String?) {
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
    func updateData() {
        collectionView.reloadData()
    }
}

