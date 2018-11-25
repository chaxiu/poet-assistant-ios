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
import CoreData
import UserNotifications
import PoetAssistantLexiconsFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		Settings.registerDefaults()
		if CommandLine.arguments.contains("UITesting") {
			Settings.clear()
			Suggestion.clearHistory(completion: nil)
			Favorite.clearFavorites {}
			FileUtils.deleteAllDocuments()
		}
		Settings.getTheme().apply()
		UNUserNotificationCenter.current().delegate = self
		return true
	}
	func saveContext () {
		CoreDataAccess.saveContext()
		saveContext(container: AppDelegate.persistentUserDbContainer)
	}
	
	private func saveContext(container: NSPersistentContainer) {
		let context = container.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
	// MARK: - Core Data stack
	static var persistentDictionariesContainer: NSPersistentContainer = {
		return CoreDataAccess.persistentDictionariesContainer
	}()
	
	static var persistentUserDbContainer: NSPersistentContainer = {
		return CoreDataAccess.loadContainer(databaseName: "userdata")
	}()
	
}
