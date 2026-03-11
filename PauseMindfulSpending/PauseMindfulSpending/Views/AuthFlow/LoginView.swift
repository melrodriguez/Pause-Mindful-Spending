import SwiftUI

struct LoginView: View {
    
    @Binding var showCreateAccount: Bool // flip between LoginView and CreateAccountView
    @StateObject var viewModel = LoginViewModel()

    var body: some View {
        
        VStack(spacing: AppLayout.horizontalScreenPadding) {
            Spacer()
            
            VStack(spacing: 10) {
                  
                VStack(spacing: 5){
                    Image("AppLogo")
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Text("Welcome to Pause: Mindful Spending")
                        .font(AppFonts.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
            
                    Text("Log in to continue building mindful spending habits and making intentional choices.")
                        .font(AppFonts.caption)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                                
                VStack(spacing: 5) {
                    
                    Text("Email")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Enter your email", text: $viewModel.email)
                        .font(AppFonts.subhead)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textInputAutocapitalization(.never)
                    
                }
                
                VStack(spacing: 5) {
                    Text("Password")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SecureField("Enter your password", text: $viewModel.password)
                        .font(AppFonts.subhead)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Turn off autocaps and autofill
                        .textContentType(.oneTimeCode)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                
            }
            
            Spacer()
                    
            Text(viewModel.statusMessage)
                .font(AppFonts.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 7) {
                Button(action: {
                    // print("pressed login")
                    viewModel.pressedLoginButton()
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
                    Button(action: { // Navigate to CreateAccountView
                        // print("pressed register button")
                        showCreateAccount = true
                    }) {
                        Text("Register")
                            .font(AppFonts.caption)
                    }
                }
            }
            
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .padding(AppLayout.horizontalScreenPadding)
        .appBackground()
    }
}

//#Preview {
//    LoginView()
//}
