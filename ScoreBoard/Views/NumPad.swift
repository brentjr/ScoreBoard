//
//  NumPad.swift
//  ScoreBoard
//
//  Created by Brent Roberts on 1/7/18.
//  Copyright © 2018 Gouda Labs. All rights reserved.
//

import UIKit

public typealias Row = Int
public typealias Column = Int

// MARK: - Position
public typealias Position = (row: Row, column: Column)

// MARK: - Item
public struct Item {
    public var backgroundColor: UIColor? = .white
    public var selectedBackgroundColor: UIColor? = .clear
    public var image: UIImage?
    public var title: String?
    public var titleColor: UIColor? = .black
    public var font: UIFont? = .systemFont(ofSize: 17)
    
    public init() {}
    public init(title: String?) {
        self.title = title
    }
    public init(image: UIImage?) {
        self.image = image
    }
}

// MARK: - NumPadDelegate
protocol NumPadDelegate: class {
    
    /// The item was tapped handler.
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position)
    
    /// The size of an item at position.
    func numPad(_ numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize
    
}

extension NumPadDelegate {
    func numPad(_ numPad: NumPad, itemTapped item: Item, atPosition position: Position) {}
    func numPad(_ numPad: NumPad, sizeForItemAtPosition position: Position) -> CGSize { return CGSize() }
}

// MARK: - NumPad
class NumPad: UIView {
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(Cell.self, forCellWithReuseIdentifier: String(describing: Cell.self))
        self.addSubview(collectionView)
        let views = ["collectionView": collectionView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|", options: [], metrics: nil, views: views))
        return collectionView
        }()
    
    /// Delegate for the number pad.
    open weak var delegate: NumPadDelegate?
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - Public Helpers
extension NumPad {
    
    /// Returns the item at the specified position.
    func item(forPosition position: Position) -> Item? {
        let indexPath = self.indexPath(forPosition: position)
        let cell = collectionView.cellForItem(at: indexPath)
        return (cell as? Cell)?.item
    }
}

// MARK: - Private Helpers
extension NumPad {
    
    /// Returns the index path at the specified position.
    private func indexPath(forPosition position: Position) -> IndexPath {
        return IndexPath(item: position.column, section: position.row)
    }
    
    /// Returns the position at the specified index path.
    private func position(forIndexPath indexPath: IndexPath) -> Position {
        return Position(row: indexPath.section, column: indexPath.item)
    }
}

// MARK: - UICollectionViewDataSource
extension NumPad: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let position = self.position(forIndexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath) as! Cell
        
        var item = Item()
        item.title = {
            switch position {
            case (3, 0):
                return "C"
            case (3, 1):
                return "0"
            case (3, 2):
                return "00"
            default:
                var index = (0..<position.row).map { _ in 3 }.reduce(0, +)
                index += position.column
                return "\(index + 1)"
            }
        }()
        item.titleColor = {
            switch position {
            case (3, 0):
                return .orange
            default:
                return UIColor(white: 0.3, alpha: 1)
            }
        }()
        item.font = .systemFont(ofSize: 40)
        
        
        
        cell.item = item
        cell.buttonTapped = { [unowned self] _ in
            self.delegate?.numPad(self, itemTapped: item, atPosition: position)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NumPad: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let position = self.position(forIndexPath: indexPath)
        let size = delegate?.numPad(self, sizeForItemAtPosition: position) ?? CGSize()
        return !size.isZero() ? size : {
            var size = collectionView.frame.size
            size.width /= CGFloat(3)
            size.height /= CGFloat(4)
            return size
            }()
    }
}

// MARK: - Cell
class Cell: UICollectionViewCell {
    
    lazy var button: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.titleLabel?.textAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
        self.contentView.addSubview(button)
        let views = ["button": button]
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-1-[button]|", options: [], metrics: nil, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-1-[button]|", options: [], metrics: nil, views: views))
        return button
        }()
    
    var item: Item! {
        didSet {
            button.setTitle(item.title, for: UIControlState())
            
            button.setTitleColor(item.titleColor, for: UIControlState())
            
            button.titleLabel?.font = item.font
            
            button.setImage(item.image, for: UIControlState())
            
            var image = item.backgroundColor.map { UIImage(color: $0) }
            button.setBackgroundImage(image, for: UIControlState())
            image = item.selectedBackgroundColor.map { UIImage(color: $0) }
            button.setBackgroundImage(image, for: .highlighted)
            button.setBackgroundImage(image, for: .selected)
            
            button.tintColor = item.titleColor
        }
    }
    
    var buttonTapped: ((UIButton) -> Void)?
    
    @IBAction func _buttonTapped(_ button: UIButton) {
        buttonTapped?(button)
    }
}

// MARK: - UIImage
extension UIImage {
    
    convenience init(color: UIColor) {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: CGPoint(), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage!)!)
    }
}

// MARK: - CGSize
extension CGSize {
    
    func isZero() -> Bool {
        return self.equalTo(CGSize())
    }
}
