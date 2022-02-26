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
}

class MapViewController: UIViewController {

    var presenter: MapViewPresenterProtocol!
    
    lazy var mapView: MKMapView = makeMapView()
    
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

    lazy var busStopName: UILabel = {
        let label = UILabel()
        label.text = presenter.getBusStopInputModelName()
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
//        collectionView.register(UINib(nibName: "BannerCollectionCell", bundle: nil), forCellWithReuseIdentifier: BannerCollectionViewCell.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    // Constants
    let defaultHeight: CGFloat = 300
    let dismissibleHeight: CGFloat = 200
    let dismissStateHeight: CGFloat = 50
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    // keep current new height, initial is default height
    var currentContainerHeight: CGFloat = 300
    
    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?
    
    func setupConstraints() {
        // Add subviews
        view.addSubview(mapView)
        view.addSubview(containerView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(arrivalTimeCollectionView)
        containerView.addSubview(busStopName)
        containerView.addSubview(panSign)

        arrivalTimeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        busStopName.translatesAutoresizingMaskIntoConstraints = false
        panSign.translatesAutoresizingMaskIntoConstraints = false
        
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
            arrivalTimeCollectionView.topAnchor.constraint(equalTo: busStopName.bottomAnchor, constant: 8),
        
            arrivalTimeCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            arrivalTimeCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
        ])
        
        ///Динамичная стандартная высота шторки
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupConstraints()
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        mapView.addGestureRecognizer(tapGesture)
        
        setupPanGesture()
    }
    @objc func handleCloseAction() {
        animateContainerHeight(dismissStateHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        animateShowDimmedView()
        animatePresentContainer()
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
        
//      let button = UIButton()
//        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
//        button.backgroundColor = .red
//        button.setTitle("SSSS", for: .normal)
//
//        mapView.addSubview(button)
        
        view.addSubview(mapView)
        return mapView
    }
    
    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }
    
    
    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        // New height is based on value of dragging plus current container height
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
            } else if newHeight < defaultHeight {
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
    
    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 2) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }
    
    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
//    func animateShowDimmedView() {
//        dimmedView.alpha = 0
//        UIView.animate(withDuration: 0.4) {
//            self.dimmedView.alpha = self.maxDimmedAlpha
//        }
//    }
    
//    func animateDismissView() {
//        // hide blur view
//        dimmedView.alpha = maxDimmedAlpha
//        UIView.animate(withDuration: 0.4) {
//            self.dimmedView.alpha = 0
//        } completion: { _ in
//            // once done, dismiss without animation
//            self.dismiss(animated: false)
//        }
//        // hide main view by updating bottom constraint in animation block
//        UIView.animate(withDuration: 0.3) {
//            self.containerViewBottomConstraint?.constant = self.defaultHeight
//            // call this to trigger refresh constraint
//            self.view.layoutIfNeeded()
//        }
//    }
    
}

extension MapViewController: MapViewControllerProtocol {
    
}

extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        UICollectionViewCell()
    }
    
    
}

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



