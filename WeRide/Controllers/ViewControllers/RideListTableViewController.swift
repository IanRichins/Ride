//
//  RideListTableViewController.swift
//  WeRide
//
//  Created by Ian Richins on 6/9/20.
//  Copyright © 2020 Ian Richins. All rights reserved.
//

import UIKit

class RideListTableViewController: UITableViewController {
    
    //MARK: -Outlets
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    //MARK: -Properties
    var rideShown = [Bool](repeating: false, count: 6)
    
    //MARK: -LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.title = "Back"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: -Helpers
    func loadData() {
        RideController.shared.fetchRide { (result) in
            switch result {
            case .success(let rides):
                RideController.shared.rides = rides
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("There was an error fetching rides")
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RideController.shared.rides.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if rideShown[indexPath.row] {
            return
        }
        
        rideShown[indexPath.row] = true
        
        cell.alpha = 0
        
        UIView.animate(withDuration: 1.0) {
            cell.alpha = 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "rideCell", for: indexPath) as? RideListTableViewCell else  { return UITableViewCell() }

        let ride = RideController.shared.rides[indexPath.row]
        
        cell.ride = ride
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let rideToDelete = RideController.shared.rides[indexPath.row]
            guard let index = RideController.shared.rides.firstIndex(of: rideToDelete) else { return }
            RideController.shared.deleteRide(ride: rideToDelete) { (result) in
                switch result {
                case .success(_):
                    RideController.shared.rides.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }    
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapDVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? MapDetailsViewController else { return }
            
            let rideToSend = RideController.shared.rides[indexPath.row]
            destinationVC.ride = rideToSend
        }
    }
    
}// END OF CLASS
