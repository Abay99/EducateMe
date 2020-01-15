//
//  NotificationCell.swift
//  Steve
//
//  Created by Sudhir Kumar on 18/06/18.
//  Copyright © 2018 Appster. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    // IBOutlets
    @IBOutlet weak var unreadView: UIView!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var notificationTime: UILabel!
    
    // Variables
    
    // MARK: - Initialization
    class var identifier: String {
        return String(describing: self)
    }
    
    class var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    // MARK: - Custom Method
    func configureData(_ notif:NotificationData?) {
        guard let notification = notif else { return }
        //let attributedString = NSMutableAttributedString(attributedString: ("Your application for the job <b>'Notfn 1 electrician kghkjd kjgdfhjk hdfjkghkj dfhgkjdfhgjkdfjk gdfhkjg dfkjg kdfjg kdfjhgkdf kjdf kdf'</b> in the category <b>'Financial Planning'</b> approved by the Employer.").htmlToAttributedString!)
//        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: CustomColor.labelDarkTextColorNoAlpha, range: NSRange(location: 0, length: attributedString.length))
//        attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: Font.MontserratLight, size: 14.0)!, range: NSRange(location: 0, length: attributedString.length))
        self.notificationLabel.text = notification.text ?? ""
        //self.notificationLabel.attributedText = attributedString
        self.notificationTime.text = self.generateTime(str:notification.createdAt ?? "")
        
        if (notification.isRead ?? 0) == 1 {
            self.unreadView.isHidden = true
        } else {
            self.unreadView.isHidden = false
        }
    }
    
    func generateTime(str:String) -> String {
        if str == "" { return ""}
        let curDateStr = "\(Date())"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let curDate = dateFormatter.date(from: curDateStr) ?? Date()
        let notifDate = dateFormatter.date(from: str)
        
        var timeStampString = ""
        if notifDate != nil {
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let strCurDate = dateFormatter.string(from: curDate)
            let strMsgDate = dateFormatter.string(from: notifDate!)
            let newCurDate = dateFormatter.date(from: strCurDate)
            let newMsgDate = dateFormatter.date(from: strMsgDate)
            
            let numberOfDays = self.getNumberOfDays(firstDate: newMsgDate ?? Date(), secondDate: newCurDate ?? Date())
            
            if numberOfDays >= 2 {
                timeStampString = self.getElapsedInterval(firstDate: newMsgDate ?? Date(), secondDate: newCurDate ?? Date())//strMsgDate
            } else if numberOfDays == 1 {
                timeStampString = "Yesterday"
            } else {
                let seconds = curDate.timeIntervalSince(notifDate!)
                timeStampString = self.timeToString(seconds)
            }
        }
        return timeStampString
    }
    
    func getNumberOfDays(firstDate:Date, secondDate:Date) -> Int {
        let calendar = NSCalendar.current
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
    
    func timeToString(_ seconds:TimeInterval) -> String {
        switch seconds {
        case 0..<60 :
            let value = Int(seconds)
            return "\(value) second\(value > 1 ? "s":"") ago"
        case 60..<3600 :
            let value = Int(seconds/60)
            return "\(value) minute\(value > 1 ? "s":"") ago"
        case 3600..<86400 :
            let value = Int(seconds/3600)
            return "\(value) hour\(value > 1 ? "s":"") ago"
        default:
            return "Today"
        }
    }
    
    func getElapsedInterval(firstDate:Date, secondDate:Date) -> String {
        let calendar = NSCalendar.current
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: firstDate)
        let date2 = calendar.startOfDay(for: secondDate)
        let interval = calendar.dateComponents([.year, .month, .day], from: date1, to: date2)
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year" + " ago" :
                "\(year)" + " " + "years" + " ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month" + " ago" :
                "\(month)" + " " + "months" + " ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day" + " ago" :
                "\(day)" + " " + "days" + " ago"
        }
        return ""
    }
}
