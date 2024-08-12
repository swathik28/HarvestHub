import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit

// Define a model to represent the donation details
struct Donation: Identifiable {
    let id: String
    let restaurantName: String
    let donatedFoodAmountString: String
    let location: String
    let amount: String
    let pickupDateTime: Date
}

// View model to fetch and manage donation data
class DonationViewModel: ObservableObject {
    @Published var donations: [Donation] = []
    
    private var db = Firestore.firestore()
    
    // Fetch donations from Firestore
    func fetchDonations() {
        db.collection("name").getDocuments { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                return
            }
            
            self.donations = documents.map { queryDocumentSnapshot -> Donation in
                let data = queryDocumentSnapshot.data()
                let id = queryDocumentSnapshot.documentID
                
                let restaurantName = data["restaurantName"] as? String ?? ""
                let donatedFoodAmountString = data["donatedFoodAmountString"] as? String ?? ""
                let location = data["location"] as? String ?? ""
                let amount = data["amount"] as? String ?? ""
                let pickupDateTime = (data["pickupDateTime"] as? Timestamp)?.dateValue() ?? Date()
                
                return Donation(id: id, restaurantName: restaurantName, donatedFoodAmountString: donatedFoodAmountString, location: location, amount: amount, pickupDateTime: pickupDateTime)
            }
        }
    }
}

struct DonationListView: View {
    @ObservedObject var viewModel = DonationViewModel()
    @State private var showMap = false // State to control navigation to the map view
    
    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.donations) { donation in
                    DonationRowView(donation: donation) {
                        // Closure to handle remove button tap
                        removeDonation(donation)
                    }
                }
                .navigationTitle("Donations")
                .onAppear {
                    viewModel.fetchDonations()
                }
                
                // Button to show the map view
                Button(action: {
                    showMap = true
                }) {
                    SettingsRowView(imageName: "arrow.right.circle.fill", title: "Show Map", tintColor: .blue)
                }
                .sheet(isPresented: $showMap) {
                    MapView()
                }
                .disabled(viewModel.donations.isEmpty) // Disable button if there are no donations
            }
        }
    }
    
    private func removeDonation(_ donation: Donation) {
        // Remove the donation from the view model's donations array
        if let index = viewModel.donations.firstIndex(where: { $0.id == donation.id }) {
            viewModel.donations.remove(at: index)
            
            // Remove the donation from Firestore
            let db = Firestore.firestore()
            db.collection("name").document(donation.id).delete { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                }
            }
        }
    }
}



struct DonationRowView: View {
    let donation: Donation
    let removeAction: () -> Void // Closure to handle remove button tap
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Restaurant Name: \(donation.restaurantName)")
            Text("Description: \(donation.donatedFoodAmountString)")
            Text("Location: \(donation.location)")
            Text("Amount: \(donation.amount)")
            Text("Pickup Date and Time: \(formattedDate(date: donation.pickupDateTime))")
            
            Button(action: removeAction) {
                Text("Remove")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
    
    // Helper function to format Date
    private func formattedDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return dateFormatter.string(from: date)
    }
}
