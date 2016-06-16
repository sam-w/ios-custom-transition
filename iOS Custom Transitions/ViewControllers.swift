//
//  ViewControllers.swift
//  CustomTransitions
//
//  Created by Sam Warner on 16/06/2016.
//  Copyright © 2016 Apple. All rights reserved.
//

import Foundation
import UIKit

class RootViewController: UIViewController {
    
    let button = UIButton()
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(colorLiteralRed: 1, green: 0.5, blue: 0.5, alpha: 1)
        
        button.setTitle("Present", for: [])
        button.setTitle("Presenting", for: .highlighted)
        button.setTitleColor(.black(), for: [])
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        button.addTarget(self, action: #selector(RootViewController.presentModal), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    override func viewDidLayoutSubviews() {
        let superBounds = button.superview!.bounds
        button.center = CGPoint(x: superBounds.midX, y: superBounds.midY)
    }
    
    @objc func presentModal() {
        let presented = PresentedViewController()
        let presentationController = CustomPresentationController(presentedViewController: presented, presenting: self)
        presented.transitioningDelegate = presentationController
        self.present(presented, animated: true, completion: nil)
    }
}

class PresentedViewController: UIViewController {
    
    let slider = UISlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePreferredContentSize(withTraitCollection: self.traitCollection)
        
        self.view.backgroundColor = UIColor(colorLiteralRed: 0.5, green: 0.5, blue: 1, alpha: 1)
        
        slider.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        self.view.addSubview(slider)
        
        slider.addTarget(self, action: #selector(PresentedViewController.sliderChanged), for: .valueChanged)
    }
    
    override func viewDidLayoutSubviews() {
        let superBounds = slider.superview!.bounds
        slider.center = CGPoint(x: superBounds.midX, y: superBounds.maxY - 150)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        self.updatePreferredContentSize(withTraitCollection: newCollection)
    }
    
    func updatePreferredContentSize(withTraitCollection traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: self.view.bounds.width, height: traitCollection.verticalSizeClass == .compact ? 270 : 420)
        
        self.slider.maximumValue = Float(self.preferredContentSize.height)
        self.slider.minimumValue = 220
        self.slider.value = self.slider.maximumValue
    }
    
    @objc func sliderChanged() {
        self.preferredContentSize = CGSize(width: self.view.bounds.width, height: CGFloat(self.slider.value))
    }
}
