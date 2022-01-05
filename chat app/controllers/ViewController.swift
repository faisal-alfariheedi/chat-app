//
//  ViewController.swift
//  chat app
//
//  Created by faisal on 01/06/1443 AH.
//

import UIKit
import Firebase
import FacebookLogin

class logiViewController: UIViewController {
    

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var login: UIButton!
    var fblogin = FBLoginButton()
    var own:convViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        email.layer.cornerRadius = 12
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.lightGray.cgColor
        pass.layer.cornerRadius = 12
        pass.layer.borderWidth = 1
        pass.layer.borderColor = UIColor.lightGray.cgColor
        if let token = AccessToken.current,
                !token.isExpired {
                    fblogin.permissions = ["public_profile", "email","image"]
                }else{

                    
                }
        fblogin.delegate=self
                            fblogin.center = view.center
                            fblogin.center.y += CGFloat(40)
                            view.addSubview(fblogin)
        // Do any additional setup after loading the view.
    }
    override func awakeFromNib() {
        
    }

    @IBAction func login(_ sender: UIButton) {
        
        if(!email.text!.isEmpty && !pass.text!.isEmpty){
            Auth.auth().signIn(withEmail: String(email.text!), password: String(pass.text!)) { (authResult: AuthDataResult?, error: Error?) in
                if let error = error {
                    print("failed to login, the error \(error.localizedDescription)")
                }else{
                    print("login was successful")
                    myuser.fireuser=authResult?.user
                    DBmanger.shared.setuser(with: myuser.fireuser!.email!)
                    /*self.own!.*/self.dismiss(animated: true, completion: nil)
                }
            }
        }
        email.text=""
        pass.text=""
    }
    
    @IBAction func register(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "reg", sender: 1)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let seg=segue.destination as! regViewController
        seg.own=own
    }
}

extension logiViewController:LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            return
        }else{
        if let result = result {
            if result.isCancelled {}else{
            let credential = FacebookAuthProvider
              .credential(withAccessToken: AccessToken.current!.tokenString)
            authwithfirebase(credential: credential)
            }
        }
        
        }
    }

    
    func authwithfirebase(credential: AuthCredential){
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              print("errr 1 \(error)")
              return
            }
            myuser.fireuser = authResult?.user
            print("errr " , myuser.fireuser!.email , myuser.fireuser!.uid)
            Profile.loadCurrentProfile(completion: { profile, error in
                print("errr 2 \(error)")
                if let profile = profile{
                    print("errr 3   |" + profile.userID)
                    DBmanger.shared.userDoExists(with: (profile.email)!, completion: {bool in
                                                    if (!bool) {
                                                        
                                                        DBmanger.shared.fbinsertUser(with: myuser.fireuser!.uid , email: myuser.fireuser!.email!.description , url:"nil" , first: profile.firstName ?? "no first", last: profile.lastName ?? "no last")
                                                             
                                                    }
                    })
                    DBmanger.shared.setuser(with: profile.email!)
                    self.dismiss(animated: true, completion: nil)
                }
            })
            
            
            
            
            // User is signed in
            // ...
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //
    }
}

