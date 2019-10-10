//
//  ViewController.swift
//  topAuth
//
//  Created by Michael L on 08/10/2019.
//  Copyright © 2019 Topco. All rights reserved.
//

import UIKit
import WebKit
import LocalAuthentication

class ViewController: UIViewController, WKNavigationDelegate {

    var wkWebView: WKWebView!
    var vSpinner : UIView?
    
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        notificationCenter.addObserver(self,
                                       selector: #selector(bioAuthAction),
                                       name: Notification.Name("foreground"),
                                       object: nil)
        
        initWebView()
        
        loadUrl(url: "https://www.apple.com")

        bioAuthAction()
    }

    func initWebView() {
        // 전화번호 recognize
        let config = WKWebViewConfiguration()
        config.dataDetectorTypes = .phoneNumber
        wkWebView = WKWebView.init(frame: view.bounds, configuration: config)
        view.addSubview(wkWebView)
        
        wkWebView.frame.origin.x = view.safeAreaInsets.left
        wkWebView.frame.origin.y = UIApplication.shared.statusBarFrame.size.height
        wkWebView.frame.size.width = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        
        // notch 처리하기
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        wkWebView.frame.size.height = view.frame.height - statusBarHeight
        wkWebView.navigationDelegate = self
        wkWebView.allowsBackForwardNavigationGestures = true
        wkWebView.removeGestureRecognizer(UILongPressGestureRecognizer())
    }
    
    func loadUrl(url: String){
        
        print("url \(url)")
        self.removeSpinner()
        let urlRequest = URLRequest(url:URL(string:url)!)
        self.wkWebView.stopLoading()
        self.wkWebView.load(urlRequest)
    }
    
    @objc func bioAuthAction() {
        //init
        loadUrl(url: "https://www.apple.com")
        
        let authContext = LAContext()
        authContext.localizedFallbackTitle = ""
        
        var error: NSError?
        
        var description: String!
        
//        deviceOwnerAuthenticationWithBiometrics
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            switch authContext.biometryType {
            case .faceID:
                description = "계정 정보를 열람하기 위해서 Face ID로 인증 합니다."
                break
            case .touchID:
                description = "계정 정보를 열람하기 위해서 Touch ID로 인증 사용합니다."
                break
            case .none:
                description = "계정 정보를 열람하기 위해서는 로그인하십시오."
                break
            default:
                description = error?.description
                break
            }
            
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description) { (success, error) in
                
                if success {
                    print("인증 성공")
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else {return}
                        self.loadUrl(url: "https://www.naver.com")
                    }
                }
                
                if let error = error {
                   
                    let errorString = error.localizedDescription
                    print("에러 내용::",errorString)
                    
                    if errorString.contains("Canceled by user"){
                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else {return}
                            self.loadUrl(url: "https://www.daum.net")
                        }
                    }else if errorString.contains("Fallback authentication mechanism selected"){
                        exit(0)
                    }else if errorString.contains("Canceled by another authentication"){
                        DispatchQueue.main.async { [weak self] in
                            guard let `self` = self else {return}
                            self.loadUrl(url: "https://www.apple.com")
                        }
                    }
                }
                
            }
            
        }  else {
            // Touch ID・Face ID를 사용할 수없는 경우
            let errorDescription = error?.userInfo["NSLocalizedDescription"] ?? ""
            print(errorDescription)
            description = "계정 정보를 열람하기 위해서는 로그인하십시오."
            
            let alertController = UIAlertController(title: "Authentication Required", message: description, preferredStyle: .alert)
            weak var usernameTextField: UITextField!
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "User ID"
                usernameTextField = textField
            })
            weak var passwordTextField: UITextField!
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                passwordTextField = textField
            })
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Log In", style: .destructive, handler: { action in
                // 를
                print(usernameTextField.text! + "\n" + passwordTextField.text!)
            }))
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("start")
        self.showSpinner(onView: self.view)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish")
        self.removeSpinner()
    }

}

extension ViewController {
  func showSpinner(onView : UIView) {
      let spinnerView = UIView.init(frame: onView.bounds)
      spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
      let ai = UIActivityIndicatorView.init(style: .whiteLarge)
      ai.startAnimating()
      ai.center = spinnerView.center
      
      DispatchQueue.main.async {
          spinnerView.addSubview(ai)
          onView.addSubview(spinnerView)
      }
      
      vSpinner = spinnerView
  }
  
  func removeSpinner() {
      DispatchQueue.main.async {
        self.vSpinner?.removeFromSuperview()
        self.vSpinner = nil
      }
  }
}


