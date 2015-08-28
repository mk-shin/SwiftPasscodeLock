//
//  PasscodeKeychainRepository.swift
//  SwiftPasscodeLock
//
//  Created by Yanko Dimitrov on 11/16/14.
//  Copyright (c) 2014 Yanko Dimitrov. All rights reserved.
//

import Foundation

public class PasscodeKeychainRepository: PasscodeRepository {
    
    public var hasPasscode: Bool {
        return getPasscode().count > 0
    }
    
    public var hasPasscodeExpiry: Bool {
        return getExpiryTimeDuration() != nil ? true : false
    }
    
    private let keychain: KeychainService
    private let keyName = "passcode"
    private let expiryDurationKeyName = "passcodeExpiryDuration"
    private let expiryStartTimeKeyName = "passcodeExpiryStartTime"
    
    ///////////////////////////////////////////////////////
    // MARK: - Initializers
    ///////////////////////////////////////////////////////
    
    init(keychainService: KeychainService) {
        
        keychain = keychainService
    }
    
    convenience init() {
        
        let keychain = Keychain(serviceName: "swift.passcode.lock", accessMode: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
        
        self.init(keychainService: keychain)
    }
    
    ///////////////////////////////////////////////////////
    // MARK: - Methods
    ///////////////////////////////////////////////////////
    
    public func savePasscode(passcode: [String]) -> Bool {
        
        let passcodeKey = ArchiveKey(keyName: keyName, object: passcode)
        
        if let error = keychain.add(passcodeKey) {
            
            return false
        }
        
        return true
    }
    
    public func updatePasscode(passcode: [String]) -> Bool {
        
        let passcodeKey = ArchiveKey(keyName: keyName, object: passcode)
        
        if let error = keychain.update(passcodeKey) {
            
            return false
        }
        
        return true
    }
    
    public func deletePasscode() -> Bool {
        
        let passcodeKey = ArchiveKey(keyName: keyName)
        
        if let error = keychain.remove(passcodeKey) {
            
            return false
        }
        
        return true
    }
    
    public func getPasscode() -> [String] {
        
        var passcodeStack = [String]()
        let passcodeKey = ArchiveKey(keyName: keyName)
        
        if let passcode = keychain.get(passcodeKey).item?.object as? NSArray {
            
            for item in passcode {
                let sign = item as! String
                
                passcodeStack.append(sign)
            }
        }
        
        return passcodeStack
    }
    
    public func saveExpiryTimeDuration(duration: NSTimeInterval) -> Bool {
        
        let value = String(stringInterpolationSegment: duration)
        let passcodeExpiryTimeDurationKey = GenericKey(keyName: expiryDurationKeyName, value: value)
        
        if let error = keychain.add(passcodeExpiryTimeDurationKey) {
            
            return false
        }
        
        return true
    }
    
    public func updateExpiryTimeDuration(duration: NSTimeInterval) -> Bool {
        
        let value = String(stringInterpolationSegment: duration)
        let passcodeExpiryTimeDurationKey = GenericKey(keyName: expiryDurationKeyName, value: value)
        
        if let error = keychain.update(passcodeExpiryTimeDurationKey) {
            
            return false
        }
        
        return true
    }
    
    public func deleteExpiryTimeDuration() -> Bool {
        
        let passcodeExpiryTimeDurationKey = GenericKey(keyName: expiryDurationKeyName)
        
        if let error = keychain.remove(passcodeExpiryTimeDurationKey) {
            
            return false
        }
        
        return true
    }
    
    public func getExpiryTimeDuration() -> NSTimeInterval? {
        
        let passcodeExpiryTimeDurationKey = GenericKey(keyName: expiryDurationKeyName)
        
        if let duration = keychain.get(passcodeExpiryTimeDurationKey).item?.value as? String {
            
            return NSTimeInterval((duration as NSString).doubleValue)
        }
        
        return nil
    }
    
    public func saveExpiryStartTime(time: NSTimeInterval) -> Bool {
        
        let value = String(stringInterpolationSegment: time)
        let passcodeExpiryStartTimeKey = GenericKey(keyName: expiryStartTimeKeyName, value: value)
        
        if let error = keychain.add(passcodeExpiryStartTimeKey) {
            
            return false
        }
        
        return true
    }
    
    public func updateExpiryStartTime(time: NSTimeInterval) -> Bool {
        
        let value = String(stringInterpolationSegment: time)
        let passcodeExpiryStartTimeKey = GenericKey(keyName: expiryStartTimeKeyName, value: value)
        
        if let error = keychain.update(passcodeExpiryStartTimeKey) {
            
            return false
        }
        
        return true
    }
    
    public func deleteExpiryStartTime() -> Bool {
        
        let passcodeExpiryStartTimeKey = GenericKey(keyName: expiryStartTimeKeyName)
        
        if let error = keychain.remove(passcodeExpiryStartTimeKey) {
            
            return false
        }
        
        return true
    }
    
    public func getExpiryStartTime() -> NSTimeInterval? {
        
        let passcodeExpiryStartTimeKey = GenericKey(keyName: expiryStartTimeKeyName)
        
        if let time = keychain.get(passcodeExpiryStartTimeKey).item?.value as? String {
            
            return NSTimeInterval((time as NSString).doubleValue)
        }
        
        return nil
    }
}
