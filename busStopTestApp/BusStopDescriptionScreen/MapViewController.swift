//
//  MapViewController.swift
//  busStopTestApp
//
//  Created by Иван Тиминский on 25.02.2022.
//

import UIKit
import MapKit

protocol MapViewControllerProtocol: AnyObject {
    var presenter: MapViewPresenterProtocol! { get set }
    
    func updateCollectionView()
}

class MapViewController: UIViewController {

    var presenter: MapViewPresenterProtocol!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePresentContainer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        presenter.notifyThatViewDidLoad()
        setupConstraints()
        // tap gesture on map view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        mapView.addGestureRecognizer(tapGesture)
        setupPanGesture()
    }
    
    //MARK: - Subviews
    lazy var mapView: MKMapView = makeMapView()
    
    lazy var busStopName: UILabel = {
        let label = UILabel()
        label.text =  "Остановка:  \(presenter.getBusStopInputModelName())"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 1
        return label
    }()
    
    lazy var arrivalTimeCollectionView: UICollectionView = {
        let layer = UICollectionViewFlowLayout()
        layer.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layer)
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: TimeArrivalCell.identifier, bundle: nil), forCellWithReuseIdentifier: TimeArrivalCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 22
        view.clipsToBounds = true
        return view
    }()
    
    lazy var panSign: UILabel = {
        let label = UILabel()
        label.text = "________"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()
    
    lazy var showScheduleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Показать расписание", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        button.layer.borderWidth = 2
        return button
    }()
    
    lazy var someButton1: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        return button
    }()
    
    lazy var someButton2: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        return button
    }()
    
    lazy var someButton3: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "point.topleft.down.curvedto.point.bottomright.up"), for: .normal)
        return button
    }()
    
    //MARK: Constants for bottomSheet
    let defaultHeight: CGFloat = 300
    let dismissibleHeight: CGFloat = 200
    let dismissStateHeight: CGFloat = 50
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 300
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    private func setupConstraints() {

        view.addSubview(mapView)
        view.addSubview(containerView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(arrivalTimeCollectionView)
        containerView.addSubview(busStopName)
        containerView.addSubview(panSign)
        containerView.addSubview(showScheduleButton)
        containerView.addSubview(someButton1)
        containerView.addSubview(someButton2)
        containerView.addSubview(someButton3)
        

        arrivalTimeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        busStopName.translatesAutoresizingMaskIntoConstraints = false
        panSign.translatesAutoresizingMaskIntoConstraints = false
        showScheduleButton.translatesAutoresizingMaskIntoConstraints = false
        someButton1.translatesAutoresizingMaskIntoConstraints = false
        someButton2.translatesAutoresizingMaskIntoConstraints = false
        someButton3.translatesAutoresizingMaskIntoConstraints = false
        
        // Set static constraints
        NSLayoutConstraint.activate([
            // set dimmedView edges to superview
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            
            panSign.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            panSign.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            panSign.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            busStopName.topAnchor.constraint(equalTo: panSign.bottomAnchor, constant: 18),
            busStopName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            busStopName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            
            arrivalTimeCollectionView.topAnchor.constraint(equalTo: busStopName.bottomAnchor, constant: 20),
            arrivalTimeCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            arrivalTimeCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            arrivalTimeCollectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            showScheduleButton.topAnchor.constraint(equalTo: arrivalTimeCollectionView.bottomAnchor, constant: 10),
            showScheduleButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            showScheduleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            showScheduleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            showScheduleButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            someButton1.topAnchor.constraint(equalTo: showScheduleButton.bottomAnchor, constant: 10),
            someButton1.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            someButton1.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.width/3),
            someButton1.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            someButton2.topAnchor.constraint(equalTo: showScheduleButton.bottomAnchor, constant: 10),
            someButton2.leadingAnchor.constraint(equalTo: someButton1.trailingAnchor),
            someButton2.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.width/3),
            someButton2.heightAnchor.constraint(greaterThanOrEqualToConstant: 50),
            someButton3.topAnchor.constraint(equalTo: showScheduleButton.bottomAnchor, constant: 10),
            someButton3.leadingAnchor.constraint(equalTo: someButton2.trailingAnchor),
            someButton3.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            someButton3.heightAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }

    @objc private func handleCloseAction() {
        animateContainerHeight(dismissStateHeight)
    }
    
    private func makeMapView() -> MKMapView {
        let mapView = MKMapView()
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        let location = presenter.getBusStopLocation()
        let point = MKPointAnnotation()
        point.coordinate = location
        mapView.centerToLocation(location)
        mapView.addAnnotation(point)
        
        view.addSubview(mapView)
        return mapView
    }
    
    private func setupPanGesture() {
        /// На весь контроллер
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: Pan gesture handler
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)

        // Get drag direction
        let isDraggingDown = translation.y > 0

        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                animateContainerHeight(dismissStateHeight)
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    private func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) { [weak self] in
            // Update container height
            self?.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self?.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    private func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self?.view.layoutIfNeeded()
        }
    }
}

//MARK: - MapViewControllerProtocol
extension MapViewController: MapViewControllerProtocol {
    func updateCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.arrivalTimeCollectionView.reloadData()
        }
    }
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter.getNumberOfRoutes()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeArrivalCell.identifier, for: indexPath) as! TimeArrivalCell
        guard let model = presenter.getBusStopDescription() else {
            return UICollectionViewCell()
        }
        cell.configureCell(with: model, for: indexPath)
        return cell
    }
    
    //MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60 , height:  50 )
    }
}

//MARK: extension MKMapView
private extension MKMapView {
  func centerToLocation(
    _ location: CLLocationCoordinate2D,
    regionRadius: CLLocationDistance = 1000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}



