/**
 Copyright (c) 2018 Carmen Alvarez

 This file is part of Poet Assistant.

 Poet Assistant is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Poet Assistant is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Poet Assistant.  If not, see <http://www.gnu.org/licenses/>.
*/

import UIKit
import AVFoundation

class ComposerViewController: UIViewController, UITextViewDelegate {
	internal lazy var document: PoemDocument = {
		return PoemDocument.loadSavedPoem()
	}()

	private var keyboardHeight:  CGFloat?
	private var ttsPlayButtonUpdater: TtsPlayButtonConnector?
	
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var text: UITextView! {
		didSet {
			text.delegate = self
		}
	}
	
	@IBOutlet weak var hideKeyboardButton: UIButton!
	@IBOutlet weak var wordCount: UILabel!
	@IBOutlet weak var hint: UILabel!
	@IBOutlet weak var placeholderHeight: NSLayoutConstraint!

	internal let menuItemRhymer = UIMenuItem(title: NSLocalizedString("rhymer", comment:""), action: #selector(menuItemRhymerSelected))
	internal let menuItemThesaurus = UIMenuItem(title: NSLocalizedString("thesaurus", comment:""), action: #selector(menuItemThesaurusSelected))
	internal let menuItemDictionary = UIMenuItem(title: NSLocalizedString("dictionary", comment:""), action: #selector(menuItemDictionarySelected))
	var rtdDelegate : RTDDelegate? = nil
	
	@IBAction func didTapPlayButton(_ sender: UIButton) {
		ttsPlayButtonUpdater?.textToSpeak = getTextToPlay()
		ttsPlayButtonUpdater?.didTapPlayButton()
	}
	private func getTextToPlay() -> String {
		if let selectedRange = text.selectedTextRange {
			if let selectedText = text.text(in:selectedRange) {
				if !selectedText.isEmpty {
					return selectedText
				} else if let rangeFromCursorToEnd = text.textRange(from: selectedRange.start, to: text.endOfDocument) {
					if let textFromCursorToEnd = text.text(in:rangeFromCursorToEnd) {
						if !textFromCursorToEnd.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
							return textFromCursorToEnd
						}
					}
				}
			}
		}
		return text.text
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if (document.documentState == .normal) {
			text.text = document.text
		}
		updateUi()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		ttsPlayButtonUpdater = TtsPlayButtonConnector(playButton: playButton)
		registerForKeyboardNotifications()
		NotificationCenter.default.addObserver(self, selector:#selector(documentStateChanged), name:UIDocument.stateChangedNotification, object:document)
	}

	@objc
	func documentStateChanged(notification: Notification) {
		if (document.documentState.contains(.normal)) {
			text.text = document.text
			updateUi()
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for:segue, sender:sender)
		if segue.identifier == "More" {
			if let moreViewController = segue.destination as? MoreTableViewController {
				moreViewController.delegate = self
				moreViewController.emptyPoem = document.text.isEmpty
				moreViewController.currentPoemFilename = document.fileURL.lastPathComponent
			}
		}
	}

	internal func updateUi() {
		hint.isHidden = !text.text.isEmpty
		updatePlayButton()
		wordCount.text = getWordCountText(text: text.text)
		navigationItem.title = document.localizedName.capitalized
	}
	
	private func updatePlayButton() {
		playButton.isEnabled = !text.text.isEmpty
	}
	
	private func getWordCountText(text: String?) -> String {
		let words = WordCounter.countWords(text:text)
		let characters = WordCounter.countCharacters(text:text)
		if (words == 0) {
			return ""
		}
		return String(format: NSLocalizedString("word_count", comment:""), String(words), String(characters))
	}
	
	func textViewDidChange(_ textView: UITextView) {
		updateUi()
		if (document.documentState == .normal) {
			document.text = text.text
			document.updateChangeCount(.done)
		}
	}
	
	@IBAction func didClickHideKeyboard(_ sender: UIButton) {
		text.endEditing(true)
		setPlaceholderHeight(height: 0.0)
	}
	
	// Adapt the location of the text view when the keyboard appears. Otherwise the keyboard will remain
	// on top of the text view.
	// https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html#//apple_ref/doc/uid/TP40009542-CH5-SW7
	private func registerForKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardWasShown), name:UIResponder.keyboardDidShowNotification, object:nil)
		NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillBeHidden), name:UIResponder.keyboardWillHideNotification, object:nil)
	}
	@objc func keyboardWasShown(notification: Notification) {
		if let kbSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.size {
			if let tabBarHeight = tabBarController?.tabBar.frame.height {
				setPlaceholderHeight(height: kbSize.height - tabBarHeight)
			}
		}
	}
	@objc func keyboardWillBeHidden(notification: Notification) {
		setPlaceholderHeight(height: 0.0)
	}
	private func setPlaceholderHeight(height: CGFloat) {
		placeholderHeight.constant = height
		hideKeyboardButton.isHidden = height <= 0
		DispatchQueue.main.async {
			self.scrollToCursor(keyboardHeight: height)
		}
	}
	
	private func scrollToCursor(keyboardHeight: CGFloat) {
		if let selectedRange = text.selectedTextRange {
			let caretRectInTextView = text.caretRect(for: selectedRange.end)
			let caretRectInRootView = view.convert(caretRectInTextView, from: text)
			
			let visibleTextFrame = text.frame
			if (!visibleTextFrame.contains(caretRectInRootView)) {
				text.scrollRectToVisible(caretRectInTextView, animated: true)
			}
		}
	}
}