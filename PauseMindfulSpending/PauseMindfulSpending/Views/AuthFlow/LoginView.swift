import SwiftUI

struct LoginView: View {
    
    // send this to the backend
    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        
        VStack(spacing: AppLayout.horizontalScreenPadding) {
//            AppHeader(title:"")
//                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Spacer()
            
            VStack(spacing: 10) {
                                
                Image("AppLogo")
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text("Welcome to Pause: Mindful Spending")
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
                    
                    TextField("Enter your email", text: $viewModel.email)
                        .font(AppFonts.subhead)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                
                // TODO: password visibility toggle
                VStack(spacing: 5) {
                    Text("Password")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SecureField("Enter your password", text: $viewModel.password)
                        .font(AppFonts.subhead)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text(viewModel.statusMessage)
                    .font(AppFonts.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
                                    
            Button(action: {
                print("pressed login")
                viewModel.pressedLoginButton(email: viewModel.email, password: viewModel.password)
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(AppFonts.subhead)
                    .background(AppColors.mainGreen)
                    .foregroundColor(.black)
                    .cornerRadius(15)
            }
            
            HStack(alignment: .center) {
                Text("Haven't registered yet?")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                Button(action: {
                    print("pressed register button")
//                    viewModel.pressedLoginButton(email: viewModel.email, password: viewModel.password)
                }) {
                    Text("Register")
                        .font(AppFonts.caption)
                }
            }

            
        }
        
        .padding(AppLayout.horizontalScreenPadding)
        .appBackground()
    }
}

#Preview {
    LoginView()
}
