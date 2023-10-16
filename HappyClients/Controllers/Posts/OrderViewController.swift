//
//  OrderViewController.swift
//  HappyClients
//
//  Created by MacBook on 11.05.2023.
//

import UIKit

class OrderViewController: UIViewController {

    let locationPicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    private let options = [
            ("Essential Mall, Almaty", "Essential Mall"),
            ("Ritz Carlton, Astana", "Ritz Carlton"),
            ("Nurly Tau, Almaty", "Nurly Tau")
        ]
    
    let datePicker = UIDatePicker()
    
    private var randomValue: Double = 0.0
    
    private let valueLabel: UILabel = {
            let label = UILabel()
            label.text = "Random Value: "
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 18)
            return label
        }()
    
    // Title field
    private let titleField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Enter Title..."
        field.autocapitalizationType = .words
        field.autocorrectionType = .yes
        field.backgroundColor = .secondarySystemBackground
        field.layer.masksToBounds = true
        return field
    }()

    // Image Header
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "photo")
        imageView.backgroundColor = .tertiarySystemBackground
        return imageView
    }()

    // TextView for post
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .secondarySystemBackground
        textView.isEditable = true
        textView.font = .systemFont(ofSize: 28)
        return textView
    }()

    private var selectedHeaderImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(headerImageView)
        view.addSubview(textView)
        view.addSubview(titleField)
        view.addSubview(locationPicker)
        view.addSubview(datePicker)
        view.addSubview(valueLabel)
        locationPicker.delegate = self
        locationPicker.dataSource = self
        datePicker.datePickerMode = .dateAndTime
        datePicker.minimumDate = Date()
        randomValue = Double.random(in: 300000...500000)
        valueLabel.text = "Total Billboard Price: \(String(format: "%.2f", randomValue)) tenge"
//        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
//                button.setTitle("Select Date", for: .normal)
//                button.backgroundColor = .systemBlue
//                button.addTarget(self, action: #selector(didTapDate), for: .touchUpInside)
//                view.addSubview(button)
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapHeader))
        headerImageView.addGestureRecognizer(tap)
        configureButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        titleField.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width-20, height: 50)
        headerImageView.frame = CGRect(x: 0, y: titleField.bottom+5, width: view.width, height: 160)
        textView.frame = CGRect(x: 10, y: headerImageView.bottom+10, width: view.width-20, height: view.height-630-view.safeAreaInsets.top)
        locationPicker.frame = CGRect(x: 13, y: textView.bottom - 30, width: view.width - 50, height: 150)
        datePicker.frame = CGRect(x: -100, y: locationPicker.bottom - 50, width: view.frame.width, height: 200)
        valueLabel.frame = CGRect(x: 50, y: datePicker.bottom - 70, width: view.width - 100, height: 100)
    }

    @objc private func didTapDate() {
            // Get the selected date from the datePicker
            let date = datePicker.date

            // Format the date as a string
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy h:mm a"
            let dateString = formatter.string(from: date)

            // Display an alert with the selected date
            let alert = UIAlertController(title: "Selected Date", message: dateString, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    
    @objc private func didTapHeader() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private func configureButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(didTapCancel)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost)
        )
    }

    @objc private func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func didTapPost() {
        // Check data and post
        guard let title = titleField.text,
              let body = textView.text,
              let headerImage = selectedHeaderImage,
              let email = UserDefaults.standard.string(forKey: "email"),
              !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !body.trimmingCharacters(in: .whitespaces).isEmpty else {

            let alert = UIAlertController(title: "Enter Post Details",
                                          message: "Please enter a title, body, and select a image to continue.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            
            IAPManager.shared.fetchPackages { package in
                guard let package = package else { return }
                IAPManager.shared.subscribe(package: package) { [weak  self] success in
                    print("Purchase: \(success)")
                    DispatchQueue.main.async {
                        if success {
                            self?.dismiss(animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(
                                title: "Subscription Failed",
                                message: "We were unable to complete the transaction.",
                                preferredStyle: .alert
                            )
                            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                            self?.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
            
            return
        }

        print("Starting post...")

        let newPostId = UUID().uuidString

        // Upload header Image
        StorageManager.shared.uploadAdHeaderImage(
            email: email,
            image: headerImage,
            postId: newPostId
            
        ) { success in
            guard success else {
                return
            }
            StorageManager.shared.downloadUrlForPostHeader(email: email, postId: newPostId) { url in
                guard let headerUrl = url else {
                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrate(for: .error)
                    }
                    return
                }

                // Insert of post into DB
                let post = AdPost(
                    identifier: newPostId,
                    title: title,
                    timestamp: Date().timeIntervalSince1970,
                    headerImageUrl: headerUrl,
                    text: body
                )

                DatabaseManager.shared.insert(adPost: post, email: email) { [weak self] posted in
                    guard posted else {
                        DispatchQueue.main.async {
                            HapticsManager.shared.vibrate(for: .error)
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        HapticsManager.shared.vibrate(for: .success)
                        self?.didTapCancel()
                    }
                }
            }
        }
    }
}

extension OrderViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row].0
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedOption = options[row].1
    }
}

extension OrderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        selectedHeaderImage = image
        headerImageView.image = image
    }
    
    
}


