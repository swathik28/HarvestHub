//
//  ProfileView.swift
//  SwiftUIAuth
//
//  Created by Swathi Karthikeyan on 4/12/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        if let user = viewModel.currentUser{
            NavigationView {
                List {
                    Section{
                        
                        HStack {
                            Text(user.initials)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(width: 72, height: 72)
                                .background(Color(.systemGray3))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullname)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top,4)
                                
                                Text(user.email)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                
                            }
                        }
                    }
                    Section("Welcome") {
                        HStack{
                            SettingsRowView(imageName: "hand.wave.fill", title: "Hello, \(user.fullname)", tintColor: Color(.systemGray))
                            Spacer()
                            
                            
                        }
                    }
                    Section("Account") {
                        Button{
                            viewModel.signOut()
                        }label: {
                            SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                        }
                    }
                    
                    Section("Organization/Restaurant") {
                        NavigationLink(destination: MainContentView()) {
                            SettingsRowView(imageName: "arrow.right.circle.fill", title: "Donater", tintColor: .blue)
                            
                        }
                        NavigationLink(destination: DonationListView()) {
                            SettingsRowView(imageName: "arrow.right.circle.fill", title: "Receiver", tintColor: .blue)
                        }
                    }
                    .navigationBarTitle("Profile") // Set navigation bar title
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
