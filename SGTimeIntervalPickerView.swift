//
//  SGTimeIntervalPickerView.swift
//
//  Created by Stephen Groom on 09/09/2014.
//
//

import UIKit

protocol SGTimeIntervalPickerViewDelegate: NSObjectProtocol {
    func pickerView(pickerView: UIPickerView, didSelectTimeInterval: NSTimeInterval)
}

class SGTimeIntervalPickerView: UIPickerView, UIPickerViewDelegate {
    
    weak var timeIntervalDelegate: SGTimeIntervalPickerViewDelegate?
    
    var minimumTimeInterval: NSTimeInterval = 0
    
    var _maximumTimeInterval: NSTimeInterval = 86400
    var maximumTimeInterval: NSTimeInterval{
        set(timeInterval) {
            _maximumTimeInterval = min(timeInterval, 86400)
        }
        get {
            return _maximumTimeInterval
        }
    }
    
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
    
    func sharedInit() {
        dataSource = self
        delegate = self
    }
    
    //MARK: Helpers
    
    func selectionIsValid(row: Int, component: Int) -> Bool {
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
            return min(maxTimeIntervalInSeconds / 60, 60)
        default: //seconds
            return min(maxTimeIntervalInSeconds, 60)
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
        
        if let unDelegate = timeIntervalDelegate {
            unDelegate.pickerView(pickerView, didSelectTimeInterval: timeInterval)
        }
    }
}