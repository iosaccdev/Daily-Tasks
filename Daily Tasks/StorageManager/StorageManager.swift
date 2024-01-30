//
//  StorageManager.swift
//  WebviewTestTask
//
//  Created by iosdev on 23.01.2024.
//

import Foundation

final class StorageManager {
    static let shared = StorageManager()
    
    private struct UserDefaultsKeys {
        static let tasks = "tasks"
    }
    
    //MARK: - Properties
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    //MARK: - Func create
    private func create(_ object: Any, key: String) {
        userDefaults.setValue(object, forKey: key)
    }
    //MARK: - Func getObject
    private func getObject(forKey key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }
    
    //MARK: - Func setTasks
    func setTasks(_ tasks: [Task]) {
        do {
            let jsonData = try JSONEncoder().encode(tasks)
            create(jsonData, key: UserDefaultsKeys.tasks)
        } catch {
            print("Error encoding tasks: \(error)")
        }
    }
    
    //MARK: - Func getTasks
    func getTasks() -> [Task] {
        guard let data = getObject(forKey: UserDefaultsKeys.tasks) as? Data else {
            return []
        }
        
        do {
            let tasks = try JSONDecoder().decode([Task].self, from: data)
            return tasks
        } catch {
            print("Error decoding tasks: \(error)")
            return []
        }
    }
    
    //MARK: - Func removeTask
    func removeTask(withId taskId: UUID) {
        var tasks = getTasks()
        tasks.removeAll { $0.id == taskId }
        setTasks(tasks)
    }
}
