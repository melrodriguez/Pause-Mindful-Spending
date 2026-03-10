import SwiftUI

struct CreateAccountView: View {
    
    // send this to the backend
//    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        
        VStack(spacing: AppLayout.horizontalScreenPadding) {
            AppHeader(title:"")
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Spacer()
            
            VStack(spacing: 10) {
                
                Text("Create Account")
                    .font(AppFonts.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack() {
                    Text("Remember,\n\nI am in control of my choices.\n\nMy money reflects my values, and I decide what matters.\n\nThe habits I build today support the life I want tomorrow.")
                        .font(AppFonts.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Spacer()
                                
                VStack(spacing: 5) {
                    
                    Text("Email")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
//                    TextField("Enter your email", text: $viewModel.email)
//                        .font(AppFonts.subhead)
//                        .textFieldStyle(.roundedBorder)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                // TODO: password visibility toggle
                VStack(spacing: 5) {
                    Text("Password")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
//                    SecureField("Enter your password", text: $viewModel.password)
//                        .font(AppFonts.subhead)
//                        .textFieldStyle(.roundedBorder)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text("Log in to continue building mindful spending habits and making intentional choices.")
                    .font(AppFonts.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
    
            }
            
            Spacer()
                        
            Button(action: {
                print("pressed login")
//                viewModel.pressedLoginButton(email: viewModel.email, password: viewModel.password)
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(AppFonts.subhead)
                    .background(AppColors.mainGreen)
                    .foregroundColor(.black)
                    .cornerRadius(15)
            }
        
//            Text(viewModel.statusMessage)
//                .font(AppFonts.caption)
//                .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
        .padding(AppLayout.horizontalScreenPadding)
        .appBackground()
    }
}

#Preview {
    CreateAccountView()
}

