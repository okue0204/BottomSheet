//
//  ViewController.swift
//  BottomSheet
//
//  Created by 奥江英隆 on 2024/05/18.
//

import UIKit

class ViewController: UIViewController {
    
    private enum BottomSheetAppearance {
        case top
        case middle
        case bottom
    }

    @IBOutlet weak var bottomSheetView: BottomSheetView!
    @IBOutlet weak var backgroundOverlayView: UIView!
    
    private static let maxSwipeVelocity: CGFloat = 3000
    private static let normalSwipeVelocity: CGFloat = 500
    private static let defaultAlpha: CGFloat = 0.3
    private static let animationDuration: CGFloat = 0.25
    
    private var isFirstLaunch = true
    private var latestTouchPointY: CGFloat = 0
    
    private var windowHeight: CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        return windowScene.screen.bounds.height
    }
    
    private var bottomSheetAppearance: BottomSheetAppearance = .top {
        didSet {
            if isFirstLaunch {
                isFirstLaunch = false
                return
            }
            UIView.animate(withDuration: Self.animationDuration,
                           delay: 0,
                           options: .curveEaseOut) { [weak self] in
                guard let self else {
                    return
                }
                switch bottomSheetAppearance {
                case .top:
                    backgroundOverlayView.alpha = Self.defaultAlpha
                    latestTouchPointY = 0
                    bottomSheetView.transform = .identity
                case .middle:
                    backgroundOverlayView.alpha = 0
                    latestTouchPointY = bottomSheetView.bounds.height * 0.55
                    bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetView.bounds.height * 0.55)
                case .bottom:
                    backgroundOverlayView.alpha = 0
                    latestTouchPointY = bottomSheetView.bounds.height * 0.85
                    bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetView.bounds.height * 0.85)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    private func setupLayout() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(_:)))
        bottomSheetView.addGestureRecognizer(panGestureRecognizer)
        bottomSheetAppearance = .bottom
        backgroundOverlayView.alpha = 0
        latestTouchPointY = bottomSheetView.bounds.height * 0.85
        bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetView.bounds.height * 0.85)
    }
    
    @objc
    private func panGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        let translationY = sender.translation(in: bottomSheetView).y
        let bottomSheetHeight = bottomSheetView.bounds.height
        switch sender.state {
        case .changed:
            if bottomSheetAppearance == .middle {
                backgroundOverlayView.alpha = min(Self.defaultAlpha,
                                                  -(translationY / (bottomSheetHeight * 0.55)) * Self.defaultAlpha)
            } else if bottomSheetAppearance == .top {
                backgroundOverlayView.alpha = min(Self.defaultAlpha,
                                                  Self.defaultAlpha - (translationY / (bottomSheetHeight * 0.55)) * Self.defaultAlpha)
            }
            bottomSheetView.transform = CGAffineTransform(translationX: 0, y: max(0, translationY + latestTouchPointY))
        case .ended:
            bottomSheetAppearance = {
                return switch sender.velocity(in: bottomSheetView).y {
                case Self.maxSwipeVelocity...: // 3000以上で下にスワイプ
                        .bottom
                case ...(-Self.maxSwipeVelocity): // 3000以上で上にスワイプ
                        .top
                case Self.normalSwipeVelocity...: // 500以上で下にスワイプ
                    switch bottomSheetAppearance {
                    case .top:
                            .middle
                    case .middle:
                            .bottom
                    case .bottom:
                            .bottom
                    }
                case ...(-Self.normalSwipeVelocity): // 500以上で上にスワイプ
                    switch bottomSheetAppearance {
                    case .top:
                            .top
                    case .middle:
                            .top
                    case .bottom:
                            .middle
                    }
                default:
                    switch translationY + latestTouchPointY {
                    case (bottomSheetHeight * 0.7)...bottomSheetHeight:
                            .bottom
                    case (bottomSheetHeight * 0.4)...(bottomSheetHeight * 0.7):
                            .middle
                    case ...(bottomSheetHeight * 0.4):
                            .top
                    default:
                            .bottom
                    }
                }
            }()
        default:
            break
        }
    }
}

