//
//  LoginCoordinator.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 10/14/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

public final class SimpleFileViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var webView: UIWebView!

    // MARK: - Public properties
    public var didError: ((SimpleFileViewController) -> Void)?
    public var atDocumentEnd: ((SimpleFileViewController) -> Void)?

    public var fileData: Data {
        guard let data = data else {
            // if NSData was not set, try and create one from the URL, otherwise show error and return.
            if let url = url, let URL = URL(string: url), let data = try? Data(contentsOf: URL) {
                return data
            }
            didError?(self)
            return Data()
        }

        return data
    }

    public var numberOfPagesInDocument: CGFloat {
        return round(webView.scrollView.contentSize.height / contentHeight)
    }

    public var numberOfPagesLoaded: CGFloat {
        let preloadOffset: CGFloat = 0.7
        return round((webView.scrollView.contentOffset.y / contentHeight) + preloadOffset)
    }

    // MARK: - Private properties
    private var url: String?
    private var data: Data?
    private var mimeType: MIMEType?
    private var contentHeight: CGFloat {
        var contentHeight = webView.scrollView.frame.size.height
        if UIScreen.main.bounds.width > UIScreen.main.bounds.height {
            // Screen rendered in landscape mode
            contentHeight *= 2
        }
        return contentHeight
    }

    // MARK: - Lifecycle
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public init(load url: String) {
        self.url = url
        super.init(nibName: "SimpleFileViewController", bundle: Bundle(for: SimpleFileViewController.self))
    }

    public init(data: Data, mimeType: MIMEType) {
        self.data = data
        self.mimeType = mimeType
        url = nil
        super.init(nibName: "SimpleFileViewController", bundle: Bundle(for: SimpleFileViewController.self))
    }

    public init(url: String, mimeType: MIMEType) {
        self.url = url
        self.mimeType = mimeType
        data = nil
        super.init(nibName: "SimpleFileViewController", bundle: Bundle(for: SimpleFileViewController.self))
    }

    // MARK: - Overrides
    override public func viewDidLoad() {
        super.viewDidLoad()

        if let mimeType = mimeType?.value {

            // Loading Data
            webView.load(fileData, mimeType: mimeType, textEncodingName: "utf-8", baseURL: URL(fileURLWithPath: ""))

        } else if let myURL = url {

            // Loading Webpage
            guard let URL = URL(string: myURL) else {
                didError?(self)
                return
            }

            webView.loadRequest(URLRequest(url: URL))

        } else {
            didError?(self)
        }

        webView.scalesPageToFit = true
        webView.scrollView.delegate = self
        webView.delegate = self
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    fileprivate func checkIfAtDocumentEnd() {
        if numberOfPagesInDocument == 1 {
            atDocumentEnd?(self)
            return
        }

        if numberOfPagesInDocument == numberOfPagesLoaded {
            atDocumentEnd?(self)
        }
    }
}

extension SimpleFileViewController: UIWebViewDelegate {

    public func webViewDidFinishLoad(_ webView: UIWebView) {
        checkIfAtDocumentEnd()
    }

    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        didError?(self)
    }
}

extension SimpleFileViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkIfAtDocumentEnd()
    }
}
