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
    
    private var conversations = [Conversation]()
        
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return table
    }()

    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Conversations!"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = false
        return label
    }()

    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
       
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.startListeningForCOnversations()
        })
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
        validateAuth()
        
        setupTableView()
        
        
           
       }
    
    private func startListeningForCOnversations() {
        let email = Auth.auth().currentUser!.email!
        
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }

        print("starting conversation fetch...")

        let safeEmail = DBmanger.shared.safeEmail(email: email)

        DBmanger.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            
            
            switch result {
            case .success(let conversations):
                print("successfully got conversation models")
                if conversations.isEmpty  {
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    print("errr nothing")
                    return
                }
                    print("errr yay")

                self?.noConversationsLabel.isHidden = true
                self?.tableView.isHidden = false
                self?.conversations = conversations

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("errr failed to get convos: \(error)")
            }
        })
    }
    
    @IBAction func newconv(_ sender: UIBarButtonItem) {
        let vc = newconvoViewController()
        vc.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }

            let currentConversations = strongSelf.conversations

            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DBmanger.shared.safeEmail(email: result.email)
            }) {
                print("there")
                let vc = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                vc.isNewConversation = false
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
            else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    private func createNewConversation(result: SearchResult) {
        print("here")
        let name = result.name
        let email = DBmanger.shared.safeEmail(email: result.email)

        // check in datbase if conversation with these two users exists
        // if it does, reuse conversation id
        // otherwise use existing code
        print(email)
        DBmanger.shared.conversationExists(iwth: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                print("bad")
                return
            }
            print(result)
            switch result {
            case .success(let conversationId):
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConversation = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            case .failure(_):
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConversation = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    private func validateAuth(){
           // current user is set automatically when you log a user in
           if Auth.auth().currentUser == nil {
    
               let vc = LoginViewController()
               vc.title = "Log in"
               let nav = UINavigationController(rootViewController: vc)
               nav.modalPresentationStyle = .fullScreen
               present(nav, animated: true)
               
           }else{
               DBmanger.shared.setuser(with: (Auth.auth().currentUser!.email!) )
               print("errr here")
               startListeningForCOnversations()
               
               
           }
    

    }
    private func setupTableView(){
           tableView.delegate = self
           tableView.dataSource = self
       }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.height-100)/2,
                                            width: view.width-20,
                                            height: 100)
    }
       
       
}



extension convViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier,
                                                 for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }

    func openConversation(_ model: Conversation) {
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // begin delete
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)

            DBmanger.shared.deleteConversation(conversationId: conversationId, completion: { success in
                if !success {
                    // add model and row back and show error alert

                }
            })

            tableView.endUpdates()
        }
    }
}
