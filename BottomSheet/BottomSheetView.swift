//
//  BottomSheetView.swift
//  BottomSheet
//
//  Created by 奥江英隆 on 2024/05/18.
//

import UIKit

class BottomSheetView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNib()
    }
    
    private func loadNib() {
        let bundle = Bundle(for: type(of: self))
        guard let view = UINib(nibName: String(describing: Self.self), bundle: bundle).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    private func setupLayout() {
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
    }
}
