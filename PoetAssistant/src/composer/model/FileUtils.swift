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
class FileUtils {
	private init() {
		// Prevent instantiation
	}

	class func deleteAllDocuments() {
		let fileManager = FileManager()
		let documentsFolderUrl = getDocumentFolderUrl()
		let documentsUrls = try! fileManager.contentsOfDirectory(at: documentsFolderUrl, includingPropertiesForKeys: nil, options: [])
		documentsUrls.forEach { url in
			try! fileManager.removeItem(at: url)
		}
	}

	class func buildDocumentUrl(filename: String) -> URL {
		return getDocumentFolderUrl().appendingPathComponent(filename)
	}
	
	private class func getDocumentFolderUrl() -> URL{
		return try! FileManager.default.url(
			for: .documentDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true)
	}

	class func save(url: URL, text: String) {
		if let data = text.data(using: .utf8) {
			do {
				try data.write(to: url)
			} catch let error {
				print ("couldn't save poem to \(url): \(error)")
			}
		}
	}
	
	class func getUsableFilename(userEnteredFilename: String) -> String {
		var result = userEnteredFilename
		
		let range = NSMakeRange(0, result.utf16.count)
		let regex = try! NSRegularExpression(pattern: "[^\\p{L}\\p{N}\\. ]", options: NSRegularExpression.Options.caseInsensitive)
		result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "")
		if result.isEmpty {
			result = "poem"
		}
		if !result.hasSuffix(".txt") {
			result.append(".txt")
		}
		return result
	}
}