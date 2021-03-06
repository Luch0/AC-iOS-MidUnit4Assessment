//
//  HistoryViewController.swift
//  AC-iOS-MidUnit4Assessment-StudentVersion
//
//  Created by Luis Calle on 12/22/17.
//  Copyright © 2017 C4Q . All rights reserved.
//

import UIKit

// https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/
// reference for implementing collectionview inside a tableviewcell

class HistoryViewController: UIViewController {
    
    let cellSpacing: CGFloat = 3.0
    var storedOffsets = [Int: CGFloat]()
    
    @IBOutlet weak var pastGamesTableView: UITableView!
    
    override func viewDidLoad() {
        self.pastGamesTableView.delegate = self
        self.pastGamesTableView.dataSource = self
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pastGamesTableView.reloadData()
    }

    @IBAction func resetPastGamesButtonPressed(_ sender: UIButton) {
        DataPersistenceModel.shared.clearPastGames()
        pastGamesTableView.reloadData()
    }
    
}

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataPersistenceModel.shared.getPastGames().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pastGameCell = tableView.dequeueReusableCell(withIdentifier: "PastCardGameCell", for: indexPath)
        if let pastGameCell = pastGameCell as? PastGameTableViewCell {
            let selectedPastGame = DataPersistenceModel.shared.getPastGames()[indexPath.row]
            pastGameCell.pastGameScoreLabel.text = "Final Hand Value: \(selectedPastGame.finalScore) - Target: \(selectedPastGame.targetScore)"
        }
        return pastGameCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? PastGameTableViewCell else { return }
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? PastGameTableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
}

extension HistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DataPersistenceModel.shared.getPastGames()[collectionView.tag].gameCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cardCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastCardCell", for: indexPath)
        if let cardCell = cardCell as? CardCollectionViewCell {
            let selectedCard = DataPersistenceModel.shared.getPastGames()[collectionView.tag].gameCards[indexPath.item]
            switch selectedCard.value {
            case "JACK", "QUEEN", "KING":
                cardCell.cardValueLabel.text = "10"
            case "ACE":
                cardCell.cardValueLabel.text = "11"
            default:
                cardCell.cardValueLabel.text = selectedCard.value
            }
            cardCell.cardImageView.image = #imageLiteral(resourceName: "backOfCard")
            ImageFetchHelper.manager.getImage(from: selectedCard.image, completionHandler: {
                cardCell.cardImageView.image = $0
                cardCell.setNeedsLayout()
            }, errorHandler: { print($0) })
        }
        return cardCell
    }
    
}

extension HistoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numCells: CGFloat = 4
        let numSpaces: CGFloat = numCells + 1
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height
        return CGSize(width: (collectionViewWidth - (cellSpacing * numSpaces)) / numCells, height: collectionViewHeight * 0.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: cellSpacing, left: cellSpacing/2, bottom: cellSpacing, right: cellSpacing/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
}
