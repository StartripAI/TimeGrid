//
//  LoginView.swift
//  时光格 V2.0 - 登录视图
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var authManager = AuthManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var showPhoneLogin = false
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isCodeSent = false
    @State private var countdown = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundCream").ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo 和标语
                    headerSection
                    
                    // 触发原因提示
                    if let trigger = authManager.loginTrigger {
                        triggerMessage(trigger)
                    }
                    
                    Spacer()
                    
                    // 登录按钮
                    loginButtons
                    
                    // 跳过按钮
                    skipButton
                    
                    // 协议
                    agreementText
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("TextSecondary"))
                    }
                }
            }
            .sheet(isPresented: $showPhoneLogin) {
                PhoneLoginSheet(
                    phoneNumber: $phoneNumber,
                    verificationCode: $verificationCode,
                    isCodeSent: $isCodeSent,
                    countdown: $countdown,
                    onLogin: handlePhoneLogin
                )
            }
            .alert("登录失败", isPresented: .constant(authManager.error != nil)) {
                Button("确定") {
                    authManager.error = nil
                }
            } message: {
                Text(authManager.error?.localizedDescription ?? "")
            }
        }
    }
    
    // MARK: - Sub Views
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            // Logo
            HStack(spacing: 8) {
                Text("Y")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                Circle()
                    .fill(Color("SealColor"))
                    .frame(width: 10, height: 10)
                Text("G E")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .tracking(8)
            }
            .foregroundColor(Color("TextPrimary"))
            
            Text("登录后，时光永不丢失")
                .font(.system(size: 16))
                .foregroundColor(Color("TextSecondary"))
        }
    }
    
    private func triggerMessage(_ trigger: RegistrationTrigger) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Color("PrimaryWarm"))
            
            Text(trigger.message)
                .font(.system(size: 14))
                .foregroundColor(Color("TextPrimary"))
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color("PrimaryWarm").opacity(0.1))
        .cornerRadius(12)
    }
    
    private var loginButtons: some View {
        VStack(spacing: 16) {
            // 微信登录（主推）
            Button {
                Task {
                    try? await authManager.loginWithWechat()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 20))
                    Text("微信一键登录")
                        .font(.system(size: 17, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(hex: "#07C160"))
                .cornerRadius(27)
            }
            
            // Apple 登录
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    handleAppleLogin(result)
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 54)
            .cornerRadius(27)
            
            // 手机号登录
            Button {
                showPhoneLogin = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                    Text("手机号登录")
                        .font(.system(size: 17, weight: .medium))
                }
                .foregroundColor(Color("TextPrimary"))
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color("CardBackground"))
                .cornerRadius(27)
                .overlay(
                    RoundedRectangle(cornerRadius: 27)
                        .stroke(Color("TextSecondary").opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
    
    private var skipButton: some View {
        Button {
            authManager.skipLogin()
            dismiss()
        } label: {
            Text("暂时跳过")
                .font(.system(size: 15))
                .foregroundColor(Color("TextSecondary"))
        }
        .padding(.top, 10)
    }
    
    private var agreementText: some View {
        HStack(spacing: 4) {
            Text("登录即代表同意")
                .foregroundColor(Color("TextSecondary"))
            
            Button("用户协议") {
                // 打开用户协议
            }
            .foregroundColor(Color("PrimaryWarm"))
            
            Text("和")
                .foregroundColor(Color("TextSecondary"))
            
            Button("隐私政策") {
                // 打开隐私政策
            }
            .foregroundColor(Color("PrimaryWarm"))
        }
        .font(.system(size: 12))
    }
    
    // MARK: - Actions
    
    private func handleAppleLogin(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let credential = auth.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    try? await authManager.loginWithApple(credential: credential)
                }
            }
        case .failure(let error):
            print("Apple Sign In Error: \(error)")
        }
    }
    
    private func handlePhoneLogin() {
        Task {
            try? await authManager.loginWithPhone(
                phone: phoneNumber,
                code: verificationCode
            )
            if authManager.authState.isLoggedIn {
                showPhoneLogin = false
            }
        }
    }
}

// MARK: - 手机号登录 Sheet

struct PhoneLoginSheet: View {
    @Binding var phoneNumber: String
    @Binding var verificationCode: String
    @Binding var isCodeSent: Bool
    @Binding var countdown: Int
    
    let onLogin: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var timer: Timer?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 手机号输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("手机号")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                    
                    TextField("请输入手机号", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .font(.system(size: 17))
                        .padding()
                        .background(Color("CardBackground"))
                        .cornerRadius(12)
                }
                
                // 验证码输入
                VStack(alignment: .leading, spacing: 8) {
                    Text("验证码")
                        .font(.system(size: 14))
                        .foregroundColor(Color("TextSecondary"))
                    
                    HStack(spacing: 12) {
                        TextField("请输入验证码", text: $verificationCode)
                            .keyboardType(.numberPad)
                            .font(.system(size: 17))
                            .padding()
                            .background(Color("CardBackground"))
                            .cornerRadius(12)
                        
                        Button {
                            sendCode()
                        } label: {
                            Text(countdown > 0 ? "\(countdown)s" : "获取验证码")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(countdown > 0 ? Color("TextSecondary") : Color("PrimaryWarm"))
                                .frame(width: 100)
                        }
                        .disabled(countdown > 0 || phoneNumber.count != 11)
                    }
                }
                
                Spacer()
                
                // 登录按钮
                Button {
                    onLogin()
                } label: {
                    Text("登录")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color("PrimaryWarm"), Color("SealColor")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(27)
                }
                .disabled(phoneNumber.count != 11 || verificationCode.count != 6)
                .opacity(phoneNumber.count == 11 && verificationCode.count == 6 ? 1 : 0.6)
            }
            .padding(30)
            .background(Color("BackgroundCream").ignoresSafeArea())
            .navigationTitle("手机号登录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(Color("TextSecondary"))
                }
            }
        }
        .presentationDetents([.medium])
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func sendCode() {
        Task {
            try? await AuthManager.shared.sendVerificationCode(to: phoneNumber)
            
            isCodeSent = true
            countdown = 60
            
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if countdown > 0 {
                    countdown -= 1
                } else {
                    timer?.invalidate()
                }
            }
        }
    }
}

