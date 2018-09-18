import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var authenticationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateAuthenticationButton()
    }
    
    @IBAction func didTapAuthenticationButton(_ sender: Any) {
        if RemoteData.isAuthenticated {
            RemoteData.signOut()
                .done {
                    self.updateAuthenticationButton()
                }.catch { error in
                    print(error)
            }
        } else {
            RemoteData.authenticate(viewController: self)
                .done {
                    self.updateAuthenticationButton()
                }.catch { error in
                    print(error)
            }
        }
    }
    
    func updateAuthenticationButton() {
        authenticationButton.setTitle((RemoteData.isAuthenticated ? "Sign out" : "Sign in"), for: .normal)
    }
}
