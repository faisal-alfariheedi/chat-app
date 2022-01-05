//
//  regViewController.swift
//  chat app
//
//  Created by faisal on 01/06/1443 AH.
//

import UIKit
import Firebase

class regViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var pass: UITextField!
    @IBOutlet weak var first: UITextField!
    @IBOutlet weak var last: UITextField!
    @IBOutlet weak var img: UIImageView!
    
    var imgsel=false
    var own:convViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func register(_ sender: UIButton) {
        
        if(!email.text!.isEmpty && !pass.text!.isEmpty && !first.text!.isEmpty && !last.text!.isEmpty && imgsel ){
            if( pass.text!.count > 5){
            DBmanger.shared.userDoExists(with: email.text!, completion: {bool in
                if(bool){
                    print("\(self.email.text!) already registred")
                }
                self.newuser()
            })}else{
                print("short password 6 is the minmum")
            }
            
        }
        
    }
    func newuser(){
        Auth.auth().createUser(withEmail: String(email.text!), password: String(pass.text!)){ (authResult: AuthDataResult?, error: Error?) in
            if let error = error {
                print("something went wrong, can`t creat the account, error is \(error.localizedDescription) ")
            }else{
                print("account \(self.email.text!) was successfully created ")
                let temp = authResult!.user
                myuser.fireuser=authResult!.user
                
                
                DBmanger.shared.insertUser(with: temp,img: self.img.image!.jpegData(compressionQuality: 1)!,first: self.first.text!,last: self.last.text!)
                
                self.own!.dismiss(animated: true, completion: nil)
                
            }
        }
    }
    
    
    
    @IBAction func imageselect(_ sender: UIButton) {
        selectalert()
    }
    

}


extension regViewController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // get results of user taking picture or selecting from camera roll
    func selectalert(){
        let selalert = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture?", preferredStyle: .actionSheet)
        selalert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        selalert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            self?.camera()
        }))
        selalert.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { [weak self] _ in
            self?.photopicker()
        }))
        
        present(selalert, animated: true)
    }
    func camera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func photopicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let Image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        
        self.img.image = Image
        self.imgsel=true
        picker.dismiss(animated: true, completion: nil)
        print(info)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
