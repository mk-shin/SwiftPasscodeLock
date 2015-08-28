//
//  PasscodeLockPresenter.swift
//  SwiftPasscodeLock
//
//  Created by Yanko Dimitrov on 11/26/14.
//  Copyright (c) 2014 Yanko Dimitrov. All rights reserved.
//

import UIKit

public class PasscodeLockPresenter: NSObject {
    
    public weak var window: UIWindow?
    private let passcodeViewController: UIViewController
    private let passcodeRepository: PasscodeRepository
    private let splashView: UIView
    public var isPasscodePresented = false
    private var isFreshAppLaunch = true
    
    ///////////////////////////////////////////////////////
    // MARK: - Initializers
    ///////////////////////////////////////////////////////
    
    public init(passcodeViewController: UIViewController, repository: PasscodeRepository, splashView: UIView) {
        
        assert(passcodeViewController is PasscodeLockPresentable, "Passcode VC should conform to PasscodeLockPresentable")
        
        self.passcodeViewController = passcodeViewController
        self.passcodeRepository = repository
        self.splashView = splashView
        
        super.init()
        
        if let presented = passcodeViewController as? PasscodeLockPresentable {
            
            presented.onCorrectPasscode = {
                
                self.dismissPasscodeLock()
            }
        }
        
        addEvents()
    }
    
    deinit {
        
        removeEvents()
    }
    
    ///////////////////////////////////////////////////////
    // MARK: - Methods
    ///////////////////////////////////////////////////////
    
    private func addEvents() {
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.addObserver(
            self,
            selector: Selector("applicationDidEnterBackground"),
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil
        )
        
        center.addObserver(
            self,
            selector: Selector("applicationDidLaunched"),
            name: UIApplicationDidFinishLaunchingNotification,
            object: nil
        )
        
        center.addObserver(
            self,
            selector: Selector("applicationDidBecomeActive"),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil
        )
    }
    
    private func removeEvents() {
        
        let center = NSNotificationCenter.defaultCenter()
        
        center.removeObserver(self)
    }
    
    func applicationDidEnterBackground() {
        
        if passcodeRepository.hasPasscodeExpiry {
            // if passcode is forced displayed already then do not set the expiry start time,
            // so as it is not closed when app moves in foreground again
            if isPasscodePresented {
                passcodeRepository.deleteExpiryStartTime()
            } else {
                passcodeRepository.saveExpiryStartTime(NSDate().timeIntervalSinceReferenceDate)
            }
        }
        
        addSplashView()
        presentPasscodeLock(splashViewAnimated: false)
    }
    
    func applicationDidLaunched() {

        presentPasscodeLock(splashViewAnimated: false)
    }
    
    func applicationDidBecomeActive() {
        
        // we don't want two PasscodeViewController to be displayed together
        // developer can easily handle the success handler for both
        if let topController = findTopMostControllerInWindow(window)
            where topController is PasscodeViewController && topController !== passcodeViewController
        {
            self.removeSplashView()
        }
        
        // if passcode is presented but not expired then dismiss the view
        if !isFreshAppLaunch && isPasscodePresented && passcodeRepository.hasPasscodeExpiry && !isPasscodeExpired() {
            dismissPasscodeLock(animated: false)
        }
        
        if isFreshAppLaunch {
            isFreshAppLaunch = false
        }
    }
    
    public func isPasscodeExpired() -> Bool {
        
        if let
            startTime = passcodeRepository.getExpiryStartTime(),
            duration = passcodeRepository.getExpiryTimeDuration()
        {
            let now = NSDate().timeIntervalSinceReferenceDate
            
            if now - startTime >= duration {
                
                return true
            }
            
            return false
        }
        
        // default is true (means expired), so even when this feature is disabled it does not affect the flow
        return true
    }
    
    private func shouldPresentPasscodeLock() -> Bool {
        
        if passcodeRepository.hasPasscode && !isPasscodePresented {
            
            return true
        }
        
        return false
    }
    
    private func findTopMostControllerInWindow(window: UIWindow?) -> UIViewController? {
        
        var topController: UIViewController?
        
        if let mainWindow = window {
            
            topController = mainWindow.rootViewController
        
            while topController?.presentedViewController != nil {
            
                topController = topController?.presentedViewController
            }
        }
        
        return topController
    }
    
    private func presentPasscodeLock(#splashViewAnimated: Bool) {
        
        if !shouldPresentPasscodeLock() {
            
            return
        }
        
        let topController = findTopMostControllerInWindow(window)
        
        // Trying to present passcode view controller on top of the same view controller
        // no need to do that
        if topController is PasscodeViewController {

            return
        }
        
        if splashViewAnimated {
            
            topController?.presentViewController(passcodeViewController, animated: false, completion: nil)
            
            animateSplashView({
                
                self.removeSplashView()
            })
            
        } else {
            
            topController?.presentViewController(passcodeViewController, animated: false, completion: {
                
                self.removeSplashView()
            })
        }
        
        isPasscodePresented = true
    }
    
    private func dismissPasscodeLock() {
        
        passcodeViewController.dismissViewControllerAnimated(true, completion: nil)
        
        self.isPasscodePresented = false
    }
    
    private func updateSplashViewFrame() {
        
        let screenBounds = UIScreen.mainScreen().bounds
        let device = UIDevice.currentDevice()
        
        splashView.frame = screenBounds
        
        if device.userInterfaceIdiom == .Phone && screenBounds.width > screenBounds.height {
            
            splashView.frame = CGRectMake(0, 0, screenBounds.height, screenBounds.width)
        }
    }
    
    private func addSplashView() {
        
        if !shouldPresentPasscodeLock() {
            
            return
        }
        
        updateSplashViewFrame()
        
        window?.addSubview(splashView)
    }
    
    private func removeSplashView() {
        
        splashView.removeFromSuperview()
    }
    
    private func animateSplashView(complete: () -> Void) {
        
        UIView.animateWithDuration(
            0.3,
            delay: 0.2,
            options: nil,
            animations: {
                
                self.splashView.alpha = 0
                
            }, completion: {
                finished in
                
                complete()
                self.splashView.alpha = 1
            }
        )
        
    }
}
