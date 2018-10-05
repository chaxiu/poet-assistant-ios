//
//  TabBarController.swift
//  PoetAssistant
//
//  Created by Carmen Alvarez on 03/10/2018.
//  Copyright © 2018 Carmen Alvarez. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
	
	private var tabToViewController = [Tab:UIViewController]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
		goToTab(tab: Settings.getTab())
	}
	
	override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardVisibilityChanged), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
		preloadTabs()
	}
	
	private func preloadTabs() {
		// Hack to preload tab viewcontrollers
		// https://stackoverflow.com/questions/33261776/how-to-load-all-views-in-uitabbarcontroller
		// If we don't do this, then the first tab we open is behind (not below) the status bar.
		viewControllers?.forEach {
			let _ = $0.view
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	

	func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
		if let tab = getTabForViewController(viewController: viewController) {
			Settings.setTab(tab: tab)
		}
	}
	
	// Make sure keyboard doesn't cover the tab bar, by placing the tab bar above the keyboard,
	// when the keyboard becomes visible.
	// https://stackoverflow.com/questions/5272267/keyboard-hides-tabbar/14782487#14782487
	// https://stackoverflow.com/questions/7842806/check-for-split-keyboard/13495680#13495680
	@objc func keyboardVisibilityChanged(notification: Notification) {
		if let keyboardFrame = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
			let newTabBarY = keyboardFrame.origin.y - tabBar.frame.size.height
			let newTabBarFrame = CGRect(x: tabBar.frame.origin.x, y: newTabBarY, width: tabBar.frame.width, height: tabBar.frame.height)
			if let animationDuration = notification.userInfo?["UIKeyboardAnimationDurationUserInfoKey"] as? Float {
				UIView.animate(withDuration: TimeInterval(animationDuration), animations: { [weak self] in
					self?.tabBar.frame = newTabBarFrame
				})
			}
		}
	}
	
	func goToTab(tab: Tab) {
		for (index, viewController) in viewControllers!.enumerated() {
			if getTabForViewController(viewController: viewController) == tab {
				selectedViewController = viewController
				selectedIndex = index
			}
		}
	}
	
	private func getTabForViewController(viewController: UIViewController) -> Tab? {
		if (viewController is RhymerViewController) {
			return .rhymer
		} else if (viewController is ThesaurusViewController) {
			return .thesaurus
		} else if (viewController is DictionaryViewController) {
			return .dictionary
		} else if (viewController is ComposerViewController){
			return .composer
		}
		return nil
	}
}
