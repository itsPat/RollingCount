//
//  ViewController.swift
//  RollingCount
//
//  Created by Pat Trudel on 7/9/22.
//

import UIKit

class ViewController: UIViewController {
    
    var scrollViews = [UIScrollView]()
    var targets = [121_451, 247_219, 361_346, 449_191, 691_451, 778_651]
    var targetIndex = 0 {
        didSet {
            animateToTarget()
        }
    }
    
    var currentTarget: Int {
        targets[targetIndex % targets.count]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollViews.forEach {
            if let stackview = $0.subviews.first as? UIStackView {
                $0.contentSize = stackview.intrinsicContentSize
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        targetIndex += 1
    }
    
    func setupSubviews() {
        let targetAsString = String(currentTarget)
        
        let maxWidth = view.bounds.width - 40
        let maxCharWidth = maxWidth / CGFloat(targetAsString.count)
        
        let scrollViews = (0..<targetAsString.count).map { _ -> UIScrollView in
            makeDigitColumn(maxWidth: maxCharWidth)
        }
        self.scrollViews = scrollViews
        
        guard let anyLabel = (scrollViews.first?.subviews.first as? UIStackView)?.arrangedSubviews.first as? UILabel else { return }
        
        let containerView = UIView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        let hStack = UIStackView(arrangedSubviews: scrollViews)
        hStack.axis = .horizontal
        hStack.distribution = .fillEqually
        hStack.spacing = 0
        hStack.frame = containerView.bounds
        containerView.addSubview(hStack)
        
        hStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: maxWidth),
            containerView.heightAnchor.constraint(equalTo: anyLabel.heightAnchor),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            hStack.topAnchor.constraint(equalTo: containerView.topAnchor),
            hStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            hStack.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            hStack.widthAnchor.constraint(equalTo: anyLabel.widthAnchor, multiplier: CGFloat(targetAsString.count))
        ])
    }
    
    func makeDigitColumn(maxWidth: CGFloat) -> UIScrollView {
        let labels = (0...9).map { index -> UILabel in
            let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxWidth)))
            label.text = "\(index)"
            label.font = .systemFont(ofSize: 72, weight: .black)
            label.textAlignment = .center
            return label
        }
        
        let vStack = UIStackView(arrangedSubviews: labels)
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.distribution = .fillEqually
        
        let scrollView = UIScrollView(frame: .zero)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(vStack)
        
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            vStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            vStack.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            vStack.rightAnchor.constraint(equalTo: scrollView.rightAnchor)
        ])
        return scrollView
    }

    func animateToTarget() {
        let targetAsString = String(currentTarget)
        for (i, c) in targetAsString.enumerated() {
            let scrollView = scrollViews[i]
            guard let stackView = scrollView.subviews.first as? UIStackView else { continue }
            let intValue = Int("\(c)") ?? 0
            let label = stackView.arrangedSubviews[intValue]
            let frame = scrollView.convert(label.frame, to: scrollView)
            UIView.animate(
                withDuration: 1.0,
                delay: Double(i) * 0.1,
                usingSpringWithDamping: 0.75,
                initialSpringVelocity: 0.0,
                options: [.allowAnimatedContent, .allowUserInteraction, .beginFromCurrentState],
                animations: {
                    scrollView.scrollRectToVisible(frame, animated: false)
                },
                completion: nil
            )
        }
    }
    
}

