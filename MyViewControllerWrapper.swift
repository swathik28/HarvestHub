import SwiftUI
import MapKit

struct MapView: View {
    @State private var searchQuery: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedLocation: MKPlacemark?
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var route: MKRoute?
    
    var body: some View {
        ZStack(alignment: .top) {
            MapKitView(searchResults: searchResults, selectedLocation: $selectedLocation, userLocation: $userLocation, route: $route)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                    
                    TextField("Search", text: $searchQuery)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 8)
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Button(action: searchLocation) {
                        Text("Search")
                            .foregroundColor(.blue)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 8)
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(8)
                .padding(.horizontal)
                
                Spacer()
                
                if let selectedLocation = selectedLocation {
                    VStack {
                        Text(selectedLocation.title ?? "")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button(action: getDirections) {
                            Text("Get Directions")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding()
                        .disabled(userLocation == nil)
                    }
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(8)
                    .padding()
                }
            }
            .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            hideKeyboard()
        }
    }
    
    private func searchLocation() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else { return }
            if let firstMapItem = response.mapItems.first {
                self.selectedLocation = firstMapItem.placemark
                self.userLocation = firstMapItem.placemark.coordinate // Update userLocation to selected location
                self.searchResults = response.mapItems // Update search results to show selected location on map
                
                // Call showDirections function passing the selected and user locations
                self.showDirections(from: self.userLocation!, to: firstMapItem.placemark.coordinate)
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func getDirections() {
        guard let selectedLocation = selectedLocation?.coordinate, let userLocation = userLocation else { return }
        
        // Call showDirections function passing the selected and user locations
        showDirections(from: userLocation, to: selectedLocation)
    }
    
    private func showDirections(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first else {
                // Handle error here
                print("Error calculating route: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self.route = route // Update route variable
            }
        }
    }
}

struct MapKitView: UIViewRepresentable {
    var searchResults: [MKMapItem]
    @Binding var selectedLocation: MKPlacemark?
    @Binding var userLocation: CLLocationCoordinate2D?
    @Binding var route: MKRoute?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        
        for item in searchResults {
            let annotation = MKPointAnnotation()
            annotation.coordinate = item.placemark.coordinate
            annotation.title = item.name
            uiView.addAnnotation(annotation)
        }
        
        if let route = route {
            uiView.removeOverlays(uiView.overlays)
            uiView.addOverlay(route.polyline)
            
            // Adjust the visible map rect to show the route
            uiView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitView
        
        init(_ parent: MapKitView) {
            self.parent = parent
        }
        
        // Handle overlay rendering
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .blue
            renderer.lineWidth = 5
            return renderer
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
