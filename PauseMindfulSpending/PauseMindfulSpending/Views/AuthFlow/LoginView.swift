import SwiftUI

struct LoginView: View {
    
    @Binding var showCreateAccount: Bool
    @StateObject var viewModel = LoginViewModel()
    @State private var showPassword: Bool = false

    var body: some View {
        
        VStack(spacing: 0) {
            
            // Header
            Spacer()
            
            HStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pause")
                        .font(Font.custom("Inter18pt-Bold", size: 32))
                    Text("for mindful spending")
                        .font(AppFonts.subhead)
                        .italic()
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Login form and fields
            VStack(spacing: 12) {
                
                TextField("Enter your email", text: $viewModel.email)
                    .font(AppFonts.subhead)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                    .textInputAutocapitalization(.never)
                
                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword {
                            TextField("Enter your password", text: $viewModel.password)
                        } else {
                            SecureField("Enter your password", text: $viewModel.password)
                        }
                    }
                    .font(AppFonts.subhead)
                    .padding()
                    .padding(.trailing, 44)
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                    .textContentType(.oneTimeCode)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 14)
                }
                
                if !viewModel.statusMessage.isEmpty {
                    Text(viewModel.statusMessage)
                        .font(AppFonts.caption)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button(action: {
                    viewModel.pressedLoginButton()
                }) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(AppFonts.subhead)
                        .background(AppColors.mainGreen)
                        .foregroundColor(.black)
                        .cornerRadius(25)
                }
                
                Button("Forgot Password?") {
                    // TODO - handle forgot password
                }
                .font(AppFonts.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, AppLayout.horizontalScreenPadding)
            
            Spacer()
            Spacer()
            
            // Create account button
            VStack(spacing: 7) {
                Button(action: {
                    showCreateAccount = true
                }) {
                    Text("Create new account")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(AppFonts.subhead)
                        .foregroundColor(AppColors.mainGreen)
                        .overlay(RoundedRectangle(cornerRadius: 25).stroke(AppColors.mainGreen, lineWidth: 2))
                        .cornerRadius(25)
                }
            }
            .padding(.horizontal, AppLayout.horizontalScreenPadding)
            .padding(.bottom, AppLayout.horizontalScreenPadding)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .appBackground()
        .ignoresSafeArea(.keyboard)
    }
}

#Preview {
    LoginView(showCreateAccount: .constant(false))
}
