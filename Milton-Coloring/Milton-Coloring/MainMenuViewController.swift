//
//  MainMenuViewController.swift
//  MiltonPuzzles
//
//  Created by Stefanita Oaca on 06.01.2022.
//

import UIKit
import AlignedCollectionViewFlowLayout

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewRightConstraint: NSLayoutConstraint!
    
    private var sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    private var indexOfCellBeforeDragging = 0
    
    var selectedBook: ColoringBook!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backgroundImage.backgroundColor = AssetsManager.sharedInstance.getMainMenuBackgroundColor()
        self.backgroundImage.image = AssetsManager.sharedInstance.getMainMenuBackgroundImage()
        
        SoundsController.sharedInstance.checkAndPlayBackgroundMusic()
        
        InAppPurchases.shared.load()
        
#if targetEnvironment(macCatalyst)
        func bitSet(_ bits: [Int]) -> UInt {
            return bits.reduce(0) { $0 | (1 << $1) }
        }
        
        func property(_ property: String, object: NSObject, set: [Int], clear: [Int]) {
            if let value = object.value(forKey: property) as? UInt {
                object.setValue((value & ~bitSet(clear)) | bitSet(set), forKey: property)
            }
        }
        if  let NSApplication = NSClassFromString("NSApplication") as? NSObject.Type,
            let sharedApplication = NSApplication.value(forKeyPath: "sharedApplication") as? NSObject,
            let windows = sharedApplication.value(forKeyPath: "windows") as? [NSObject]
        {
            for window in windows {
                let resizable = 3
                property("styleMask", object: window, set: [], clear: [resizable])
                let fullScreenPrimary = 7
                let fullScreenAuxiliary = 8
                let fullScreenNone = 9
                property("collectionBehavior", object: window, set: [fullScreenNone], clear: [fullScreenPrimary, fullScreenAuxiliary])
            }
        }
#endif
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
        
        collectionViewLeftConstraint.constant = 0
        collectionViewRightConstraint.constant = 0
        
        let paddingHeight = collectionView.frame.size.height / 2 - (collectionView.frame.size.height / 2.5) / 2
        let paddingWidth = AssetsManager.sharedInstance.getSidePadding(from: self.view) + collectionView.frame.size.width / 2 - (collectionView.frame.size.height / 2.5) / 2
        sectionInsets = UIEdgeInsets(top: paddingHeight, left: paddingWidth, bottom: paddingHeight, right: paddingWidth)
        loadButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResourcesWebFromMainMenu"{
            (segue.destination as! ResourceWebViewViewController).url = URL(string: "https://bazzipapers.crmalldata3.com/files")
        }else if segue.identifier == "ColoringFromMainMenu"{
            (segue.destination as! ColoringViewController).coloringBook = self.selectedBook
        }
    }
    
#if targetEnvironment(macCatalyst)
    
#else
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let pageWidth = collectionView.frame.size.width / 2
        let proportionalOffset = collectionView.contentOffset.x / pageWidth
        indexOfCellBeforeDragging = Int(round(proportionalOffset))
        
        print("indexOfCellBeforeDragging: \(indexOfCellBeforeDragging)")
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrolling
        targetContentOffset.pointee = scrollView.contentOffset
        
        // Calculate conditions
        let pageWidth = collectionView.frame.size.width / 2
        let collectionViewItemCount = AssetsManager.sharedInstance.coloringBooks.count
        let proportionalOffset = collectionView.contentOffset.x / pageWidth
        let indexOfMajorCell = Int(round(proportionalOffset))
        
        print("pageWidth: \(pageWidth)")
        print("proportionalOffset: \(proportionalOffset)")
        print("indexOfMajorCell: \(indexOfMajorCell)")
        
        
        let swipeVelocityThreshold: CGFloat = 0.25
        let hasEnoughVelocityToSlideToTheNextCell = indexOfCellBeforeDragging + 1 < collectionViewItemCount && velocity.x > swipeVelocityThreshold
        let hasEnoughVelocityToSlideToThePreviousCell = indexOfCellBeforeDragging - 1 >= 0 && velocity.x < -swipeVelocityThreshold
        let majorCellIsTheCellBeforeDragging = indexOfMajorCell == indexOfCellBeforeDragging
        let didUseSwipeToSkipCell = majorCellIsTheCellBeforeDragging && (hasEnoughVelocityToSlideToTheNextCell || hasEnoughVelocityToSlideToThePreviousCell)
        
        if didUseSwipeToSkipCell {
            // Animate so that swipe is just continued
            let snapToIndex = indexOfCellBeforeDragging + (hasEnoughVelocityToSlideToTheNextCell ? 1 : -1)
            let toValue = pageWidth * CGFloat(snapToIndex)
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: velocity.x,
                options: .allowUserInteraction,
                animations: {
                    scrollView.contentOffset = CGPoint(x: toValue, y: 0)
                    scrollView.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            // Pop back (against velocity)
            let indexPath = IndexPath(row: indexOfMajorCell, section: 0)
            if AssetsManager.sharedInstance.coloringBooks.count > indexPath.row {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
#endif
    
    func loadButtons(){
        if let button = AssetsManager.sharedInstance.getMainMenuSettingsButton(){
            let settings = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
            settings.addTarget(self, action: #selector(onSettings), for: .touchUpInside)
        }
        
        if let button = AssetsManager.sharedInstance.getMainMenuResourcesButton(){
            let resourcesButton = AssetsManager.sharedInstance.createButton(using: button, superView: self.view)
            resourcesButton.addTarget(self, action: #selector(onResources), for: .touchUpInside)
        }
    }
    
    @objc func onResources() {
        SoundsController.sharedInstance.playMenuSound()
        self.performSegue(withIdentifier: "ResourcesWebFromMainMenu", sender: self)
    }
    
    @objc func onSettings() {
        SoundsController.sharedInstance.playMenuSound()
        self.performSegue(withIdentifier: "SettingsFromMainMenu", sender: self)
    }
}

extension MainMenuViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AssetsManager.sharedInstance.coloringBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:  "gameCell", for: indexPath)
        let book = AssetsManager.sharedInstance.coloringBooks[indexPath.item]
        
        if let background = cell.viewWithTag(1) as? UIImageView{
            background.image = book.icon
            if let button = AssetsManager.sharedInstance.getBookMenuButton(){
                let menuItem = AssetsManager.sharedInstance.createButton(using: button, superView: background, fillView: true)
            }
        }
        
        if let label = cell.viewWithTag(2) as? UILabel{
            label.isHidden = true
        }
        
        if let activityIndicator = cell.viewWithTag(3) as? UIActivityIndicatorView{
            activityIndicator.isHidden = true
        }
        
        if let background = cell.viewWithTag(4) as? UIImageView{
            background.image = InAppPurchases.shared.bookLocked(book) ? AssetsManager.sharedInstance.getMainMenuLockedImage() : nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let activityIndicator = collectionView.cellForItem(at: indexPath)?.viewWithTag(3) as? UIActivityIndicatorView{
            activityIndicator.isHidden = false
        }
        if InAppPurchases.shared.bookLocked(AssetsManager.sharedInstance.coloringBooks[indexPath.item]) {
            InAppPurchases.shared.downloadBook(book: AssetsManager.sharedInstance.coloringBooks[indexPath.item], completionHandle: { success, data in
                if success {
                    AssetsManager.sharedInstance.coloringBooks[indexPath.item].loadBookData(completion: {
                        success in
                        self.showColoringScene(for: AssetsManager.sharedInstance.coloringBooks[indexPath.item])
                        if let activityIndicator = collectionView.cellForItem(at: indexPath)?.viewWithTag(3) as? UIActivityIndicatorView{
                            activityIndicator.isHidden = true
                        }
                    })
                }
                else {
                    if let activityIndicator = collectionView.cellForItem(at: indexPath)?.viewWithTag(3) as? UIActivityIndicatorView{
                        activityIndicator.isHidden = true
                    }
                }
            })
        }
        else {
            AssetsManager.sharedInstance.coloringBooks[indexPath.item].loadBookData(completion: {
                success in
                self.showColoringScene(for: AssetsManager.sharedInstance.coloringBooks[indexPath.item])
                if let activityIndicator = collectionView.cellForItem(at: indexPath)?.viewWithTag(3) as? UIActivityIndicatorView{
                    activityIndicator.isHidden = true
                }
            })
        }
    }
    
    
    func showColoringScene(for coloringBook: ColoringBook){
        self.selectedBook = coloringBook
        self.performSegue(withIdentifier: "ColoringFromMainMenu", sender: self)
    }
}

extension MainMenuViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath ) -> CGSize {
        if let button = AssetsManager.sharedInstance.getBookMenuButton(){
            return CGSize(width: self.view.frame.size.width * button.width, height: self.view.frame.size.height * button.height)
        }else{
            let cellHeight = self.view.frame.size.height / 2.5
            return CGSize(width: cellHeight  * 1.2, height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return self.view.frame.size.width / 2 - (self.view.frame.size.height / 2.5)
    }
}
