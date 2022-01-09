//
//  profileViewController.swift
//  chat app
//
//  Created by faisal on 01/06/1443 AH.
//

import UIKit
import Firebase
import FacebookLogin



class profileViewController: UIViewController {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var table: UITableView!
    
    var list=["Log out"]
    var user:Firebase.User?
    override func viewDidLoad() {
        super.viewDidLoad()
        if(!(myuser.userr?.picurl == nil)){
            downloadImage(from: URL(string: myuser.userr?.picurl ?? "")!)
        }
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        img.contentMode = .scaleAspectFill
        img.backgroundColor = .white
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = 3
        img.layer.masksToBounds = true
        img.layer.cornerRadius = img.width/2
        // Do any additional setup after loading the view.
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            // always update the UI from the main thread
            DispatchQueue.main.async() { [weak self] in
                self!.img.image = UIImage(data: data)
            }
        }
    }
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
   
}
extension profileViewController:UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = list[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // unhighlight the cell
        // logout the user
        
        // show alert
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            // action that is fired once selected
            guard let strongSelf = self else {
                return
            }
            do {
                try FirebaseAuth.Auth.auth().signOut()
                if AccessToken.current == nil { FBSDKLoginKit.LoginManager().logOut()}
                // present login view controller
                let vc = LoginViewController()
                vc.title = "Log in"
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self!.present(nav, animated: true)
            }
            catch {
                print("failed to logout")
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
}
