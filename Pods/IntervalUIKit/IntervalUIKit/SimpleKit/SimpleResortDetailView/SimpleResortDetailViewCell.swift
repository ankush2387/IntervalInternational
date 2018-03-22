//
//  SimpleResortDetailViewCell.swift
//  IntervalUIKit
//
//  Created by Aylwing Olivas on 1/20/18.
//

import Bond
import UIKit
import SDWebImage
import ReactiveKit

final public class SimpleResortDetailViewCell: SimpleTableViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var resortNameLabel: UILabel!
    @IBOutlet private weak var resortLocationLabel: UILabel!
    @IBOutlet private weak var resortCodeLabel: UILabel!
    @IBOutlet private weak var resortImageView: UIImageView!
    @IBOutlet private weak var resortDetailBackgroundView: UIView!

    // MARK: - Public properties
    open weak var viewModel: SimpleResortDetailViewModel? {
        didSet {
            if let viewModel = viewModel {
                setUI()
                viewModel.resortNameLabelText.bind(to: resortNameLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.resortLocationLabelText.bind(to: resortLocationLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.resortCodeLabelText.bind(to: resortCodeLabel.reactive.text).dispose(in: onReuseBag)
                viewModel.resortImage.observeNext(with: setImage).dispose(in: onReuseBag)
                viewModel.resortImageURL.observeNext(with: downloadImage).dispose(in: onReuseBag)
            }
        }
    }

    // MARK: - Private properties
    private func setUI() {

        selectionStyle = .none
        let gradient = CAGradientLayer()
        gradient.frame = resortImageView.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.8, 1]
        resortImageView.layer.mask = gradient

        [resortNameLabel, resortLocationLabel].forEach {
            $0?.textColor = IntervalThemeFactory.deviceTheme.textColorBlack
        }

        resortCodeLabel.textColor = IntervalThemeFactory.deviceTheme.textColorLightOrange
        resortDetailBackgroundView.backgroundColor = IntervalThemeFactory.deviceTheme.backgroundColorWhite.withAlphaComponent(0.7)
    }

    private func setImage(image: UIImage?) {
        if case .some = image {
            resortImageView.backgroundColor = .clear
            resortImageView.contentMode = .scaleToFill
            resortImageView.image = image
        } else {
            resortImageView.backgroundColor = .gray
            resortImageView.contentMode = .scaleAspectFit
            resortImageView.image = viewModel?.placeholderImage.value
        }
    }

    private func downloadImage(url: String?) {
        guard let url = url, let imageURL = URL(string: url) else { return }
        resortImageView.sd_setImage(with: imageURL,
                                    placeholderImage: viewModel?.placeholderImage.value,
                                    options: []) { [unowned self] downloadedImage, _, _, _ in
                                        self.viewModel?.resortImage.next(downloadedImage)
        }
    }
}
