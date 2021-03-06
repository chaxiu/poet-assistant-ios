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

import CoreData

public class CoreDataAccess {
	public static let persistentDictionariesContainer: NSPersistentContainer = {
		EmbeddedDb.install()
		return loadContainer(databaseName: "dictionaries")
	}()
	
	private class func loadContainer(databaseName: String) -> NSPersistentContainer {
		// https://stackoverflow.com/questions/42553749/core-data-failed-to-load-model
		guard let modelUrl = Bundle(for: CoreDataAccess.self).url(forResource: "dictionaries", withExtension:"momd") else {
			fatalError("Error loading model from bundle")
		}
		guard let mom = NSManagedObjectModel(contentsOf: modelUrl) else {
			fatalError("Error initializing mom from: \(modelUrl)")
		}
		let container = NSPersistentContainer(name: "dictionaries", managedObjectModel: mom)
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		return container
	}
}
