//
//  TasksViewController.swift
//  WebviewTestTask
//
//  Created by Tania Harbarchuk on 19.01.2024.
//

import UIKit
import UserNotifications

protocol TasksViewControllerDelegate: AnyObject {
    func didToggleIsCompleteState(with checked: Bool)
}

final class TasksViewController: UIViewController {
    
    private struct Constants {
        static let taskDetailVCID = "TaskDetailViewController"
        static let taskViewCellID = "TaskViewCell"
    }
    
    //MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var exitEditingButton: UIButton?
    
    //MARK: - Properties
    var tasks: [Task] {
        get { return StorageManager.shared.getTasks() }
        set { StorageManager.shared.setTasks(newValue) }
    }
    private var isEditingMode: Bool = false
    private var notifications = LocalNotifications()
    weak var delegate: TasksViewControllerDelegate?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
    }
    
    //MARK: - Func configureTableView()
    private func configureTableView() {
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(with: TaskViewCell.self)
        exitEditingButton?.tintColor = .lightGray
    }
    
    //MARK: - Func updateEditingButtonState
    private func updateEditingButtonState() {
        DispatchQueue.main.async {
            self.exitEditingButton?.isEnabled = self.isEditingMode
            self.exitEditingButton?.tintColor = self.isEditingMode ? .systemBlue : .lightGray
        }
    }
    
    //MARK: - IBActions
    @IBAction func startEditingButton(_ sender: Any) {
        isEditingMode = true
        tableView?.isEditing = true
        updateEditingButtonState()
    }
    
    @IBAction func addButton(_ sender: Any) {
        if let taskDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.taskDetailVCID) as? TaskDetailViewController {
            taskDetailVC.delegate = self
            present(taskDetailVC, animated: true)
        }
    }
    
    @IBAction func doneButton(_ sender: Any) {
        isEditingMode = false
        tableView?.isEditing = false
        updateEditingButtonState()
    }
    
    //MARK: - Func add(task)
    private func add(task: String, date: Date?, time: Date?) {
        var newTask = Task(title: task)
        newTask.date = date
        newTask.time = time
        tasks.append(newTask)
        
        if let taskDate = date, let taskTime = time {
            notifications.scheduleNotification(forTask: newTask, date: taskDate, time: taskTime)
        }
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
}

extension TasksViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: - Func numberOfRowsInSection
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    //MARK: - Func cellForRowAt
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.taskViewCellID, for: indexPath) as? TaskViewCell {
            cell.delegate = self
            cell.cellDelegate = self
            let task = tasks[indexPath.row]
            cell.set(title: task.title, checked: task.isComplete, date: task.date, time: task.time)
            return cell
        }
        return UITableViewCell()
    }
    
    //MARK: - Func editingStyleForRowAt
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    //MARK: - Func commit
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let taskToRemove = tasks[indexPath.row]
            StorageManager.shared.removeTask(withId: taskToRemove.id)
            notifications.cancelNotification(forTask: taskToRemove)
            tasks = StorageManager.shared.getTasks()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    //MARK: - Func moveRowAt
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = tasks.remove(at: sourceIndexPath.row)
        tasks.insert(task, at: destinationIndexPath.row)
    }
}

extension TasksViewController: CheckTableViewCellDelegate {
    func checkTableViewCell(_ cell: TaskViewCell, didChangeCheckedState checked: Bool) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        var task = tasks[indexPath.row]
        task.isComplete = checked
        
        if task.isComplete {
            notifications.cancelNotification(forTask: task)
        }
        tasks[indexPath.row] = task
    }
}

extension TasksViewController: TaskDetailDelegate {
    func didUpdateTask(with title: String, date: Date?, time: Date?, for indexPath: IndexPath) {
        guard indexPath.row < tasks.count else { return }
        var updatedTask = tasks[indexPath.row]
        updatedTask.title = title
        updatedTask.date = date
        updatedTask.time = time
        
        if date == nil && time == nil {
            notifications.cancelNotification(forTask: updatedTask)
        }
        
        if date != nil && time != nil && updatedTask.isComplete {
            notifications.cancelNotification(forTask: updatedTask)
        }
        if date != nil && time != nil && !updatedTask.isComplete {
            guard let date = updatedTask.date, let time = updatedTask.time else { return }
            notifications.scheduleNotification(forTask: updatedTask, date: date, time: time)
        }
        
        tasks[indexPath.row] = updatedTask
        
        DispatchQueue.main.async {
            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didAddTask(_ task: String, date: Date?, time: Date?) {
        add(task: task, date: date, time: time)
    }
}

extension TasksViewController: TaskViewCellDelegate {
    func didUpdateTaskTitle(_ newTitle: String, for cell: TaskViewCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        var updatedTask = tasks[indexPath.row]
        updatedTask.title = newTitle
        tasks[indexPath.row] = updatedTask
    }
    
    func didTapInfoButton(for cell: TaskViewCell) {
        guard let indexPath = tableView?.indexPath(for: cell) else { return }
        let selectedTask = tasks[indexPath.row]
        if let taskDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: Constants.taskDetailVCID) as? TaskDetailViewController {
            taskDetailVC.delegate = self
            taskDetailVC.selectedTask = selectedTask
            taskDetailVC.cellIndexPath = indexPath
            present(taskDetailVC, animated: true)
        }
    }
}
