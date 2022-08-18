//
//  AccountPickerSelectionRowView.swift
//  StripeFinancialConnections
//
//  Created by Krisjanis Gaidis on 8/10/22.
//

import Foundation
import UIKit
@_spi(STP) import StripeUICore

final class AccountPickerSelectionRowView: UIView {
    
    enum SelectionType {
        case checkmark
        case radiobutton
    }
    
    private let type: SelectionType
    private let didSelect: () -> Void
    
    private var isSelected: Bool = false {
        didSet {
            layer.cornerRadius = 8
            if isSelected {
                layer.borderColor = UIColor.textBrand.cgColor
                layer.borderWidth = 2
            } else {
                layer.borderColor = UIColor.borderNeutral.cgColor
                layer.borderWidth = 1
            }
            selectionView.isSelected = isSelected
        }
    }
    
    private lazy var selectionView: SelectionView = {
        let selectionView: SelectionView
        switch type {
        case .checkmark:
            selectionView = CheckboxView()
        case .radiobutton:
            selectionView = RadioButtonView()
        }
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectionView.widthAnchor.constraint(equalToConstant: 20),
            selectionView.heightAnchor.constraint(equalToConstant: 20),
        ])
        return selectionView
    }()
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .stripeFont(forTextStyle: .bodyEmphasized)
        titleLabel.textColor = .textSecondary
        return titleLabel
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let subtitleLabel = UILabel()
        subtitleLabel.font = .stripeFont(forTextStyle: .captionTightEmphasized)
        subtitleLabel.textColor = .textSecondary
        return subtitleLabel
    }()
    
    private lazy var labelStackView: UIStackView = {
        let labelStackView = UIStackView()
        labelStackView.axis = .vertical
        labelStackView.spacing = 0
        return labelStackView
    }()
    
    init(
        type: SelectionType,
        didSelect: @escaping () -> Void
    ) {
        self.type = type
        self.didSelect = didSelect
        super.init(frame: .zero)
    
        labelStackView.addArrangedSubview(titleLabel)
        
        let horizontalStackView = CreateHorizontalStackView(
            arrangedSubviews: [
                selectionView,
                labelStackView,
            ]
        )
        addAndPinSubviewToSafeArea(horizontalStackView)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGestureRecognizer)
        
        isSelected = false // activate the setter to draw border
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: String, subtitle: String?, isSelected: Bool) {
        titleLabel.text = title
        
        subtitleLabel.removeFromSuperview()
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            labelStackView.addArrangedSubview(subtitleLabel)
        }
        titleLabel.text = title
        
        self.isSelected = isSelected
    }
    
    @objc private func didTapView() {
        self.isSelected.toggle()
        self.didSelect()
    }
}

private func CreateHorizontalStackView(arrangedSubviews: [UIView]) -> UIStackView {
    let horizontalStackView = UIStackView(arrangedSubviews: arrangedSubviews)
    horizontalStackView.axis = .horizontal
    horizontalStackView.spacing = 12
    horizontalStackView.isLayoutMarginsRelativeArrangement = true
    horizontalStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
        top: 12,
        leading: 12,
        bottom: 12,
        trailing: 12
    )
    return horizontalStackView
}

// MARK: - Helpers

private protocol SelectionView: UIView {
    var isSelected: Bool { get set }
}
extension CheckboxView: SelectionView { }
extension RadioButtonView: SelectionView { }

#if DEBUG

import SwiftUI

@available(iOS 13.0, *)
@available(iOSApplicationExtension, unavailable)
private struct AccountPickerSelectionRowViewUIViewRepresentable: UIViewRepresentable {
    
    let type: AccountPickerSelectionRowView.SelectionType
    let title: String
    let subtitle: String?
    let isSelected: Bool
    
    func makeUIView(context: Context) -> AccountPickerSelectionRowView {
        let view = AccountPickerSelectionRowView(type: type, didSelect: {})
        view.setTitle(title, subtitle: subtitle, isSelected: isSelected)
        return view
    }
    
    func updateUIView(_ uiView: AccountPickerSelectionRowView, context: Context) {
        uiView.setTitle(title, subtitle: subtitle, isSelected: isSelected)
    }
}

@available(iOSApplicationExtension, unavailable)
struct AccountPickerSelectionRowView_Previews: PreviewProvider {
    @available(iOS 13.0.0, *)
    static var previews: some View {
        if #available(iOS 14.0, *) {
            ScrollView {
                VStack(spacing: 10) {
                    VStack(spacing: 2) {
                        Text("Checkmark")
                        AccountPickerSelectionRowViewUIViewRepresentable(
                            type: .checkmark,
                            title: "Joint Checking",
                            subtitle: "••••••••6789",
                            isSelected: true
                        ).frame(height: 60)
                        AccountPickerSelectionRowViewUIViewRepresentable(
                            type: .checkmark,
                            title: "Joint Checking",
                            subtitle: nil,
                            isSelected: false
                        ).frame(height: 60)
                    }
                    VStack(spacing: 2) {
                        Text("Radiobutton")
                        AccountPickerSelectionRowViewUIViewRepresentable(
                            type: .radiobutton,
                            title: "Student Savings",
                            subtitle: "••••••••6789",
                            isSelected: true
                        ).frame(height: 60)
                        AccountPickerSelectionRowViewUIViewRepresentable(
                            type: .radiobutton,
                            title: "Student Savings",
                            subtitle: nil,
                            isSelected: false
                        ).frame(height: 60)
                    }
                }
            }
        }
    }
}

#endif
