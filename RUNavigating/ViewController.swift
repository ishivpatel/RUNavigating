//
//  ViewController.swift
//  RUNavigating
//
//  Created by dsc on 4/21/17.
//  Copyright © 2017 Digital Scholarship Center. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CLLocationManagerDelegate,
                    UIPickerViewDataSource, UIPickerViewDelegate {
    
   
    
    var buildings = [Building(name: "", latitude: 0.0, longitude: 0.0)]
    let pickerfrom = UIPickerView()
    let pickerto = UIPickerView()
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        
        return buildings.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == pickerfrom{
            startLocation.text = buildings[row].name
            self.view.endEditing(false)
            start =  CLLocation(latitude: buildings[row].latitude, longitude: buildings[row].longitude)
            
        }else{
            endLocation.text = buildings[row].name
            self.view.endEditing(false)
            end = CLLocation(latitude: buildings[row].latitude, longitude: buildings[row].longitude)

        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return buildings[row].name
    }
    
    
    
    @IBAction func navigate(_ sender: Any) {
        
        self.drawPath(startLocation: start, endLocation: end)
    }
    
    @IBOutlet var endLocation: UITextField!
    @IBOutlet var startLocation: UITextField!
    var start = CLLocation()
    var end = CLLocation()
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    @IBOutlet weak var googleMap: GMSMapView!
    
    func generateBuildings(){
        //TODO ADD Buildings
        let b1 = Building(name: "Robinson", latitude: 39.710666, longitude: -75.120227)
        buildings.append(b1)
        let b2 = Building(name: "James", latitude: 39.711692, longitude: -75.119317)
        buildings.append(b2)
        let b3 = Building(name: "Science", latitude: 39.709876, longitude: -75.120658)
        buildings.append(b3)
        let b4 = Building(name: "Library", latitude: 39.709266, longitude: -75.119016)
        buildings.append(b4)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        generateBuildings()
        startLocation.inputView = pickerfrom
        endLocation.inputView = pickerto
        
        //self.googleMap.delegate = self
        
        
        
        googleMap.addObserver(self, forKeyPath: "myLocation",
                              options: NSKeyValueObservingOptions.new,
                              context: nil)
        
        let camera = GMSCameraPosition.camera(withLatitude: 39.709084 , longitude: -75.119007, zoom: 15.0)
        
        self.googleMap.settings.zoomGestures = true
        self.googleMap.settings.myLocationButton = true
        self.googleMap.settings.compassButton = true
        self.googleMap.settings.zoomGestures = true
        self.googleMap.camera = camera
        
        pickerfrom.delegate = self
        pickerfrom.dataSource = self
        pickerto.delegate = self
        pickerto.dataSource = self
        
    }

    
    private func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            self.googleMap.isMyLocationEnabled = true
            
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
    
        if !didFindMyLocation {
            let myLocation: CLLocation = change![NSKeyValueChangeKey.newKey] as! CLLocation
            googleMap.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
            googleMap.settings.myLocationButton = true
            didFindMyLocation = true
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        googleMap.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        googleMap.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        googleMap.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        googleMap.isMyLocationEnabled = true
        googleMap.selectedMarker = nil
        return false
    }
    
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = titleMarker
        marker.icon = iconMarker
        marker.map = googleMap
    }
    
  
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation)
    {
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        
        createMarker(titleMarker: "Location Start", iconMarker: #imageLiteral(resourceName: "RUNavigationg_FinalMarker"), latitude: startLocation.coordinate.latitude, longitude: startLocation.coordinate.longitude)
        
         createMarker(titleMarker: "Location Start", iconMarker: #imageLiteral(resourceName: "RUNavigationg_FinalMarker"), latitude: endLocation.coordinate.latitude, longitude: endLocation.coordinate.longitude)
        
        googleMap.camera = GMSCameraPosition.camera(withLatitude: ((startLocation.coordinate.latitude + endLocation.coordinate.latitude)/2) , longitude: ((startLocation.coordinate.longitude + endLocation.coordinate.longitude)/2), zoom: 15.0)
        
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=walking"
        
        Alamofire.request(url).responseJSON { response in
            
            print(response.request as Any)  // original URL request
            print(response.response as Any) // HTTP URL response
            print(response.data as Any)     // server data
            print(response.result as Any)   // result of response serialization
            
            let json = JSON(data: response.data!)
            let routes = json["routes"].arrayValue
            
            // print route using Polyline
            for route in routes
            {
                let routeOverviewPolyline = route["overview_polyline"].dictionary
                let points = routeOverviewPolyline?["points"]?.stringValue
                let path = GMSPath.init(fromEncodedPath: points!)
                let polyline = GMSPolyline.init(path: path)
                polyline.strokeWidth = 4
                polyline.strokeColor = UIColor.red
                polyline.map = self.googleMap
            }
            
        }
    }
    
}

