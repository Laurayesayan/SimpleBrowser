//
//  BrowserViewController.swift
//  SimpleBrowser
//
//  Created by Laura Esaian on 01.06.2021.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKUIDelegate {
    // MARK: - UI
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.dataDetectorTypes = [.all]
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.navigationDelegate = self
        
        return webView
    }()
    
    private lazy var searchController: UISearchController = {
        let view = UISearchController(searchResultsController: nil)
        view.searchBar.placeholder = BrowserStrings.searchBarPlaceholder.getString()
        view.searchBar.delegate = self
        view.obscuresBackgroundDuringPresentation = false
        view.searchBar.keyboardAppearance = .alert
        view.hidesNavigationBarDuringPresentation = true
        view.searchBar.searchTextField.textAlignment = .center
        view.searchBar.searchTextField.autocapitalizationType = .none
        view.searchBar.searchTextField.clearButtonMode = .whileEditing
        
        return view
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(progressViewStyle: .bar)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var barItems: [UIBarButtonItem] = {
        var toolBar = [UIBarButtonItem]()
        let goBackItem = UIBarButtonItem(image: BrowserImages.goBack.getImage(),
                                         style: .plain,
                                         target: self,
                                         action: #selector(onBackButtonPressed))
        let goForwardItem = UIBarButtonItem(image: BrowserImages.goForward.getImage(),
                                            style: .plain,
                                            target: self,
                                            action: #selector(onForwardButtonPressed))
        let reloadItem = UIBarButtonItem(barButtonSystemItem: .refresh,
                                         target: self,
                                         action: #selector(onReloadPressed))
        let stopLoading = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(onStopLoadingPressed))
        
        
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        
        toolBar.append(space)
        toolBar.append(goBackItem)
        toolBar.append(space)
        toolBar.append(goForwardItem)
        toolBar.append(space)
        toolBar.append(reloadItem)
        toolBar.append(space)
        toolBar.append(stopLoading)
        toolBar.append(space)
        
        return toolBar
    }()
    
    // MARK: - Private properties
    private var lastScrollYPosition: CGFloat = .zero
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        addObservers()
        loadStartingPage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureNavigationController()
    }
    
    // MARK: - Deinitialization
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), context: nil)
    }
    
    // MARK: - Private methods
    private func setupLayout() {
        view.backgroundColor = .systemBackground
        view.addSubview(webView)
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                                     progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     progressView.bottomAnchor.constraint(equalTo: webView.topAnchor)])
    }
    
    private func configureNavigationController() {
        navigationController?.isToolbarHidden = false
        navigationItem.searchController = searchController
        toolbarItems = barItems
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func addObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
    }
    
    private func hideProgressView(_ state: Bool) {
        if state {
            UIView.animate(withDuration: 0.3, delay: 0.7) { [weak self] in
                self?.progressView.alpha = .zero
            } completion: { [weak self] completed in
                self?.progressView.isHidden = completed
                self?.progressView.progress = .zero
            }
        } else {
            progressView.isHidden = false
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.progressView.alpha = 1.0
            }
        }
    }
    
    private func handleError(_ error: Error?) {
        if let error = error as NSError? {
            let ingoreCode = -999
            if error.code != ingoreCode {
                self.askForAction(title: BrowserStrings.generalError.getString(), message: error.localizedDescription)
            }
            
        }
    }
    
    private func loadStartingPage() {
        if let url = URL(string: BrowserStrings.startingPage.getString()) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    @objc private func onBackButtonPressed() {
        if (webView.canGoBack) {
            webView.goBack()
        }
    }
    
    @objc private func onForwardButtonPressed() {
        if (webView.canGoForward) {
            webView.goForward()
        }
    }
    
    @objc private func onReloadPressed() {
        webView.reload()
    }
    
    @objc private func onStopLoadingPressed() {
        if webView.isLoading {
            webView.stopLoading()
        }
    }
    
    // MARK: Overrided methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        if keyPath == "title" {
            if let title = webView.title {
                searchController.searchBar.text = title
                searchController.searchBar.searchTextField.textAlignment = .center
            }
        }
    }
}

// MARK: - Extensions
extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if progressView.isHidden {
            hideProgressView(false)
        }
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideProgressView(true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error)
        hideProgressView(true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error)
        hideProgressView(true)
    }
}

extension BrowserViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if var text = searchBar.text?.lowercased().trimmingCharacters(in: .whitespaces) {
            if !text.contains("://") {
                text = "https://" + text
            }
            
            if webView.url?.absoluteString == text {
                return
            }
            
            if let targetURL = URL(string: text) {
                webView.load(URLRequest(url: targetURL))
            }
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.searchTextField.textAlignment = .natural
    }
}

extension BrowserViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastScrollYPosition = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){
        let hide = scrollView.contentOffset.y > lastScrollYPosition
        
        navigationController?.setNavigationBarHidden(hide, animated: true)
        navigationController?.setToolbarHidden(hide, animated: true)
    }
}
