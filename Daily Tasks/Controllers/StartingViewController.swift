//
//  StartingViewController.swift
//  TaskManagerApp
//
//  Created by iosdev on 26.01.2024.
//

import UIKit

final class StartingViewController: UIViewController {
    
    //MARK: - private struct Constants
    private struct Constants {
        static let tasksVCID = "TasksViewController"
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var createButton: UIButton?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkTasksState()
        DispatchQueue.main.async {
            self.configureCreateButton()
        }
    }
    
    //MARK: - Func checkTasksState
    private func checkTasksState() {
        if let tasksViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.tasksVCID) as? TasksViewController {
            if tasksViewController.tasks.isEmpty {
                let navigationVC = UINavigationController(rootViewController: self)
                UIApplication.shared.windows.first?.rootViewController = navigationVC
            } else {
                let navigationVC = UINavigationController(rootViewController: tasksViewController)
                UIApplication.shared.windows.first?.rootViewController = navigationVC
            }
        }
    }
    
    //MARK: - Func configureCreateButton
    private func configureCreateButton() {
        createButton?.layer.cornerRadius = 10
    }
}
