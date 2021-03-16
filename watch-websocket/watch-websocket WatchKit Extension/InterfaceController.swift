//
//  InterfaceController.swift
//  watch-websocket WatchKit Extension
//
//  Created by momosuke on 2021/03/16.
//

import WatchKit
import Foundation

var webSocketTask: URLSessionWebSocketTask!

class WebSocket: NSObject, URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
//        ping()
//        send()
        receive()
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
    }
}

func ping() {
  webSocketTask.sendPing { error in
    if let error = error {
      print("Error when sending PING \(error)")
    } else {
        print("Web Socket connection is alive")
        DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
            ping()
        }
    }
  }
}

func send() {
    DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
//        send()
        webSocketTask.send(.string("New Message")) { error in
          if let error = error {
            print("Error when sending a message \(error)")
          }
        }
    }
}


func receive() {
  webSocketTask.receive { result in
    switch result {
    case .success(let message):
      switch message {
      case .data(let data):
        print("Data received \(data)")
      case .string(let text):
        print("Text received \(text)")
      }
    case .failure(let error):
      print("Error when receiving \(error)")
    }
    
    receive()
  }
}


class InterfaceController: WKInterfaceController {
    
    @IBAction func buttonTaped() {
        send()
    }
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        let webSocketDelegate = WebSocket()
        let session = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: OperationQueue())
//        let url = URL(string: "wss://echo.websocket.org")!
        let url = URL(string: "wss://morning-citadel-60897.herokuapp.com/")!
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask.resume()

    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
