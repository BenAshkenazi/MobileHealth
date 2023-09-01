//
//  UnitTableViewCell.swift
//  MobileHealthApp
//
//  Created by Fawwaz Firdaus on 8/8/23.
//

import UIKit

class UnitTableViewCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let hoursLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let daysLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(nameLabel)
        addSubview(daysLabel)
        addSubview(hoursLabel)

        nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true

        daysLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        daysLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5).isActive = true
        daysLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true

        hoursLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        hoursLabel.topAnchor.constraint(equalTo: daysLabel.bottomAnchor, constant: 5).isActive = true
        hoursLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor).isActive = true
    }

    func configure(with unit: HealthUnit) {
        nameLabel.text = unit.name ?? "Unknown Name"
        daysLabel.text = "Available on: \(unit.formattedDaysName)"
        hoursLabel.text = "\(unit.formattedHours)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.backgroundColor = UIColor(red: 255 / 255.0, green: 212 / 255.0, blue: 238 / 255.0, alpha: 1.0) // FFD4EE
        } else {
            self.backgroundColor = UIColor(red: 255 / 255.0, green: 212 / 255.0, blue: 238 / 255.0, alpha: 1.0)// UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.backgroundColor = UIColor(red: 164 / 255.0, green: 118 / 255.0, blue: 162 / 255.0, alpha: 1.0)
    }

}
