//
//  DetailView.swift
//  DiveTest
//
//  Created by DIAKO on 5/11/20.
//  Copyright © 2020 Diako. All rights reserved.
//
import UIKit

class DetailView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let browserButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("open in browser", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Colors.mainColor
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 5
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        [titleLabel, imageView, browserButton].forEach { addSubview($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 40),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            browserButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            browserButton.heightAnchor.constraint(equalToConstant: 50),
            browserButton.widthAnchor.constraint(equalToConstant: 200),
            browserButton.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
    }
}
