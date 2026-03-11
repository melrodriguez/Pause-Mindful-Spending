import SwiftUI

struct CreateAccountView: View {
    
    @Binding var showCreateAccount: Bool
    @StateObject var viewModel = CreateAccountViewModel()
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false

    var body: some View {
        
        VStack(spacing: 0) {
            
            // Header
            Spacer().frame(maxHeight: 30)
            
            HStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pause")
                        .font(Font.custom("Inter18pt-Bold", size: 32))
                    Text("for mindful spending")
                        .font(AppFonts.body)
                        .italic()
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
                .frame(maxHeight: 30)
            
            // Create account form and fields
            ScrollView {
                VStack(spacing: 12) {
                    
                    TextField("Enter your first name", text: $viewModel.name)
                        .font(AppFonts.subhead)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                    
                    TextField("Enter your email", text: $viewModel.email)
                        .font(AppFonts.subhead)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.systemGray4), lineWidth: 1))
                        .textInputAutocapitalization(.never)
                    
                    // Password
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
                    
                    // Confirm Password
                    ZStack(alignment: .trailing) {
                        Group {
                            if showConfirmPassword {
                                TextField("Confirm your password", text: $viewModel.passwordConfirmation)
                            } else {
                                SecureField("Confirm your password", text: $viewModel.passwordConfirmation)
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
                        
                        Button(action: { showConfirmPassword.toggle() }) {
                            Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 14)
                    }
                    
                    // Terms & Conditions
                    HStack(alignment: .top, spacing: 12) {
                        Button {
                            viewModel.hasAgreed.toggle()
                        } label: {
                            Image(viewModel.hasAgreed ? "CheckboxFilled" : "CheckboxUnfilled")
                                .frame(width: 20, height: 20)
                        }
                        
                        Text("By creating an account, you confirm that you have read and agree to our Terms & Conditions and Privacy Policy, and that you will use the app in accordance with these guidelines.")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    if !viewModel.statusMessage.isEmpty {
                        Text(viewModel.statusMessage)
                            .font(AppFonts.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Button(action: {
                        viewModel.pressedCreateAccountButton()
                    }) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .font(AppFonts.subhead)
                            .background(AppColors.mainGreen)
                            .foregroundColor(.black)
                            .cornerRadius(25)
                    }
                }
                .padding(.horizontal, AppLayout.horizontalScreenPadding)
                .padding(.bottom, 12)
            }
            
            // Button to log in
            Button(action: {
                showCreateAccount = false
            }) {
                Text("Already have an account? Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(AppFonts.subhead)
                    .foregroundColor(AppColors.mainGreen)
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(AppColors.mainGreen, lineWidth: 1.5))
                    .cornerRadius(25)
            }
            .padding(.horizontal, AppLayout.horizontalScreenPadding)
            .padding(.vertical, AppLayout.horizontalScreenPadding)
        }
        .ignoresSafeArea(.keyboard)
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .appBackground()
    }
}

#Preview {
    CreateAccountView(showCreateAccount: .constant(true))
}
