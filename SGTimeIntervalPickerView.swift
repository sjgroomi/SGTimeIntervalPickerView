//
//  SGTimeIntervalPickerView.swift
//
//  Created by Stephen Groom on 09/09/2014.
//
//

import UIKit

class SGTimeIntervalPickerView: UIPickerView, UIPickerViewDelegate {
    
    var minimumTimeInterval: NSTimeInterval = 0
    var maximumTimeInterval: NSTimeInterval = 86400
    
    var timeIntervalSelectedClosure: ((timeInterval: NSTimeInterval) -> ())?
    
    //MARK: Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    //MARK: Setup
    
    private func sharedInit() {
        dataSource = self
        delegate = self
    }
    
    //MARK: Selection
    
    func selectTimeInterval(timeInterval: NSTimeInterval, animated: Bool) {
        precondition(timeInterval >= minimumTimeInterval, "Cannot select a time interval which is less than the mimimumTimeInterval")
        precondition(timeInterval <= maximumTimeInterval, "Cannot select a time interval which is greater than the maximumTimeInterval")
        var time = componentsFromTimeInterval(timeInterval)
        selectRow(time.0, inComponent: 0, animated: animated)
        selectRow(time.1, inComponent: 1, animated: animated)
        selectRow(time.2, inComponent: 2, animated: animated)
    }
    
    //MARK: Helpers
    
    private func componentsFromTimeInterval(timeInterval: NSTimeInterval) -> (Int, Int, Int) {
        var time: (Int, Int, Int) = (0, 0, 0)
        
        time.0 = Int(abs(timeInterval/3600))
        time.1 = Int(abs(timeInterval/60 % 60))
        time.2 = Int(abs(timeInterval%60))
        
        return time
    }
    
    private func selectionIsValid(row: Int, component: Int) -> Bool {
        let hours = selectedRowInComponent(0) * 3600
        let minutes = selectedRowInComponent(1) * 60
        let seconds = selectedRowInComponent(2)
        
        var newInterval = 0;
        switch (component) {
        case 0: //Hours
            newInterval = (60 * 60 * row) + minutes + seconds
        case 1: //Minutes
            newInterval = (60 * row) + hours + seconds
        default: //seconds
            newInterval = hours + minutes + row
        }
        return (NSTimeInterval(newInterval) <= maximumTimeInterval)
    }
}

//MARK: Data source
extension SGTimeIntervalPickerView: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let maxTimeIntervalInSeconds = Int(maximumTimeInterval)
        switch (component) {
        case 0: //Hours
            return maxTimeIntervalInSeconds / 3600 + 1
        case 1: //Minutes
            return max(1, min(maxTimeIntervalInSeconds / 60, 60))
        default: //seconds
            return max(1, min(maxTimeIntervalInSeconds, 60))
        }
    }
}

//MARK: Delegate
extension SGTimeIntervalPickerView: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        var period: NSString!
        switch (component) {
        case 0: //Hours
            period = "h"
        case 1: //Minutes
            period = "m"
        default: //seconds
            period = "s"
        }
        let labelString = "\(row) \(period)"
        var label = UILabel(frame: CGRectZero)
        label.text = labelString
        label.textColor = selectionIsValid(row, component: component) ? UIColor.blackColor() : UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        
        return label
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //Check if the selection is valid
        if !selectionIsValid(row, component: component)
        {
            var newRow = row - 1
            while (!selectionIsValid(newRow, component: component))
            {
                newRow--
            }
            pickerView.selectRow(newRow, inComponent: component, animated: true)
            return
        }
        
        let hours = pickerView.selectedRowInComponent(0) * 3600
        let minutes = pickerView.selectedRowInComponent(1) * 60
        let seconds = pickerView.selectedRowInComponent(2)
        let timeInterval: NSTimeInterval = NSTimeInterval(hours + minutes + seconds)
        
        pickerView.reloadAllComponents()
        
        if let closure = timeIntervalSelectedClosure {
            closure(timeInterval: timeInterval)
        }
    }
}
