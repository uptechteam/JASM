//
//  SideMenuController.swift
//  SideMenu
//
//  Created by Евгений Матвиенко on 11/14/16.
//  Copyright © 2016 SilverDefender. All rights reserved.
//

import UIKit

public class SideMenuController: UIViewController {
    
    // MARK: - Public Properties
    
    /// What width will be side menu relative to SideMenuController view width.
    public var menuWidthRatio           : CGFloat = 0.8
    
    /// Minimum velocity to open or close side menu.
    public var minimumXVelocity         : CGFloat = 1000
    
    /// Minimum translation to open or close side menu relative to SideMenuController view width.
    public var minimumXTranslationRatio : CGFloat = 0.3
    
    /// An array of root view controllers that will be presented.
    public var viewControllers          : [UIViewController] = []
    
    // MARK: - Private Properties
    
    fileprivate let menuContainerViewController : UIViewController
    fileprivate let frontContainerViewController: UIViewController
    
    fileprivate var menuContainerView   : UIView { return menuContainerViewController.view }
    fileprivate var frontContainerView  : UIView { return frontContainerViewController.view }
    fileprivate let invisibleFrontView  : UIView
    
    fileprivate var menuViewController  : UIViewController?
    fileprivate var frontViewController : UIViewController?
    
    fileprivate var menuView    : UIView? { return menuViewController?.view }
    fileprivate var frontView   : UIView? { return frontViewController?.view }
    
    fileprivate var isMenuShown = false
    
    fileprivate var frontContainerViewFrameBeforePanning: CGRect?
    
    fileprivate let frontViewPanGestureRecognizer       : UIPanGestureRecognizer
    fileprivate let invisibleViewPanGestureRecognizer   : UIPanGestureRecognizer
    
    // MARK: - Lifecycle
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        // Containers
        menuContainerViewController     = UIViewController()
        frontContainerViewController    = UIViewController()
        
        // Views
        invisibleFrontView = UIView()
        
        // Gesture Recognizers
        frontViewPanGestureRecognizer       = UIPanGestureRecognizer()
        invisibleViewPanGestureRecognizer   = UIPanGestureRecognizer()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // Containers Configuration
        addChildViewController(menuContainerViewController)
        view.addSubview(menuContainerView)
        menuContainerViewController.didMove(toParentViewController: self)
        menuContainerView.frame = view.bounds
        
        addChildViewController(frontContainerViewController)
        view.addSubview(frontContainerView)
        frontContainerViewController.didMove(toParentViewController: self)
        frontContainerView.frame = view.bounds
        
        invisibleFrontView.frame = frontContainerView.bounds
        invisibleFrontView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:))))
        invisibleFrontView.addGestureRecognizer(invisibleViewPanGestureRecognizer)
        frontContainerView.addSubview(invisibleFrontView)
        invisibleFrontView.alpha = 0
        
        // Gesture Recognizer Targets
        frontViewPanGestureRecognizer.addTarget(self, action: #selector(self.handlePanGestureRecognizer(_:)))
        invisibleViewPanGestureRecognizer.addTarget(self, action: #selector(self.handlePanGestureRecognizer(_:)))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Inputs
    
    /// Method to set view controller as menu view controller.
    ///
    /// - parameter menuViewController: View controller for menu.
    public func set(menuViewController: UIViewController) {
        if let oldMenuViewController = self.menuViewController {
            remove(menuViewController: oldMenuViewController)
        }
        
        self.menuViewController = menuViewController
        add(menuViewController: menuViewController)
    }
    
    /// Method to present view controller from viewControllers array.
    ///
    /// - parameter index:    Index of view controller from viewControllers array.
    /// - parameter animated: Is animated present.
    public func present(viewControllerAtIndex index: Int, animated: Bool = true) {
        let viewController = viewControllers[index]
        if let oldFrontViewController = frontViewController {
            remove(viewController: oldFrontViewController)
        }
        
        self.frontViewController = viewController
        add(viewController: viewController)
        
        toggleMenu(on: false, animated: animated)
    }
    
    /// Method to toggle menu.
    ///
    /// - parameter on:       Show or hide.
    /// - parameter animated: Is animated.
    public func toggleMenu(on: Bool, animated: Bool) {
        isMenuShown = on
        invisibleFrontView.alpha = on ? 1 : 0
        updateFrontContainerViewFrame(animated: animated)
    }
    
    // MARK: - Internal Helpers
    
    private func add(menuViewController: UIViewController) {
        menuViewController.willMove(toParentViewController: menuContainerViewController)
        self.addChildViewController(menuViewController)
        menuContainerView.addSubview(menuViewController.view)
        menuViewController.view.frame = menuContainerView.bounds
        menuViewController.didMove(toParentViewController: menuContainerViewController)
    }
    
    private func remove(menuViewController: UIViewController) {
        menuViewController.willMove(toParentViewController: nil)
        menuViewController.view.removeFromSuperview()
        menuViewController.removeFromParentViewController()
        menuViewController.didMove(toParentViewController: nil)
    }
    
    private func add(viewController: UIViewController) {
        viewController.willMove(toParentViewController: frontContainerViewController)
        frontContainerViewController.addChildViewController(viewController)
        frontContainerView.insertSubview(viewController.view, at: 0)
        viewController.view.frame = frontContainerView.bounds
        viewController.didMove(toParentViewController: frontContainerViewController)
        viewController.view.addGestureRecognizer(frontViewPanGestureRecognizer)
    }
    
    private func remove(viewController: UIViewController) {
        viewController.view.removeGestureRecognizer(frontViewPanGestureRecognizer)
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
        viewController.didMove(toParentViewController: nil)
    }

    fileprivate func updateFrontContainerViewFrame(animated: Bool) {
        let frontContainerViewFrame = !isMenuShown ?
            CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height) :
            CGRect(x: view.frame.width * menuWidthRatio, y: 0, width: view.frame.width, height: view.frame.height)
        
        let animate = {
            self.frontContainerView.frame = frontContainerViewFrame
        }
        
        guard animated else {
            animate()
            return
        }
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            animate()
            }, completion: nil)
    }
    
    fileprivate func shouldToggleMenu(translation: CGPoint, velocity: CGPoint) -> Bool {
        let minimumXTranslation : CGFloat = view.frame.width * minimumXTranslationRatio
    
        if !isMenuShown {
            if translation.x >= minimumXTranslation || velocity.x >= minimumXVelocity {
                return true
            }
        } else {
            if translation.x <= -minimumXTranslation || velocity.x <= -minimumXVelocity {
                return true
            }
        }
        
        return false
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        frontViewPanGestureRecognizer.isEnabled = false
        invisibleViewPanGestureRecognizer.isEnabled = false
        frontViewPanGestureRecognizer.isEnabled = true
        invisibleViewPanGestureRecognizer.isEnabled = true
        
        menuContainerView.frame     = view.bounds
        frontContainerView.frame    = view.bounds
        menuView?.frame             = view.bounds
        frontView?.frame            = view.bounds
        invisibleFrontView.frame    = view.bounds
        isMenuShown                 = false
    }
    
}

// MARK: - Pan Gesture Recognizer Handling

extension SideMenuController {
    func handlePanGestureRecognizer(_ gr: UIPanGestureRecognizer) {
        switch gr.state {
        case .began:
            panGestureBegan(gr)
        case .changed:
            panGestureChanged(gr)
        case .ended:
            panGestureEnded(gr)
        default:
            break
        }
    }
    
    private func panGestureBegan(_ gr: UIPanGestureRecognizer) {
        frontContainerViewFrameBeforePanning = frontContainerView.frame
    }
    
    private func panGestureChanged(_ gr: UIPanGestureRecognizer) {
        guard let frontContainerViewFrameBeforePanning = frontContainerViewFrameBeforePanning else { return }
        
        let translation = gr.translation(in: view)
        
        let newFrontContainerViewOriginX = max(0, frontContainerViewFrameBeforePanning.origin.x + translation.x)
        
        let newFrontContainerViewOrigin = CGPoint(
            x: newFrontContainerViewOriginX,
            y: frontContainerViewFrameBeforePanning.origin.y
        )
        
        frontContainerView.frame = CGRect(
            origin: newFrontContainerViewOrigin,
            size: frontContainerViewFrameBeforePanning.size
        )
    }
    
    private func panGestureEnded(_ gr: UIPanGestureRecognizer) {
        let velocity = gr.velocity(in: view)
        let translation = gr.translation(in: view)
        
        let shouldToggleMenu = self.shouldToggleMenu(translation: translation, velocity: velocity)
        let toggleMenuOn = (!isMenuShown && shouldToggleMenu) || (isMenuShown && !shouldToggleMenu)
        toggleMenu(on: toggleMenuOn, animated: true)
    }
    
}

// MARK: - Tap Gesture Recognizer Handling

extension SideMenuController {
    func handleTapGestureRecognizer(_ gr: UITapGestureRecognizer) {
        toggleMenu(on: false, animated: true)
    }
    
}

// MARK: - UIViewController Extension

public extension UIViewController {
    
    /// Associated side menu controller.
    var sideMenuController: SideMenuController? {
        guard let sideMenuController = parent as? SideMenuController else {
            return parent?.sideMenuController
        }
        
        return sideMenuController
    }
    
}
