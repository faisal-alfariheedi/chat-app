//
//  convViewController.swift
//  chat app
//
//  Created by faisal on 01/06/1443 AH.
//

import UIKit
import Firebase
import JGProgressHUD

class convViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    var chatlist = [String]()
        
        private let tableView: UITableView = {
            let table = UITableView()
            table.isHidden = true // first fetch the conversations, if none (don't show empty convos)
            
            table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            return table
        }()
        
        private let noConversationsLabel: UILabel = {
            let label = UILabel()
            label.text = "No conversations"
            label.textAlignment = .center
            label.textColor = .gray
            label.font = .systemFont(ofSize: 21, weight: .medium)
            return label
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
     
           validateAuth()
       }
    
    @IBAction func newconv(_ sender: UIBarButtonItem) {
    }
    private func validateAuth(){
           // current user is set automatically when you log a user in
           if Auth.auth().currentUser == nil {
               // present login view controller
               performSegue(withIdentifier: "login", sender: 1)
//               let vc = logiViewController()
//               let nav = UINavigationController(rootViewController: vc)
//               nav.modalPresentationStyle = .fullScreen
//               present(nav, animated: true)
           }
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let seg=segue.destination as! UINavigationController
        let log = seg.viewControllers[0] as! logiViewController
        log.own=self
        
    }
    private func setupTableView(){
           tableView.delegate = self
           tableView.dataSource = self
       }
       
       private func fetchConversations(){
           // fetch from firebase and either show table or label
           
           if(!chatlist.isEmpty){
               noConversationsLabel.isHidden=true
               tableView.isHidden = false
           }
       }
    }



extension convViewController: UITableViewDelegate, UITableViewDataSource {
   
   
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1
   }
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       cell.textLabel?.text = "Hello World"
       cell.accessoryType = .disclosureIndicator
       return cell
   }
   
   // when user taps on a cell, we want to push the chat screen onto the stack
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       tableView.deselectRow(at: indexPath, animated: true)
       
       let vc = newconvViewController()
       vc.title = "Jenny Smith"
       vc.navigationItem.largeTitleDisplayMode = .never
       navigationController?.pushViewController(vc, animated: true)
   }
}
