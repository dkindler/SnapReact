//
//  SnapListTableViewController.swift
//  SnapReaction
//
//  Created by Dan Kindler on 11/3/16.
//  Copyright © 2016 Dan Kindler. All rights reserved.
//

import UIKit

class SnapListTableViewController: UITableViewController {

    // Properties
    var pressedSnapCellIcon: UIView?
    var shouldHideStatusBar = false
    var snaps = [Snap]()
    
    // Constants
    let snapCellIdentifier = "snapCellIdentifier"
    let displaySnapSegue = "displaySnapSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewProperties()
        setupTableView()
        initializeTestData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldHideStatusBar = false
        UIView.animate(withDuration: 0.3) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    func setupViewProperties() {
        navigationItem.title = "Chats"
        if let navController = navigationController {
            navController.navigationBar.barStyle = UIBarStyle.black
            navController.navigationBar.barTintColor = UIColor.colorWithRGB(rgbValue: 0x0EADFF)
            navController.navigationBar.tintColor = .white
        }
    }
    
    func setupTableView() {
        tableView.register(UINib(nibName: "SnapTableViewCell", bundle: nil), forCellReuseIdentifier: snapCellIdentifier)
    }
    
    func initializeTestData() {
        snaps.append(Snap(from: "Matt Marsh", length: 3, videoFileName: "dan", reactionSnap: true))
        snaps.append(Snap(from: "Brian Degener", length: 3, photoFileName: "Dolce", reactionSnap: false))
        snaps.append(Snap(from: "Mary Ann", length: 3, photoFileName: "proposal", reactionSnap: true))
        snaps.append(Snap(from: "Matt Marsh", length: 3, videoFileName: "luna", reactionSnap: true))
        snaps.append(Snap(from: "Andrew Newman", length: 3, videoFileName: "liza", reactionSnap: true))
        snaps.append(Snap(from: "John Conte", length: 3, videoFileName: "conte", reactionSnap: true))

        tableView.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snaps.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: snapCellIdentifier, for: indexPath) as! SnapTableViewCell
        cell.snap = snaps[indexPath.item]
        return cell
    }

    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SnapTableViewCell.estimatedCellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let cell = tableView.cellForRow(at: indexPath) as? SnapTableViewCell {
            pressedSnapCellIcon = cell.indicatorView
            performSegue(withIdentifier: displaySnapSegue, sender: snaps[indexPath.item])
        }
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == displaySnapSegue {
            if let vc = segue.destination as? SnapViewController, let snap = sender as? Snap {
                shouldHideStatusBar = true
                vc.snap = snap
            }
        }
    }
}













