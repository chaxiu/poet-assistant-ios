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

import Foundation
import AVFoundation

class Settings {
	public static let MIN_VOICE_SPEED = AVSpeechUtteranceMinimumSpeechRate
	public static let MAX_VOICE_SPEED = AVSpeechUtteranceMaximumSpeechRate
	public static let MIN_VOICE_PITCH = Float(0.5)
	public static let MAX_VOICE_PITCH = Float(2.0)
	private static let KEY_TAB = "tab"
	private static let KEY_LEXICON = "lexicon"
	private static let KEY_SEARCH_HISTORY = "search_history"
	private static let KEY_VOICE_SPEED = "voice_speed"
	private static let KEY_VOICE_PITCH = "voice_pitch"
	
	private static let DEFAULT_VOICE_SPEED = AVSpeechUtteranceDefaultSpeechRate
	private static let DEFAULT_VOICE_PITCH = Float(1.0)
	
	private static let DEFAULT_TAB = Tab.composer
	private static let DEFAULT_LEXICON = Lexicon.rhymer
	
	class func getTab() -> Tab {
		if let tabName = UserDefaults.init().object(forKey: KEY_TAB) as? String {
			if let tab = Tab(rawValue: tabName) {
				return tab
			}
		}
		return DEFAULT_TAB
	}
	
	class func setTab(tab: Tab) {
		let userDefaults = UserDefaults.init()
		userDefaults.setValue(tab.rawValue, forKey: KEY_TAB)
		userDefaults.synchronize()
	}
	
	class func getLexicon() -> Lexicon {
		if let lexiconName = UserDefaults.init().object(forKey: KEY_LEXICON) as? String {
			if let lexicon = Lexicon(rawValue: lexiconName) {
				return lexicon
			}
		}
		return DEFAULT_LEXICON
	}
	
	class func setLexicon(lexicon: Lexicon) {
		let userDefaults = UserDefaults.init()
		userDefaults.setValue(lexicon.rawValue, forKey: KEY_LEXICON)
		userDefaults.synchronize()
	}
	
	class func isSearchHistoryEnabled() ->Bool {
		let userDefaults = UserDefaults.init()
		return userDefaults.bool(forKey: KEY_SEARCH_HISTORY)
	}
	
	class func setSearchHistoryEnabled(enabled: Bool) {
		let userDefaults = UserDefaults.init()
		userDefaults.setValue(enabled, forKey: KEY_SEARCH_HISTORY)
		userDefaults.synchronize()
		if !enabled {
			Suggestion.clearHistory(completion:nil)
		}
	}
	
	class func getVoiceSpeed() -> Float {
		return getFloatPref(key: KEY_VOICE_SPEED, defaultValue: DEFAULT_VOICE_SPEED)
		
	}
	
	class func setVoiceSpeed(speed: Float) {
		setFloatPref(key: KEY_VOICE_SPEED, value: speed)
	}
	
	class func getVoicePitch() -> Float {
		return getFloatPref(key: KEY_VOICE_PITCH, defaultValue: DEFAULT_VOICE_PITCH)
	}
	
	class func setVoicePitch(pitch: Float) {
		setFloatPref(key: KEY_VOICE_PITCH, value: pitch)
	}
	
	private class func getFloatPref(key: String, defaultValue: Float) -> Float {
		let userDefaults = UserDefaults.init()
		if userDefaults.object(forKey: key) == nil {
			userDefaults.setValue(defaultValue, forKey: key)
		}
		return userDefaults.float(forKey: key)
	}
	
	private class func setFloatPref(key: String, value: Float) {
		let userDefaults = UserDefaults.init()
		userDefaults.setValue(value, forKey: key)
		userDefaults.synchronize()
	}
}
