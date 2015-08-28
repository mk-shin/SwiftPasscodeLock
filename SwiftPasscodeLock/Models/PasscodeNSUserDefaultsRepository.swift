//
//  PasscodeNSUserDefaultsRepository.swift
//  SwiftPasscodeLock
//
//  Created by Nishinobu.Takahiro on 2015/08/16.
//  Copyright (c) 2015年 Yanko Dimitrov. All rights reserved.
//

import Foundation

public class PasscodeNSUserDefaultsRepository: PasscodeRepository {
    
    public var hasPasscode: Bool {
        return getPasscode().count > 0
    }
    
    public var hasPasscodeExpiry: Bool {
        return getExpiryTimeDuration() != nil ? true : false
    }
    
    private let keyName = "swift.passcode.lock"
    private let expiryDurationKeyName = "swift.passcode.lock.expiryDuration"
    private let expiryStartTimeKeyName = "swift.passcode.lock.expiryStartTime"
    
    
    ///////////////////////////////////////////////////////
    // MARK: - Methods
    ///////////////////////////////////////////////////////
    
    public func savePasscode(passcode: [String]) -> Bool {
        NSUserDefaults.standardUserDefaults().setObject(passcode, forKey: keyName)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func updatePasscode(passcode: [String]) -> Bool {
        return savePasscode(passcode)
    }
    
    public func deletePasscode() -> Bool {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(keyName)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func getPasscode() -> [String] {
        return NSUserDefaults.standardUserDefaults().objectForKey(keyName) as? [String] ?? [String]()
    }

    public func saveExpiryTimeDuration(duration: NSTimeInterval) -> Bool {
        
        let value = String(stringInterpolationSegment: duration)
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: expiryDurationKeyName)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func updateExpiryTimeDuration(duration: NSTimeInterval) -> Bool {
        return saveExpiryTimeDuration(duration)
    }
    
    public func deleteExpiryTimeDuration() -> Bool {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(expiryDurationKeyName)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func getExpiryTimeDuration() -> NSTimeInterval? {
        if let duration = NSUserDefaults.standardUserDefaults().stringForKey(expiryDurationKeyName) {
            
            return NSTimeInterval((duration as NSString).doubleValue)
        }
        
        return nil
    }
    
    public func saveExpiryStartTime(time: NSTimeInterval) -> Bool {
        
        let value = String(stringInterpolationSegment: time)
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: expiryStartTimeKeyName)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func updateExpiryStartTime(time: NSTimeInterval) -> Bool {
        
        return saveExpiryStartTime(time)
    }
    
    public func deleteExpiryStartTime() -> Bool {
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(expiryStartTimeKeyName)
        return NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    public func getExpiryStartTime() -> NSTimeInterval? {
        if let time = NSUserDefaults.standardUserDefaults().stringForKey(expiryStartTimeKeyName) {
            
            return NSTimeInterval((time as NSString).doubleValue)
        }
        
        return nil
    }
}
