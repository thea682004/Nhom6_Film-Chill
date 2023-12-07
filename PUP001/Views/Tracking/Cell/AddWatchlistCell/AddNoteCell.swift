//
//  AddNoteCell.swift
//  PUP001
//
//  Created by chuottp on 07/07/2023.
//

import UIKit

protocol AddNoteCellDelegate: AnyObject {
    func getTVTitle() -> String?
    func getTVDescription() -> String?
}

class AddNoteCell: UICollectionViewCell {
    
    weak var delegateAdd: AddNoteCellDelegate?
    weak var delegate: AddWatchlistDelegate?
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCountDescription: UILabel!
    @IBOutlet weak var lblCountTitle: UILabel!
    @IBOutlet weak var btnAdd: UIButton! {
        didSet {
            btnAdd.layer.cornerRadius = 10
            self.btnAdd.alpha = 0.5
            self.btnAdd.isUserInteractionEnabled = false
        }
    }
    @IBOutlet weak var btnCancel: UIButton! {
        didSet {
            btnCancel.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var tvDescription: UITextView! {
        didSet {
            tvDescription.layer.cornerRadius = 10
            tvDescription.delegate = self
            tvDescription.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
        }
    }
    @IBOutlet weak var tvTitle: UITextView! {
        didSet {
            tvTitle.layer.cornerRadius = 10
            tvTitle.delegate = self
            tvTitle.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 0, right: 12)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func getTVTitle() -> String? {
            return tvTitle.text
        }
    
    func getTVDescription() -> String? {
        return tvDescription.text
    }
    
    func configData(item: AddWatchListRealm?) {
        self.tvTitle.text = item?.title
        self.tvDescription.text = item?.descriptionAdd
    }
    
    @IBAction func btnAdd(_ sender: Any) {
        self.delegate?.pushAddSuccess()
        
    }
    
    @IBAction func btnCancle(_ sender: Any) {
        self.delegate?.popVC()
    }
    
}

extension AddNoteCell: UITextViewDelegate {
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.tvTitle.resignFirstResponder()
        self.tvDescription.resignFirstResponder()

    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == tvTitle {
            updateCharacterCountTitle()
        } else if textView == tvDescription {
            updateCharacterCountDescription()
        }
        
        if self.tvTitle.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.btnAdd.alpha = 0.5
            self.btnAdd.isUserInteractionEnabled = false
        } else {
            self.btnAdd.alpha = 1.0
            self.btnAdd.isUserInteractionEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView == tvTitle {
            guard let currentText = self.tvTitle.text else {
                return true
            }
            
            // Tính toán độ dài mới nếu người dùng tiếp tục thay đổi
            let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
            
            // Kiểm tra độ dài newText và giới hạn thành 100 kí tự
            let characterLimit = 100
            lblCountTitle.text = "\(newText.count)/100"
            if newText.count < characterLimit {
                lblCountTitle.textColor = UIColor(rgb: 0x999B9B)
            } else {
                lblCountTitle.textColor = .red
            }
            
            return newText.count < characterLimit
        } else if textView == tvDescription {
            guard let currentText = self.tvDescription.text else {
                return true
            }
            
            // Tính toán độ dài mới nếu người dùng tiếp tục thay đổi
            let newText = (currentText as NSString).replacingCharacters(in: range, with: text)
            
            // Kiểm tra độ dài newText và giới hạn thành 300 kí tự
            let characterLimit = 300
            lblCountDescription.text = "\(newText.count)/300"
            if newText.count < characterLimit {
                lblCountDescription.textColor = UIColor(rgb: 0x999B9B)
            } else {
                lblCountDescription.textColor = .red
            }
            
            return newText.count < characterLimit
        }
        
        return true
    }
    
    
    private func updateCharacterCountTitle() {
        if let text = tvTitle.text {
            lblCountTitle.text = "\(text.count)/100"
            if text.count < 100 {
                lblCountTitle.textColor = UIColor(rgb: 0x999B9B)
            } else {
                lblCountTitle.textColor = .red
            }
        }
    }
    
    private func updateCharacterCountDescription() {
        if let text = tvDescription.text {
            lblCountDescription.text = "\(text.count)/300"
            if text.count < 300 {
                lblCountDescription.textColor = UIColor(rgb: 0x999B9B)
            } else {
                lblCountDescription.textColor = .red
            }
        }
    }
}
