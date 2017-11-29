//
//  GestureControl.swift
//  IntervalApp
//
//  Created by Aylwing Olivas on 11/11/17.
//  Copyright © 2017 Interval International. All rights reserved.
//

import UIKit

protocol GestureControlDelegate {
    func gestureControlDidSwipe(_ direction: UISwipeGestureRecognizerDirection)
}

final class GestureControl: UIView {

    // MARK: - Public properties
    let delegate: GestureControlDelegate

    // MARK: - Lifecycle
    init(view: UIView, delegate: GestureControlDelegate) {

        self.delegate = delegate
        super.init(frame: CGRect.zero)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(GestureControl.swipeHandler(_:)))
        swipeLeft.direction = .left
        addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(GestureControl.swipeHandler(_:)))
        swipeRight.direction = .right
        addGestureRecognizer(swipeRight)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        view.addSubview(self)
        [NSLayoutAttribute.left,
         NSLayoutAttribute.right,
         NSLayoutAttribute.top,
         NSLayoutAttribute.bottom].forEach { attribute in
            (view , self) >>>- { $0.attribute = attribute; return }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public functions
    dynamic func swipeHandler(_ gesture: UISwipeGestureRecognizer) {
        delegate.gestureControlDidSwipe(gesture.direction)
    }
}
