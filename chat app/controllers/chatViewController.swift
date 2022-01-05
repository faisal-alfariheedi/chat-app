//
//  newconvViewController.swift
//  chat app
//
//  Created by faisal on 01/06/1443 AH.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class chatViewController: MessagesViewController{


    public static var dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateStyle = .medium
           formatter.timeStyle = .long
           formatter.locale = .current
           return formatter
       }()

       public let otherUserEmail: String
       private let conversationId: String?
       public var isNewConversation = false

       private var messages = [Message]()





       init(with email: String, id: String?) {
           self.conversationId = id
           self.otherUserEmail = email
           super.init(nibName: nil, bundle: nil)

           // creating a new conversation, there is no identifier



       }

       required init?(coder: NSCoder) {
           fatalError("init    (coder:) has not been implemented")
       }

       private var selfSender: Sender? {
           guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
               // we cache the user email
               return nil
           }

           let safeEmail = DBmanger.shared.safeEmail(email: email)

           return Sender(photoURL: "", senderId: safeEmail, displayName: "Me")
       }
       // will use sender's email address plus random ID generated and put into firebase
       // photo URL, we will grab that URL once uploaded

       override func viewDidLoad() {
           super.viewDidLoad()

           view.backgroundColor = .green

           messagesCollectionView.messagesDataSource = self
           messagesCollectionView.messagesLayoutDelegate = self
           messagesCollectionView.messagesDisplayDelegate = self
           messageInputBar.delegate = self


       }

//       private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
//           DBmanger.shared.getAllMessagesForConversation(with: id) { [weak self] result in
//               switch result {
//               case .success(let messages):
//                   print("success in getting messages: \(messages)")
//                   guard !messages.isEmpty else {
//                       print("messages are empty")
//                       return
//                   }
//                   self?.messages = messages
//
//                   DispatchQueue.main.async {
//                       self?.messagesCollectionView.reloadDataAndKeepOffset()
//
//                       if shouldScrollToBottom {
//                           self?.messagesCollectionView.scrollToLastItem()
//
//                       }
//
//                   }
//
//               case .failure(let error):
//                   print("failed to get messages: \(error)")
//               }
//           }
//       }

       override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           messageInputBar.inputTextView.becomeFirstResponder()

           if let conversationId = conversationId {
//               listenForMessages(id:conversationId, shouldScrollToBottom: true)
           }
       }
   }
   extension chatViewController: InputBarAccessoryViewDelegate {
       func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
           guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = self.selfSender, let messageId = createMessageId()  else {
               return
           }

           print("sending \(text)")

           let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))

           // Send message
           if isNewConversation {
               // create convo in database
               // message ID should be a unique ID for the given message, unique for all the message
               // use random string or random number
//               DBmanger.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] success in
//                   if success {
//                       print("message sent")
//                       self?.isNewConversation = false
//                   }else{
//                       print("failed to send")
//                   }
//               }

           }else {
               guard let conversationId = conversationId, let name = self.title else {
                   return
               }

               // append to existing conversation data
//               DBmanger.shared.sendMessage(to: conversationId, name: name, newMessage: message) { success in
//                   if success {
//                       print("message sent")
//                   }else {
//                       print("failed to send")
//                   }
//               }

           }

       }
       private func createMessageId() -> String? {
           // date, otherUserEmail, senderEmail, randomInt possibly
           // capital Self because its static

           guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
               return nil
           }

           let safeCurrentEmail = DBmanger.shared.safeEmail(email: currentUserEmail)

           let dateString = Self.dateFormatter.string(from: Date())
           let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"


           print("created message id: \(newIdentifier)")
           return newIdentifier

       }
   }
   extension chatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
       func currentSender() -> SenderType {
           // show the chat bubble on right or left?
           if let sender = selfSender {
               return sender
           }
           fatalError("Self sender is nil, email should be cached")
           return Sender(photoURL: "", senderId: "12", displayName: "")

       }

       func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
           return messages[indexPath.section] // message kit framework uses section to separate every single message
           // a message on screen might have mulitple pieces (cleaner to have a single section per message)
       }

       func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
           messages.count
       }


   }
