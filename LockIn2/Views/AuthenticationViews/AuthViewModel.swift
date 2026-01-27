//
//  AuthViewModel.swift
//  LockIn2
//
//  Created by Multazim Mesbah on 19/1/2026.
//
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isAuthenticated: Bool = false
    @Published var loginError: String?
    @Published var registerError: String?

    /// Convenience access to the current authenticated user's UUID.
    /// This is derived from `session` and will update whenever `session` changes.
    var userID: UUID? {
        session?.user.id
    }

    enum AuthError: LocalizedError {
        case notAuthenticated

        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "You must be signed in to do that."
            }
        }
    }

    /// Returns the current user id or throws if not signed in.
    func requireUserID() throws -> UUID {
        guard let id = userID else { throw AuthError.notAuthenticated }
        return id
    }
    
    private func normaliseEmail(_ email: String) -> String {
        return email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    private func validateEmail(_ email: String) -> String? {
        let email = normaliseEmail(email)
        guard !email.isEmpty else { return "Email is required." }
        
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        guard predicate.evaluate(with: email) else { return "Enter a valid email address." }
        return nil
    }
    
    private func validatePassword(_ password: String) -> String? {
        guard !password.isEmpty else { return "Password is required." }
        return nil
    }
    
    private func validateConfirmPassword(password: String, confirmPassword: String) -> String? {
        guard !confirmPassword.isEmpty else { return "Confirm password is required." }
        guard password == confirmPassword else { return "Passwords do not match." }
        return nil
    }
    
    private func setRegisterError(_ message: String?) {
        self.registerError = message
    }
    
    private func setLoginError(_ message: String?) {
        self.loginError = message
    }
    
    func getInitialSession() async {
        do {
            let current = try await supabaseClient.auth.session
            if current.isExpired {
                self.session = nil
                self.isAuthenticated = false
                return
            }
            self.session = current
            self.isAuthenticated = true
        } catch {
            self.session = nil
            self.isAuthenticated = false
            print("No active session: \(error.localizedDescription)")
        }
    }
    
    func register(email: String, password: String, confirmPassword: String) async {
        // Clear previous error
        setRegisterError(nil)

        if let emailError = validateEmail(email) {
            setRegisterError(emailError)
            return
        }
        if let passwordError = validatePassword(password) {
            setRegisterError(passwordError)
            return
        }
        if let confirmError = validateConfirmPassword(password: password, confirmPassword: confirmPassword) {
            setRegisterError(confirmError)
            return
        }

        do {
            let normalisedEmail = normaliseEmail(email)
            let result = try await supabaseClient.auth.signUp(email: normalisedEmail, password: password)
            self.session = result.session
            self.isAuthenticated = (self.session != nil)
            setRegisterError(nil)
        } catch {
            print("Registration failed: \(error.localizedDescription)")
            setRegisterError(error.localizedDescription)
        }
    }

    // Backwards-compatible wrapper
    func getInitalSession(email: String, password: String, confirmPassword: String) async {
        await register(email: email, password: password, confirmPassword: confirmPassword)
    }
    
    func login(email: String, password: String) async {
        setLoginError(nil)
        // Client-side validation
        if let emailError = validateEmail(email) {
            setLoginError(emailError)
            return
        }
        if let passwordError = validatePassword(password) {
            setLoginError(passwordError)
            return
        }

        do {
            //let result = try await supabase.auth.signIn(email: email, password: password)
            let normalisedEmail = normaliseEmail(email)
            let result = try await supabaseClient.auth.signIn(email: normalisedEmail, password: password)
            self.session = result
            self.isAuthenticated = self.session != nil
            setLoginError(nil)
            //Testing
        } catch {
            print("Login failed: \(error.localizedDescription)")
            setLoginError(error.localizedDescription)
        }
    }
    
    func signOut() async {
        do {
            try await supabaseClient.auth.signOut()
            self.session = nil
            self.isAuthenticated = false
        } catch {
            print("Signout failed: \(error.localizedDescription)")
        }
    }
}
