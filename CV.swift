import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit

extension Color {
    static let backgroundColor = Color(red: 0.6157, green: 0.7608, blue: 0.6353) // #9dc2a2
    static let fontColor = Color(red: 0.0431, green: 0.1176, blue: 0.0824) // #0b1e15
}

struct DonationDetails {
    var restaurantName: String
    var donatedFoodAmount: Int
    var location: String
    var pickupDateTime: Date
}

struct YourApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView() // Present ContentView as the initial screen
        }
    }
}

struct MainContentView: View {
    @State private var isPopoverPresented = false
    @State private var restaurantName = ""
    @State private var donatedFoodAmountString = ""
    @State private var location = ""
    @State private var amount = ""
    @State private var pickupDateTime = Date()
    @State private var showThankYouPopup = false
    @State public var showMapView = false// New state variable for "Thank you for Donating" popup

    var body: some View {
        VStack {
            Spacer()

            Image("donate3") // Replace "donate1" with your image asset name
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()

            Spacer()

            Button(action: {
                self.isPopoverPresented.toggle()
            }) {
                Text("Donate Food")
                    .font(.title)
                    .padding()
                    .cornerRadius(30)
                    .foregroundColor(Color.fontColor) // Text color set to fontColor
                    .background(Color.backgroundColor) // Background color set to backgroundColor
            }
            .padding()
            .popover(isPresented: $isPopoverPresented) {
                DonationDetailsPopover(
                    restaurantName: $restaurantName,
                    donatedFoodAmountString: $donatedFoodAmountString,
                    location: $location,
                    amount: $amount,
                    pickupDateTime: $pickupDateTime,
                    isPopoverPresented: $isPopoverPresented,
                    showThankYouPopup: $showThankYouPopup // Pass the binding to the Thank You popup
                )
            }

            Spacer()
        }
        .padding()
        .background(Color.backgroundColor) // Background color set to backgroundColor
        .sheet(isPresented: $showThankYouPopup, content: {
            ThankYouPopup() // Present the ThankYouViewController
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
        .edgesIgnoringSafeArea(.all)
    }
}

struct DonationDetailsPopover: View {
    @Binding var restaurantName: String
    @Binding var donatedFoodAmountString: String
    @Binding var location: String
    @Binding var amount: String
    @Binding var pickupDateTime: Date
    @Binding var isPopoverPresented: Bool
    @Binding var showThankYouPopup: Bool // New binding for "Thank you for Donating" popup

    
    
    var body: some View {
        VStack {
            Image("donate1") // Replace "donate2" with your image asset name
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()

            Text("Enter Donation Details")
                .font(.headline)
                .padding()
                .foregroundColor(Color.fontColor) // Text color set to fontColor

            TextField("Enter Restaurant Name", text: $restaurantName)
            TextField("Describe food", text: $donatedFoodAmountString)
                .keyboardType(.numberPad)
            TextField("Enter Amount of food (in pounds)", text: $amount)
            TextField("Enter Location", text: $location)

            DatePicker("Pickup Date and Time", selection: $pickupDateTime, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(GraphicalDatePickerStyle())
                .labelsHidden()
                .padding()

            Button("Submit Donation") {
                let db = Firestore.firestore()
                let donationData: [String: Any] = [
                    "restaurantName": restaurantName,
                    "donatedFoodAmountString": donatedFoodAmountString,
                    "location": location,
                    "amount": amount,
                    "pickupDateTime": pickupDateTime
                ]

                db.collection("name").addDocument(data: donationData) { error in
                    if let error = error {
                        print("Error adding document: \(error)")
                    } else {
                        print("Document added successfully!")
                    }
                }

                isPopoverPresented = false
                showThankYouPopup = true
            }

            .padding()
            .background(Color.backgroundColor) // Background color set to backgroundColor
            .foregroundColor(Color.fontColor) // Text color set to fontColor
        }
        .padding()
        .background(Color.backgroundColor) // Background color set to backgroundColor
        .foregroundColor(Color.fontColor) // Text color set to fontColor
            
    }
        
}


    

struct ThankYouPopup: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Color.backgroundColor // Background color set to backgroundColor
            .edgesIgnoringSafeArea(.all) // Extend the color to fill the entire screen
            .overlay(
                VStack {
                    Image("donate2") // Add your image asset name here
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding()

                    Text("Thank you for Donating!!!")
                        .font(.title)
                        .padding()
                        .foregroundColor(Color.fontColor) // Text color set to fontColor
                    Text("Your generosity is appreciated!")
                        .padding()
                        .foregroundColor(Color.fontColor) // Text color set to fontColor
                }
                
            )
        Button(action: {
                        self.presentationMode.wrappedValue.dismiss() // Dismiss the popup
                    }
        ) {
                        Text("Back to Donation Page")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding()
                }
    }
