//
//  DatePickerController.swift
//  StuDo
//
//  Created by Andrew on 9/2/19.
//  Copyright © 2019 Andrew. All rights reserved.
//

import UIKit

class DatePickerController: UIViewController, DimmableController {
    
    var doneCompletionHandler: (() -> Void)?
    
    let animator = SlideUpTransition()
    
    var dimView: UIView!
    var contentView: UIView!
    
    init() {
        self.dimView = UIView()
        self.contentView = UIView()
        
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    let cancelButton = UIButton()
    let doneButton = UIButton()
    
    let datePicker = UIDatePicker()
    let headerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        dimView.backgroundColor = .init(white: 0, alpha: 0.7)
        contentView.backgroundColor = .white
        
        view.addSubview(dimView)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        dimView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        contentView.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        contentView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -8).isActive = true
        headerView.bottomAnchor.constraint(equalTo: datePicker.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        headerView.backgroundColor = .white
        headerView.layer.masksToBounds = true
        headerView.layer.cornerRadius = 8
        
        
        
        
        
        let buttonLeftRightPadding: CGFloat = 20
        
        headerView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: buttonLeftRightPadding).isActive = true
        cancelButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        
        headerView.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -buttonLeftRightPadding).isActive = true
        doneButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true

        
        cancelButton.setTitle(Localizer.string(for: .cancel), for: .normal)
        doneButton.setTitle(Localizer.string(for: .done), for: .normal)

        cancelButton.setTitleColor(.globalTintColor, for: .normal)
        cancelButton.setTitleColor(UIColor.globalTintColor.withAlphaComponent(0.5), for: .highlighted)
        
        doneButton.setTitleColor(.globalTintColor, for: .normal)
        doneButton.setTitleColor(UIColor.globalTintColor.withAlphaComponent(0.5), for: .highlighted)

        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped(_:)), for: .touchUpInside)
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handle(tap:)))
        dimView.addGestureRecognizer(tap)
    }
    
    
    @objc func handle(tap: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    
    

}



extension DatePickerController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = true
        return animator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isPresenting = false
        return animator
    }
}




extension DatePickerController {
    @objc func cancelButtonTapped(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonTapped(_ button: UIButton) {
        doneCompletionHandler?()
        dismiss(animated: true, completion: nil)
    }
}
