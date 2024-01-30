//
//  TaskViewCell.swift
//  WebviewTestTask
//
//  Created by Tania Harbarchuk on 19.01.2024.
//

import UIKit

protocol CheckTableViewCellDelegate: AnyObject {
    func checkTableViewCell(_ cell: TaskViewCell, didChangeCheckedState checked: Bool)
}

protocol TaskViewCellDelegate: AnyObject {
    func didTapInfoButton(for cell: TaskViewCell)
    func didUpdateTaskTitle(_ newTitle: String, for cell: TaskViewCell)
}

final class TaskViewCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var stackView: UIStackView?
    @IBOutlet weak var taskLabel: UILabel?
    @IBOutlet weak var checkBox: CheckBox?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    
    //MARK: - Properties
    weak var delegate: CheckTableViewCellDelegate?
    weak var cellDelegate: TaskViewCellDelegate?
    
    //MARK: - IBAction
    @IBAction func checked(_ sender: CheckBox) {
        guard let checkBox = checkBox else { return }
        updateChecked()
        delegate?.checkTableViewCell(self, didChangeCheckedState: checkBox.checked)
    }
    
    //MARK: - Func set
    func set(title: String, checked: Bool, date: Date?, time: Date?) {
        DispatchQueue.main.async {
            self.taskLabel?.attributedText = NSAttributedString(string: title)
            self.taskLabel?.text = title
            self.checkBox?.checked = checked
            self.updateChecked()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mm a"
            if let date = date, let time = time {
                self.dateLabel?.text = dateFormatter.string(from: date)
                self.timeLabel?.text = timeFormatter.string(from: time)
                if date < Date() && time < Date() {
                    self.dateLabel?.textColor = .red
                    self.timeLabel?.textColor = .red
                } else {
                    self.dateLabel?.textColor = .blue
                    self.timeLabel?.textColor = .blue
                }
            } else {
                self.dateLabel?.text = nil
                self.timeLabel?.text = nil
            }
            self.stackView?.isHidden = date == nil && time == nil
        }
    }
    
    //MARK: - Func updateChecked
    private func updateChecked() {
        DispatchQueue.main.async {
            let attrStr = NSMutableAttributedString(string: self.taskLabel?.text ?? "")
            guard let checkBox = self.checkBox else { return }
            if checkBox.checked {
                attrStr.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attrStr.length))
            } else {
                attrStr.removeAttribute(.strikethroughStyle, range: NSMakeRange(0, attrStr.length))
            }
            self.taskLabel?.attributedText = attrStr
        }
    }
    
    @IBAction func infoButton(_ sender: Any) {
        cellDelegate?.didTapInfoButton(for: self)
    }
    
    func updateTaskTitle(newTitle: String) {
        DispatchQueue.main.async {
            self.taskLabel?.text = newTitle
            self.updateChecked()
            self.cellDelegate?.didUpdateTaskTitle(newTitle, for: self)
        }
    }
}
