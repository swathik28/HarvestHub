import UIKit
import SwiftUI
import MapKit




class ViewController: UIViewController {
    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private let locationManager = CLLocationManager()
    private var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tech App"
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Set up location manager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Set up search controller
        setupSearchController()
    }

    
    private func setupSearchController() {
        let resultsViewController = SearchResultsViewController()
        resultsViewController.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    // Function to plan route between two locations
    private func planRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile // You can customize this for walking, transit, etc.
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else {
                if let error = error {
                    print("Error calculating directions: \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0] // Assume we only need the first route
            self.mapView.addOverlay(route.polyline)
        }
    }
}
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 31.9686, longitude: -99.9018), latitudinalMeters: 1000000, longitudinalMeters: 1000000)
        mapView.setRegion(region, animated: true)
        
        // Stop updating location to conserve battery
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}
extension ViewController: SearchResultsViewControllerDelegate {
    func didSelectLocation(_ location: MKPlacemark) {
        // Handle the selected location
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = location.name
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: true)
        
        // Optionally, you can plan a route from the user's current location to the selected location
        if let userLocation = mapView.userLocation.location {
            planRoute(from: userLocation.coordinate, to: location.coordinate)
        }
    }
}
class SearchResultsViewController: UIViewController, UISearchResultsUpdating, UITextFieldDelegate {
    weak var delegate: SearchResultsViewControllerDelegate?
    private var searchResults: [MKMapItem] = []
    private var mapView: MKMapView!
    private var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MKMapView(frame: view.bounds)
        mapView.delegate = self
        view.addSubview(mapView)
        
        searchTextField = UITextField(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        searchTextField.placeholder = "Search"
        searchTextField.borderStyle = .roundedRect
        searchTextField.delegate = self
        view.addSubview(searchTextField)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, !query.isEmpty else {
            searchResults.removeAll()
            mapView.removeAnnotations(mapView.annotations)
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, _ in
            guard let self = self, let response = response else { return }
            
            self.searchResults = response.mapItems
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                self.mapView.addAnnotation(annotation)
            }
            
            if let firstItem = response.mapItems.first {
                let region = MKCoordinateRegion(center: firstItem.placemark.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            searchLocation(text)
        }
        return true
    }
    
    // Function to search and zoom into the entered location
    private func searchLocation(_ locationName: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locationName
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self, let response = response, error == nil else {
                print("Error searching for location: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let mapItem = response.mapItems.first {
                let coordinate = mapItem.placemark.coordinate
                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
                self.mapView.setRegion(region, animated: true)
            }
        }
    }
}
extension SearchResultsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            let placemark = MKPlacemark(coordinate: annotation.coordinate)
            delegate?.didSelectLocation(placemark)
        }
    }
}
protocol SearchResultsViewControllerDelegate: AnyObject {
    func didSelectLocation(_ location: MKPlacemark)
}
