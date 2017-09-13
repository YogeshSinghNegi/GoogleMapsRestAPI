//
//  GoogleMapsAPIVC.Swift
//  GoogleMapsRestAPI
//
//  Created by appinventiv on 12/09/17.
//  Copyright © 2017 yogesh singh negi. All rights reserved.
//

import UIKit
import Foundation

//=============================================================//
//MARK: GoogleMapsAPIVC Class
//=============================================================//

class GoogleMapsAPIVC: UIViewController {
    
//=============================================================//
//MARK: Defining Properties
//=============================================================//
    
    // Storing lat and lng of start and end location
    var latStartLocation = [Any]()
    var latEndLocation = [Any]()
    var lngStartLocation = [Any]()
    var lngEndLocation = [Any]()
    
//=============================================================//
//MARK: Defining IBOutlets
//=============================================================//
    
    @IBOutlet weak var myLoader: UIActivityIndicatorView!
    
    @IBOutlet weak var mapsDetailsTable: UITableView!
    
//=============================================================//
//MARK: viewDidLoad() method
//=============================================================//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting delegates and DataSource
        self.mapsDetailsTable.delegate = self
        self.mapsDetailsTable.dataSource = self
        
        // Registering Nib for cell
        let cell = UINib(nibName: "CustomCell", bundle: nil)
        self.mapsDetailsTable.register(cell, forCellReuseIdentifier: "CustomCell")
        self.mapsDetailsTable.separatorStyle = .none
        
        // Initially Loader is hidden
        self.stopLoader()
        
    }
    
//=============================================================//
//MARK: Defining IBAction
//=============================================================//
    
    @IBAction func getDetailsBtnTapped(_ sender: UIButton) {
        
        // Calling method which contains all the RestAPI process
        self.googleMapsLatLng()
        
        // Strating Loader
        self.startLoader()
        
        // Setting some delay to reload table. Because data takes time coming from the URL
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3.0) {

            // Reloading table to view the updated data
            self.mapsDetailsTable.reloadData()
            
            // Stoping Loader
            self.stopLoader()
            
        }
    }
    
//=============================================================//
//MARK: googleMapsLatLng() method for getting lat and lng
//=============================================================//
    
    // Function contains all the logic to hit an Google Maps API
    func googleMapsLatLng() {
        
        // Setting Header
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "cache-control": "no-cache",
            "postman-token": "2fca997b-75c7-1da0-34bb-1ff7047e1d2f"
        ]
        
        // Setting the Body of the HTTP Request
        let postData = NSMutableData(data: "key=AIzaSyCocEAJHSAS4BxQseCRW6Sg2ga0GdT7wqg".data(using: String.Encoding.utf8)!)
        
        // Setting the Request
        let request = NSMutableURLRequest(url: NSURL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=75%209th%20Ave%20New%20York%2C%20NY&destination=MetLife%20Stadium%201%20MetLife%20Stadium%20Dr%20East%20Rutherford%2C%20NJ%2007073&departure_time=1541202457&traffic_model=best_guess&key=AIzaSyCocEAJHSAS4BxQseCRW6Sg2ga0GdT7wqg")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        // Request Generated
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let err = error {
                print(err)
            } else {
                
                // Returns a Foundation object from given JSON data (Dictionary,Array)
                let json = try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.init(rawValue: 0))
                
                // Further coversions for fetching the desired values
                guard let dict = json as? [String:Any] else { fatalError("dict not memorised") }
                
                guard let routes = dict["routes"] as? [[String:Any]] else { fatalError("routes not memorised") }
                
                guard let legs = routes[0]["legs"] as? [[String:Any]] else { fatalError("Legs not initialised") }
                
                guard let startLocation = legs[0]["start_location"] as? [String:Any] else { fatalError("Start not initialised") }
                guard let endLocation = legs[0]["end_location"] as? [String:Any] else { fatalError("End not initialised") }
                
                var dictionaryStartLocation = [Int:Any]()
                var dictionaryEndLocation = [Int:Any]()
                
                dictionaryStartLocation[0] = startLocation
                dictionaryEndLocation[0] = endLocation
                
                guard let steps = legs[0]["steps"] as? [[String:Any]] else { fatalError("steps not initialised") }
                
                // Loop: Because every such block contains the lat lng
                for temp in 0..<steps.count {
                    for (x,y) in steps[temp] {
                        if x == "start_location" {
                            dictionaryStartLocation[temp + 1] = y as? [String:Any]
                        }
                        else if x == "end_location" {
                            dictionaryEndLocation[temp + 1] = y as? [String:Any]
                        }
                    }
                }
                
                // Final conversion to the desired Dictionary for lat lng
                var temDic = [String:Any]()
                for tempIndex in 0..<dictionaryEndLocation.count {
                    temDic = dictionaryStartLocation[tempIndex] as! [String:Any]
                    self.latStartLocation.insert(temDic["lat"]!, at: tempIndex)
                    temDic = dictionaryEndLocation[tempIndex] as! [String:Any]
                    self.latEndLocation.insert(temDic["lat"]!, at: tempIndex)
                    
                    temDic = dictionaryStartLocation[tempIndex] as! [String:Any]
                    self.lngStartLocation.insert(temDic["lng"]!, at: tempIndex)
                    temDic = dictionaryEndLocation[tempIndex] as! [String:Any]
                    self.lngEndLocation.insert(temDic["lng"]!, at: tempIndex)
                }
            }
        })
        
        dataTask.resume()
        
    }
    
//=============================================================//
//MARK: myLoader Start and Stop Methods
//=============================================================//
    
    func startLoader() {
        
        self.myLoader.isHidden = false
        self.myLoader.startAnimating()
        self.myLoader.hidesWhenStopped = true
        
    }
    
    func stopLoader() {
        
        self.myLoader.stopAnimating()
        self.myLoader.isHidden = true
        
    }
    
    
}

//====================================================================//
//MARK: GoogleMapsAPIVC Extension for TableView Delegates and DataSource
//====================================================================//

extension GoogleMapsAPIVC: UITableViewDelegate,UITableViewDataSource {
    
//====================================================================//
//MARK: Setting Number of cell
//====================================================================//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.latStartLocation.count
    }
    
//====================================================================//
//MARK: Setting the view of the cell
//====================================================================//
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell") as? CustomCell else { fatalError("Custom Cell Failed to load") }
        cell.startLocation.text = "Start Location"
        cell.endLocation.text = "End Loaction"
        cell.latEnd.text = "\(self.latEndLocation[indexPath.row])"
        cell.latStart.text = "\(self.latStartLocation[indexPath.row])"
        cell.lngEnd.text = "\(self.lngEndLocation[indexPath.row])"
        cell.lngStart.text = "\(self.lngStartLocation[indexPath.row])"
        self.mapsDetailsTable.separatorStyle = .singleLine
        return cell
    }
    
//====================================================================//
//MARK: Setting the height of the cell
//====================================================================//
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
}

