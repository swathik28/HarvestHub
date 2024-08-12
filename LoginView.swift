//
//  LoginView.swift
//  SwiftUIAuth
//
//  Created by Swathi Karthikeyan on 4/12/24.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        NavigationStack{
            VStack{
                //image
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width:100, height:120)
                    .padding(.vertical, 32)
                // form fields
                VStack(spacing:24){
                    InputView(text: $email, title: "Email Address",placeholder: "name@example.com")
                        .autocapitalization(.none)
                    
                    InputView(text: $password, title: "password", placeholder: "Enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top,12)
                
                // sign in
                Button{
                    Task{
                        try await viewModel.signIn(withEmail: email, password: password)
                    }
                }   label: {
                    HStack{
                        Text("SIGN IN")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width-32, height: 48)
                }
                .background(Color(.systemBlue))
                .disabled(!formIsValid)
                .opacity(formIsValid ? 1.0 : 0.5)
                .cornerRadius(10)
                .padding(.top,24)
                Spacer()
                
                // sign up
                NavigationLink{
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                }label: {
                    HStack(spacing: 4){
                        Text ("Don't have an account?")
                        Text ("Sign Up")
                            .fontWeight(.bold)
                            .font(.system(size: 14))
                    }
                }
                
            }
        }
    }
}
extension LoginView: AuthenticationFormProtocol{
    var formIsValid: Bool{
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
