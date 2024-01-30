//
//  CheckBox.swift
//  WebviewTestTask
//
//  Created by Tania Harbarchuk on 19.01.2024.
//

import UIKit

class CheckBox: UIControl {
    
    private var imageView: UIImageView?
    
    private var image: UIImage {
        guard let fillCheckmark = UIImage(systemName: "checkmark.square.fill") else { return UIImage()}
        guard let notFillCheckmark = UIImage(systemName: "square") else { return UIImage()}
        return checked ? fillCheckmark : notFillCheckmark
    }
    
    public var checked: Bool = false {
        didSet {
            imageView?.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        imageView = UIImageView()
        guard let imageView = imageView else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        backgroundColor = .clear
        
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }
    
    @objc func touchUpInside() {
        checked = !checked
        sendActions(for: .valueChanged)
    }
}
