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
import CoreData
import PoetAssistantLexiconsFramework

enum SuggestionListItem {
	case random_word
	case clear_history
	case history_suggestion(String)
	case dictionary_suggestion(String)
}

class SuggestionsFetchedResultsControllerWrapper {
	private var historyFetchedResultsController: NSFetchedResultsController<Suggestion>?
	private var dictionaryFetchedResultsController: NSFetchedResultsController<NSDictionary>?
	private static let SECTION_SUGGESTIONS = "suggestions_section_suggestions"
	private static let SECTION_HISTORY = "suggestions_section_history"
	private static let SECTION_DICTIONARY = "suggestions_section_dictionary"
	private let queryText: String?
	
	init(queryText: String?) {
		self.queryText = queryText
	}
	var sections = [NSFetchedResultsSectionInfo]()
	
	func object(at: IndexPath) -> SuggestionListItem {
		let sectionName = sections[at.section].name
		if sectionName == SuggestionsFetchedResultsControllerWrapper.SECTION_SUGGESTIONS {
			return sections[0].objects![0] as! SuggestionListItem
		} else if sectionName == SuggestionsFetchedResultsControllerWrapper.SECTION_HISTORY {
			if at.row == ((historyFetchedResultsController?.sections?[0].numberOfObjects ?? 0)) {
				return SuggestionListItem.clear_history
			} else {
				let historySuggestion = historyFetchedResultsController?.object(at: IndexPath(row: at.row, section: 0))
				return SuggestionListItem.history_suggestion(historySuggestion?.word ?? "")
			}
		} else {
			let dictionarySuggestion = dictionaryFetchedResultsController?.object(at: IndexPath(row: at.row, section: 0))
			return SuggestionListItem.dictionary_suggestion(dictionarySuggestion?[#keyPath(PoetAssistantLexiconsFramework.Dictionary.word)] as? String ?? "")
		}
	}
	
	func performFetch(completion: @escaping () -> Void) {
		
		let historyContext = AppDelegate.persistentUserDbContainer.newBackgroundContext()
		let dictionaryContext = AppDelegate.persistentDictionariesContainer.newBackgroundContext()
		DispatchQueue.global().async { [weak self] in
			if (Settings.isSearchHistoryEnabled()) {
				self?.historyFetchedResultsController = Suggestion.createHistorySearchSuggestionsFetchResultsController(context: historyContext, queryText: self?.queryText)
			}
			self?.dictionaryFetchedResultsController = (self?.queryText == nil || self!.queryText!.isEmpty) ? nil :  Suggestion.createSearchSuggestionsFetchResultsController(context: dictionaryContext, queryText: self!.queryText!)
			do {
				try self?.historyFetchedResultsController?.performFetch()
				try self?.dictionaryFetchedResultsController?.performFetch()
				self?.sections.append(SectionInfo(
					name: SuggestionsFetchedResultsControllerWrapper.SECTION_SUGGESTIONS,
					numberOfObjects: 1,
					objects: [SuggestionListItem.random_word]))
				if let historySearchSections = self?.historyFetchedResultsController?.sections, historySearchSections.count == 1, historySearchSections[0].numberOfObjects > 0 {
					var historySearchObjects = [Any]()
					// TODO sometimes we crash in the following line with Thread 5: EXC_BAD_ACCESS (code=1, address=0x5682470ff818
					// historySearchObjects is empty, historySearchSections has one item
					// we're in a background thread.
					// Another thread is just above in the if let condition
					historySearchObjects += historySearchSections[0].objects ?? []
					historySearchObjects += [SuggestionListItem.clear_history]
					self?.sections.append(SectionInfo(
						name: SuggestionsFetchedResultsControllerWrapper.SECTION_HISTORY,
						numberOfObjects: historySearchObjects.count,
						objects: historySearchObjects))
				}
				if let dictionarySearchSections = self?.dictionaryFetchedResultsController?.sections, dictionarySearchSections.count == 1 {
					self?.sections.append(SectionInfo(
						name: SuggestionsFetchedResultsControllerWrapper.SECTION_DICTIONARY,
						numberOfObjects: dictionarySearchSections[0].numberOfObjects,
						objects: dictionarySearchSections[0].objects))
				}
				DispatchQueue.main.async(execute:completion)
			} catch let error {
				print ("Error loading suggestions \(error)")
			}
			DispatchQueue.main.async(execute:completion)
		}
	}
}
