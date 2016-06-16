//
//  CustomPresentationController.swift
//  CustomTransitions
//
//  Created by Sam Warner on 16/06/2016.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation
import UIKit

class CustomPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    var dimmingView: UIView?
    var presentationWrappingView: UIView?
    
    override init(presentedViewController: UIViewController, presenting: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presenting)
        
        presentedViewController.modalPresentationStyle = .custom
    }
    
    override func presentedView() -> UIView? {
        return self.presentationWrappingView
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        let containerViewBounds = self.containerView!.bounds
        let presentedViewContentSize = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerViewBounds.size)
        
        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.origin.y = containerViewBounds.maxY - presentedViewContentSize.height// / 2
        return presentedViewControllerFrame
    }
    
    override func presentationTransitionWillBegin() {
        let presentedViewControllerView = super.presentedView()!
        
        let presentationWrapperView = UIView(frame: self.frameOfPresentedViewInContainerView())
        presentationWrapperView.layer.shadowOpacity = 0.44
        presentationWrapperView.layer.shadowRadius = 13
        presentationWrapperView.layer.shadowOffset = CGSize(width: 0, height: -6)
        self.presentationWrappingView = presentationWrapperView
        
        let cornerRadius = CGFloat(16)
        
        let presentationRoundedCornerView = UIView(frame: UIEdgeInsetsInsetRect(presentationWrapperView.bounds, UIEdgeInsets(top: 0, left: 0, bottom: -cornerRadius, right: 0)))
        presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentationRoundedCornerView.layer.cornerRadius = cornerRadius
        presentationRoundedCornerView.layer.masksToBounds = true
        
        let presentedViewControllerWrapperView = UIView(frame: UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsets(top: 0, left: 0, bottom: cornerRadius, right: 0)))
        presentedViewControllerWrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        presentedViewControllerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds
        presentedViewControllerWrapperView.addSubview(presentedViewControllerView)
        
        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)
        presentationWrapperView.addSubview(presentationRoundedCornerView)
        
        let dimmingView = UIView(frame: self.containerView!.bounds)
        dimmingView.backgroundColor = UIColor.black()
        dimmingView.isOpaque = false
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CustomPresentationController.dimmingViewTapped)))
        self.dimmingView = dimmingView
        self.containerView?.addSubview(dimmingView)
        
        let transitionCoordinator = self.presentingViewController.transitionCoordinator()
        
        self.dimmingView?.alpha = 0
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0.5
        })
    }

    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator()
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0
            })
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.presentationWrappingView = nil
            self.dimmingView = nil
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        if container === self.presentedViewController {
            self.containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if let containerViewController = container as? UIViewController where containerViewController === self.presentedViewController {
            return containerViewController.preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        self.dimmingView?.frame = self.containerView!.bounds
        self.presentationWrappingView?.frame = self.frameOfPresentedViewInContainerView()
    }
    
    @objc func dimmingViewTapped() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext!.isAnimated() ? 0.35 : 0
    }
    
    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        
        let (view, finalFrame) = { () -> (UIView, CGRect) in
            let isPresenting = (fromViewController == self.presentingViewController)
            if isPresenting {
                let toView = transitionContext.view(forKey: UITransitionContextToViewKey)!
                let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
                var toViewInitialFrame = CGRect()//transitionContext.initialFrame(for: toViewController)
                toViewInitialFrame.size = toViewFinalFrame.size
                toViewInitialFrame.origin = CGPoint(x: containerView.bounds.minX, y: containerView.bounds.maxY)
                toView.frame = toViewInitialFrame
                containerView.addSubview(toView)
                return (toView, transitionContext.finalFrame(for: toViewController))
            } else {
                let fromView = transitionContext.view(forKey: UITransitionContextFromViewKey)!
                var fromViewFinalFrame = CGRect()// transitionContext.finalFrame(for: fromViewController)
                fromViewFinalFrame = fromView.frame.offsetBy(dx: 0, dy: fromView.frame.height)
                return (fromView, fromViewFinalFrame)
            }
        }()
        
        let transitionDuration = self.transitionDuration(transitionContext)
        
        UIView.animate(withDuration: transitionDuration, animations: {
            view.frame = finalFrame
        }, completion: { _ in
            let wasCancelled = transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(!wasCancelled)
        })
    }
    
    //MARK: UIViewControllerTransitioningDelegate
    
    func presentationController(forPresentedViewController presented: UIViewController, presenting: UIViewController?, sourceViewController source: UIViewController) -> UIPresentationController? {
        assert(self.presentedViewController == presented)
        return self
    }
    
    func animationController(forPresentedController presented: UIViewController, presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissedController dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
