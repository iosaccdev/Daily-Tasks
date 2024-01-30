//
//  TaskDetailViewController.swift
//  WebviewTestTask
//
//  Created by iosdev on 23.01.2024.
//

import UIKit

protocol TaskDetailDelegate: AnyObject {
    func didAddTask(_ task: String, date: Date?, time: Date?)
    func didUpdateTask(with title: String, date: Date?, time: Date?, for indexPath: IndexPath)
}

final class TaskDetailViewController: UIViewController {
    
    //MARK: - private struct Constants
    private struct Constants {
        static let maxHeightConstant: CGFloat = 100
        static let minHeightConstant: CGFloat = 10
        static let borderWidth = 2.0
        static let cornerRadius: CGFloat = 7
    }
    
    //MARK: - IBOutlets
    @IBOutlet private weak var timeStackView: UIStackView?
    @IBOutlet private weak var dateStackView: UIStackView?
    @IBOutlet private weak var textField: UITextField?
    @IBOutlet private weak var dateSwitch: UISwitch?
    @IBOutlet private weak var timeSwitch: UISwitch?
    @IBOutlet private weak var heightConstraint: NSLayoutConstraint?
    @IBOutlet weak var timeImageView: UIImageView?
    @IBOutlet weak var dateImageView: UIImageView?
    
    //MARK: - Properties
    weak var delegate: TaskDetailDelegate?
    private var datePicker: UIDatePicker?
    private var timePicker: UIDatePicker?
    var selectedTask: Task?
    private var task: Task?
    var cellIndexPath: IndexPath?
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        configureTextField()
        configureStackView()
        
        
        if let selectedTask = selectedTask {
            textField?.text = selectedTask.title
            setInitialPickerValues()
        }
    }
    
    private func setup() {
        dateImageView?.layer.cornerRadius = Constants.cornerRadius
        timeImageView?.layer.cornerRadius = Constants.cornerRadius
        dateSwitch?.isOn = false
        timeSwitch?.isOn = false
    }
    
    // MARK: - UI Configuration
    private func configureTextField() {
        textField?.translatesAutoresizingMaskIntoConstraints = false
        textField?.layer.borderWidth = Constants.borderWidth
        textField?.layer.cornerRadius = Constants.cornerRadius
        textField?.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func configureStackView() {
        dateStackView?.layer.borderWidth = Constants.borderWidth
        dateStackView?.layer.cornerRadius = Constants.cornerRadius
        dateStackView?.layer.borderColor = UIColor.lightGray.cgColor
        timeStackView?.layer.borderWidth = Constants.borderWidth
        timeStackView?.layer.cornerRadius = Constants.cornerRadius
        timeStackView?.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    // MARK: - Date Picker
    private func addDatePicker() {
        DispatchQueue.main.async {
            self.datePicker = UIDatePicker()
            if let datePicker = self.datePicker {
                guard let timeStackView = self.timeStackView else { return }
                guard let dateStackView = self.dateStackView else { return }
                datePicker.datePickerMode = .date
                datePicker.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(datePicker)
                NSLayoutConstraint.activate([
                    datePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    datePicker.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.3),
                    datePicker.topAnchor.constraint(equalTo: dateStackView.bottomAnchor, constant: 2.5),
                    datePicker.bottomAnchor.constraint(equalTo: timeStackView.topAnchor, constant: 6)
                ])
            }
        }
    }
    
    private func hideDatePicker() {
        DispatchQueue.main.async {
            self.datePicker?.removeFromSuperview()
            self.heightConstraint?.constant = Constants.minHeightConstant
        }
    }
    
    // MARK: - Time Picker
    private func setupTimePicker() {
        DispatchQueue.main.async {
            self.timePicker = UIDatePicker()
            if let timePicker = self.timePicker {
                guard let timeStackView = self.timeStackView else { return }
                timePicker.datePickerMode = .time
                timePicker.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(timePicker)
                NSLayoutConstraint.activate([
                    timePicker.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    timePicker.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.2),
                    timePicker.topAnchor.constraint(equalTo: timeStackView.bottomAnchor, constant: 20)
                ])
            }
        }
    }
    
    private func hideTimePicker() {
        DispatchQueue.main.async {
            self.timePicker?.removeFromSuperview()
        }
    }
    
    //MARK: - IBActions
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func dateSwitchTapped(_ sender: Any) {
        guard let dateSwitch = dateSwitch else { return }
            if dateSwitch.isOn {
                heightConstraint?.constant = Constants.maxHeightConstant
                addDatePicker()
            } else {
                hideDatePicker()
            }
    }
    
    @IBAction func timeSwitchTapped(_ sender: Any) {
        guard let timeSwitch = timeSwitch else { return }
        if timeSwitch.isOn {
                setupTimePicker()
            } else {
                hideTimePicker()
            }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            guard let taskName = self.textField?.text, !taskName.isEmpty else { return }
            let selectedDate = self.datePicker?.date
            let selectedTime = self.timePicker?.date
            
            if let task = self.selectedTask {
                guard let cellIndexPath = self.cellIndexPath else { return }
                if let isOnDateSwitch = self.dateSwitch?.isOn, let isOnTimeSwitch = self.timeSwitch?.isOn {
                    if !isOnDateSwitch && !isOnTimeSwitch {
                        self.delegate?.didUpdateTask(with: taskName, date: nil, time: nil, for: cellIndexPath)
                    } else if isOnDateSwitch && isOnTimeSwitch {
                        self.delegate?.didUpdateTask(with: taskName, date: selectedDate, time: selectedTime, for: cellIndexPath)
                    }
                }
            } else {
                if selectedDate != nil && selectedTime != nil {
                    self.delegate?.didAddTask(taskName, date: selectedDate, time: selectedTime)
                    self.dismiss(animated: true)
                } else if selectedDate == nil && selectedTime == nil {
                    self.delegate?.didAddTask(taskName, date: nil, time: nil)
                }
            }
            self.dismiss(animated: true)
        }
    }
    
    private func setInitialPickerValues() {
        if let task = selectedTask {
            if let date = task.date {
                dateSwitch?.isOn.toggle()
                addDatePicker()
                datePicker?.date = date
                heightConstraint?.constant = Constants.maxHeightConstant
            }
            
            if let time = task.time {
                timeSwitch?.isOn.toggle()
                setupTimePicker()
                timePicker?.date = time
            }
        }
    }
}
