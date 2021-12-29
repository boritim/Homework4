//
//  ViewController.swift
//  CatsAndDogs
//
//  Created by Борисов Тимофей on 28.12.2021.
//

import Combine
import Kingfisher
import SnapKit
import UIKit

class ViewController: UIViewController {


    private enum Constants {
        static let defaultInsets: CGFloat = 16
        static let segmentTop: CGFloat = 32
        static let contentHeight: CGFloat = 200
        static let contentTop: CGFloat = 40
        static let labelHeight: CGFloat = 46
        static let buttonLeading: CGFloat = 112
        static let buttonHeight: CGFloat = 40

        static let borderWidth: CGFloat = 1
        static let contentCornerRadius: CGFloat = 10
        static let buttonCornerRadius: CGFloat = 20
    }



    private let segmentedControl = UISegmentedControl(items: ["Cats", "Dogs"])
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "Content"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private let contentImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.borderWidth = Constants.borderWidth
        view.layer.cornerRadius = Constants.contentCornerRadius
        return view
    }()
    private let moreButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 1, green: 0.609, blue: 0.542, alpha: 1)
        button.setTitle("More", for: .normal)
        button.layer.cornerRadius = Constants.buttonCornerRadius
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        return button
    }()
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Score: 0 cats and 0 dogs"
        return label
    }()
    private var viewModel = ViewModel()
    private var cancellable = Set<AnyCancellable>()



    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupNavigationBar()
        setupSubscribers()
        view.backgroundColor = .white
    }



    private func setupView() {
        view.addSubview(segmentedControl)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(didChangeIndexForSegmentedControl), for: .valueChanged)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Constants.defaultInsets)
            $0.centerX.equalToSuperview()
        }

        view.addSubview(contentImageView)
        contentImageView.snp.makeConstraints {
            $0.height.equalTo(Constants.contentHeight)
            $0.leading.trailing.equalToSuperview().inset(Constants.defaultInsets)
            $0.top.equalTo(self.segmentedControl.snp.bottom).offset(Constants.contentTop)
        }

        contentImageView.addSubview(contentLabel)
        contentLabel.text = "Content"
        contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        view.addSubview(moreButton)
        moreButton.snp.makeConstraints {
            $0.height.equalTo(Constants.buttonHeight)
            $0.leading.trailing.equalToSuperview().inset(Constants.buttonLeading)
            $0.top.equalTo(contentImageView.snp.bottom).offset(Constants.defaultInsets)
        }

        view.addSubview(scoreLabel)
        scoreLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Constants.defaultInsets)
            $0.top.equalTo(self.moreButton.snp.bottom).offset(Constants.defaultInsets)
            $0.height.equalTo(Constants.labelHeight)
        }
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetButtonTapped))
        title = "Cats and dogs"
    }



    @objc private func didChangeIndexForSegmentedControl() {
        let index = segmentedControl.selectedSegmentIndex
        if index == 0 {
            viewModel.type = .cats
        } else {
            viewModel.type = .dogs
        }
    }

    @objc private func moreButtonTapped() {
        viewModel.fetchContent()
    }

    @objc func resetButtonTapped() {
        viewModel.catsCount = 0
        viewModel.dogsCount = 0
        viewModel.text = nil
        viewModel.imageURL = nil
    }



    private func setupSubscribers() {

        let typeSub = viewModel.$type
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                guard let self = self else { return }
                switch type {
                case .cats:
                    self.contentImageView.image = nil
                    self.contentLabel.isHidden = false
                    self.contentLabel.text = self.viewModel.text ?? "Content"

                case .dogs:
                    self.contentImageView.kf.setImage(with: self.viewModel.imageURL)
                    self.contentLabel.isHidden = true
                }
            }

        let textSub = viewModel.$text
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.contentLabel.isHidden = false
                self.contentImageView.image = nil
                self.contentLabel.text = self.viewModel.text ?? "Content"
            }

        let urlSub = viewModel.$imageURL
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self = self else { return }
                self.contentImageView.kf.setImage(with: url)
                self.contentLabel.isHidden = true
            }

        let catsSub = viewModel.$catsCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.scoreLabel.text = "Score: \(self.viewModel.catsCount) cats and \(self.viewModel.dogsCount) dogs"
            }

        let dogsSub = viewModel.$dogsCount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.scoreLabel.text = "Score: \(self.viewModel.catsCount) cats and \(self.viewModel.dogsCount) dogs"
            }

        cancellable.insert(typeSub)
        cancellable.insert(textSub)
        cancellable.insert(urlSub)
        cancellable.insert(catsSub)
        cancellable.insert(dogsSub)
    }
}

