//
//  TodayViewController.swift
//  PoetAssistantTodayExtension
//
//  Created by Carmen Alvarez on 25/11/2018.
//  Copyright © 2018 Carmen Alvarez. All rights reserved.
//

import UIKit
import NotificationCenter
import PoetAssistantLexiconsFramework

class TodayViewController: UIViewController, NCWidgetProviding {
	@IBOutlet weak var labelTitle: UILabel!
	
	@IBOutlet weak var labelDefinitions: UILabel!
	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var constraintStackViewTop: NSLayoutConstraint!
	@IBOutlet weak var constraintStackViewBottom: NSLayoutConstraint!
	override func viewDidLoad() {
		super.viewDidLoad()
		self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
		let tap = UITapGestureRecognizer(target: self, action: #selector(searchWord))
		labelTitle.isUserInteractionEnabled = true
		labelDefinitions.isUserInteractionEnabled = true
		labelTitle.addGestureRecognizer(tap)
		labelDefinitions.addGestureRecognizer(tap)
	}
	@objc
	func searchWord(sender:UITapGestureRecognizer) {
		print("tap working")
	}
	func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
		if (activeDisplayMode == .compact) {
			self.preferredContentSize = maxSize;
		}
		else {
			resizeToFitWhyDoesntAutoLayoutWork()
		}
	}
	func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
		CoreDataAccess.persistentDictionariesContainer.performBackgroundTask { [weak self] context in
			let wotd = Wotd.getWordOfTheDay(context: context)
			if let wotdDefinitions = Dictionary.fetch(context: context, queryText: wotd)?.getDefinitionsText() {
				DispatchQueue.main.async {
					self?.labelTitle.text = wotd
					var definitions = wotdDefinitions
					definitions.append("line1\nline2\nline3")
					self?.labelDefinitions.text = definitions
					self?.resizeToFitWhyDoesntAutoLayoutWork()
				}
			}
		}
		completionHandler(NCUpdateResult.newData)
	}
	
	private func resizeToFitWhyDoesntAutoLayoutWork() {
		self.preferredContentSize = CGSize(
			width: self.preferredContentSize.width,
			height: getContentHeight())
	}
	
	private func getContentHeight() -> CGFloat {
		var height:CGFloat = 0.0
		stackView.subviews.forEach { subview in
			height += subview.intrinsicContentSize.height
				+ subview.layoutMargins.top
				+ subview.layoutMargins.bottom
		}
		height += constraintStackViewTop.constant + constraintStackViewBottom.constant
		return height
	}
	
}
