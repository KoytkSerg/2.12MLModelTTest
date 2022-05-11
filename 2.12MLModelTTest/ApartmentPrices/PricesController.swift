//
//  PricesController.swift
//  2.12MLModelTTest
//
//  Created by Sergii Kotyk on 25/1/2022.
//

import UIKit
import MapKit
import ObjectiveC

class PricesController: UIViewController {

    @IBAction func squareSlider(_ sender: Any) {
        squareLabel.text = "Площадь: \(Int(squareSlider.value))"
        resultLabel.text = "\(pricePredict(loc: annotation))"
    }
    
    @IBAction func roomsSlider(_ sender: Any) {
        roomsLabel.text = "Количество комнат: \(Int(roomsSlider.value))"
        resultLabel.text = pricePredict(loc: annotation)
    }
    @IBAction func floorSlider(_ sender: Any) {
        floorLabel.text = "Этаж: \(Int(floorSlider.value))"
        resultLabel.text = pricePredict(loc: annotation)
    }
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var floorSlider: UISlider!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomsSlider: UISlider!
    @IBOutlet weak var roomsLabel: UILabel!
    @IBOutlet weak var squareSlider: UISlider!
    @IBOutlet weak var squareLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let model = ApartmentPrices()
    let annotation = MKPointAnnotation()
    
    func pricePredict(loc: MKPointAnnotation) -> String{
        if annotation.coordinate.longitude != 0.0{
            let square = Double(squareSlider.value)
            let floor = Double(floorSlider.value)
            let rooms = Double(roomsSlider.value)
            let latitude = loc.coordinate.latitude
            let longitude = loc.coordinate.longitude
            let prediction = try? model.prediction(Square: square, Floor: floor, Rooms: rooms, Latitude: latitude, Longitude: longitude)
            let price = (prediction?.Price)!
            return "\(Int(price)) $"
        } else { return "" }
    }
    
    func defaultMapSetup(){
        mapView.centerToLocation(CLLocation(latitude: 48.49053, longitude: 32.25831), regionRadius: 9000)
        
        let kropCentr = CLLocation(latitude: 48.49053, longitude: 32.25831)
        let region = MKCoordinateRegion(center: kropCentr.coordinate, latitudinalMeters: 50000, longitudinalMeters: 60000)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: region), animated: true)
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 60000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
        
    }
    
    func defaultSlidersSetup(){
        mainView.layer.cornerRadius = 20
       
        
        floorSlider.maximumValue = 10
        floorSlider.minimumValue = 1
        floorSlider.value = 5
        floorLabel.text = "Этаж: \(Int(floorSlider.value))"
        
        roomsSlider.maximumValue = 10
        roomsSlider.minimumValue = 1
        roomsSlider.value = 2
        roomsLabel.text = "Количество комнат: \(roomsSlider.value)"
        
        roomsSlider.maximumValue = 10
        roomsSlider.minimumValue = 1
        roomsSlider.value = 2
        roomsLabel.text = "Количество комнат: \(Int(roomsSlider.value))"
        
        squareSlider.maximumValue = 100
        squareSlider.minimumValue = 1
        squareSlider.value = 40
        squareLabel.text = "Площадь: \(Int(squareSlider.value))"
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        if let lastAnnotation = mapView.annotations.last{
            mapView.removeAnnotation(lastAnnotation)
        }

        annotation.coordinate = location
        annotation.title = "place"
        resultLabel.text = pricePredict(loc: annotation)
        self.mapView.addAnnotation(annotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaultSlidersSetup()
        defaultMapSetup()
        print(annotation.coordinate.longitude)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
            mapView.addGestureRecognizer(longTapGesture)


    }

}

extension MKMapView {
    
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
      let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
          setRegion(coordinateRegion, animated: true)
    }
}
extension PricesController: UIGestureRecognizerDelegate{

}

extension PricesController: MKMapViewDelegate{


}

