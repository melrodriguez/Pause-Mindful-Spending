import SwiftUI

struct CreateAccountView: View {
    
    @Binding var showCreateAccount: Bool // flip between LoginView and CreateAccountView
    @StateObject var viewModel = CreateAccountViewModel()

    var body: some View {
        
        VStack(spacing: AppLayout.horizontalScreenPadding) {
            AppHeader(title:"")
                .frame(maxWidth: .infinity, alignment: .topLeading)
           
            VStack(spacing: 15) {
                
                VStack(spacing: 5){
                    Text("Create Account")
                        .font(AppFonts.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
            
                    Text("Join to Pause before your purchase & build mindful spending habits")
                        .font(AppFonts.caption)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                                
                VStack(spacing: 5) {
                    Text("Name")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextField("Enter your first name", text: $viewModel.name)
                        .font(AppFonts.subhead)
                        .textFieldStyle(.roundedBorder)
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
                
                VStack(spacing: 5) {
                    Text("Password")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SecureField("Confirm your password", text: $viewModel.passwordConfirmation)
                        .font(AppFonts.subhead)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Turn off autocaps and autofill
                        .textContentType(.oneTimeCode)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                
                HStack (spacing: 15) {
                    // Terms and conditions checkbox
                    Button {
                        // print("pressed agree to T&C")
                        viewModel.hasAgreed.toggle()
                    } label: {
                        Image(viewModel.hasAgreed ? "CheckboxFilled" : "CheckboxUnfilled")
                            .frame(width: 10, height: 10)
                    }
                                        
                    Text("By creating an account, you confirm that you have read and agree to our Terms & Conditions and Privacy Policy, and that you will use the app in accordance with these guidelines.")
                        .font(AppFonts.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(AppColors.textSecondary)
                }
                
            }
            
            Spacer()
            
            Text(viewModel.statusMessage)
                .font(AppFonts.caption)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 7) {
                Button(action: {
                    // print("pressed create account button")
                    viewModel.pressedCreateAccountButton()
                }) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(AppFonts.subhead)
                        .background(AppColors.mainGreen)
                        .foregroundColor(.black)
                        .cornerRadius(15)
                }
                
                HStack(alignment: .center) {
                    Text("Already have an account?")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    Button(action: {
                        // print("pressed login button")
                        showCreateAccount = false
                    }) {
                        Text("Login")
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
//    CreateAccountView(showRegister: $showRegister)
//}

