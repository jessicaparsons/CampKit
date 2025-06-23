//
//  StatusBarView.swift
//  CampKit
//
//  Created by Jessica Parsons on 6/23/25.
//

import SwiftUI

struct StatusBarView<Content: View>: View {
    @ViewBuilder var content: Content
    
    // Status Bar Window
    
    @State private var statusBarWindow: UIWindow?
    
    var body: some View {
        content
            .onAppear {
                if statusBarWindow == nil {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        let statusBarWindow = UIWindow(windowScene: windowScene)
                        statusBarWindow.windowLevel = .statusBar
                        statusBarWindow.tag = 0320
                        let controller = StatusBarViewController()
                        controller.view.backgroundColor = .clear
                        controller.view.isUserInteractionEnabled = false
                        statusBarWindow.rootViewController = controller
                        statusBarWindow.isHidden = false
                        statusBarWindow.isUserInteractionEnabled = false
                        self.statusBarWindow = statusBarWindow
                    }
                }
            }
    }
}

extension UIApplication {
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let statusBarWindow = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first(where: {
            $0.tag == 0320 }), let statusBarController = statusBarWindow.rootViewController as? StatusBarViewController {
            // Updating status bar style
            statusBarController.statusBarStyle = style
            // Refreshing changes
            statusBarController.setNeedsStatusBarAppearanceUpdate()
        }
    }
}




class StatusBarViewController: UIViewController {
    var statusBarStyle: UIStatusBarStyle = .default
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
