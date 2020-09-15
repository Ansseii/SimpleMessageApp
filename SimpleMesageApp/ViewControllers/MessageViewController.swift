//
//  MessageViewController.swift
//  SimpleMesageApp
//
//  Created by BEREZIN Stanislav on 12.09.2020.
//  Copyright © 2020 Aleksandr Lukash. All rights reserved.
//

import UIKit


class MessageViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var inputField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    
    var messages: [Message] = Message.getMessages()
    var profile: Profile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        inputField.delegate = self
        
        tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UITextField.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UITextField.keyboardWillHideNotification,
            object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
        
    }
    
    @IBAction func pressSend() {
        guard let textInField = inputField.text else { return }
        if textInField.isEmpty {
            let message = "The field is empty. Please type message"
            showAlert(title: "Attention", message: message)
        } else {
            let message = Message(text: inputField.text ?? "", person: profile)
            Message.setMessage(message: message)
          
            messages = Message.getMessages()
            inputField.text = ""
            inputField.resignFirstResponder()
            tableView.reloadData()
          
          if let botMessage = Message.getBotMessage(for: message) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
              Message.setMessage(message: botMessage)
              self.messages = Message.getMessages()
              self.tableView.reloadData()
            }
          }
          
        }
    }
}

extension MessageViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        messages[section].person.fullname
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let message = messages[indexPath.section]
        cell.textLabel?.text = message.text
        return cell
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if inputField.frame.origin.y == 0 {
                inputField.frame.origin.y -= keyboardSize.height * 0.75
                sendButton.layer.frame.origin.y -= keyboardSize.height * 0.75
                
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if inputField.frame.origin.y != 0 {
            inputField.frame.origin.y = 0
            sendButton.layer.frame.origin.y = 0
        }
    }
}

extension MessageViewController {
    private func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
}

extension MessageViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension MessageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .systemBlue
    }
}
