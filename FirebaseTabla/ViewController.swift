//
//  ViewController.swift
//  FirebaseTabla
//
//  Created by Fernando Santana Falcón on 8/12/20.
//

import UIKit
import FirebaseDatabase
import CoreLocation
import UserNotifications


class ViewController: UIViewController {

    @IBOutlet weak var carta: UITableView!{
        didSet{
            carta.dataSource = self
        }
    }
   
    var databaseRef = Database.database().reference()  //referencia a la BD
    var menus = [Menu]() //array que contiene tipo menu
    
    var locationManager: CLLocationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.requestNotifications()
        
        let carta = Database.database().reference().child("Carta")  //referencia a carta
        carta.observe(.childAdded) { [weak self](snapshot) in
            let key = snapshot.key
            guard let value = snapshot.value as? [String: Any] else {return} //diccionario
            
            print("\(snapshot.key): \(snapshot.value!)")
            
            if let precio = value["Precio"] as? Double, let primerPlato = value["PrimerPlato"] as? String, let segundoPlato = value["SegundoPlato"] as? String, let postre = value["Postre"] as? String, let imagen = value["imagen"] as? String
            
            {
                let menu = Menu(nombre: key, precio: precio, primerPlato: primerPlato, segundoPlato: segundoPlato, postre: postre, imagen: imagen)
                self?.menus.append(menu)
                if let row = self?.menus.count{
                    let indexPath = IndexPath(row: row-1, section: 0)
                    self?.carta.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    //  Core Location inicialización
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.configLocationManager()
    }
    
    private func configLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "segueDetalle" {
            
            let DVC = segue.destination as! DetalleViewController
            
            if let indexPath = self.carta.indexPathForSelectedRow{
                
                let nombreMaestro = self.menus[indexPath.row].nombre
                DVC.campoNombre = nombreMaestro
                
                let precioMaestro = self.menus[indexPath.row].precio
                DVC.campoPrecio = precioMaestro
                
                let primerPlatoMaestro = self.menus[indexPath.row].primerPlato
                DVC.campoPrimerPlato = primerPlatoMaestro
                
                let segundoPlatoMaestro = self.menus[indexPath.row].segundoPlato
                DVC.campoSegundoPlato = segundoPlatoMaestro
                
                let postreMaestro = self.menus[indexPath.row].postre
                DVC.campoPostre = postreMaestro
                
                let imagenMaestro = self.menus[indexPath.row].imagen
                DVC.campoImagen = imagenMaestro

            }
        }
    }
    // MARK: -Configuración Beacon

// Cazar Beacon
private func startScanning() {
    let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
    let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 123, minor: 456, identifier: "Casitas")
   
    self.locationManager.allowsBackgroundLocationUpdates = true
    self.locationManager.pausesLocationUpdatesAutomatically = false
    self.locationManager.startMonitoring(for: beaconRegion)
    self.locationManager.startRangingBeacons(in: beaconRegion)
    self.locationManager.startUpdatingLocation()
}

// Actualizar Ubicación del Beacon
private func actualizarPosicion(_ distancia: CLProximity) {
    print("Actualización de posición")
    UIView.animate(withDuration: 0.8) {
        switch distancia {
        case .unknown:
            print("Beacon no detectada")
        case .far:
            self.scheduleNotifications(title: "Bienvenido!", messageBody: "Entra en la app para observar los menus del día!!")
            print("Lejos del Beacon.")
        case .near:
            print("Cerca del Beacon.")

        case .immediate:
            print("En el Beacon.")

        @unknown default:
            print("Beacon no encontrado. \(distancia)")
        }
    }
}

    // MARK: - Notificaciones
private func requestNotifications() {
    if #available(iOS 10.0, *) {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if granted {
                print("El usuario ha aceptado las notificaciones!!")
            } else {
                print("El usuario ha denegado las notificaciones!!")
            }
        }
    } else {
        //<iOS 10
        print("iOS menor a 10.0, notificaciones no disponibles!")
        self.pushLocalNotification(title: "Actualiza!", messageBody: "Las notifaciones solo estarán disponible despues de iOS 10")
    }
}

private func pushLocalNotification(title: String, messageBody: String) {
    if #available(iOS 10.0, *) {
        
//            1.requerimos los permisos y referencia al centro de notificaciones
        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()  //elimina notificaciones pendientes en otros hilos
        center.removeAllDeliveredNotifications() //elimina notificaciones de la app en el Centro de Notificaciones
        
//                    2.Creamos el contenido de la notificacion
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = messageBody
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
//                 3. Crear el trigger de la notificacion
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
//                 4. Crear el Request
        let notificationRequest = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//                  5.Registrar el request con el centro de notificacion
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Fallo añadiendo Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    } else {
        // < iOS 10.0
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1) as Date
        notification.alertBody = messageBody
        notification.alertAction = title
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.shared.scheduleLocalNotification(notification)
    }
}

private func scheduleNotifications(title: String, messageBody: String) {
    if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.pushLocalNotification(title: title, messageBody: messageBody)
                print("envía notifica")
            }
            else {
                // Las notificaciones estan denegadas o sin determinar
                self.redireccionamientoAjustes(alertMessage: "Permita las notificaciones para poder usar todas las características de nuestra App.")
            }
        }
    } else {
        //<iOS 10
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications {
            self.pushLocalNotification(title: title, messageBody: messageBody)
        } else {
            // Las notificaciones estan denegadas o sin determinar
            self.redireccionamientoAjustes(alertMessage: "Permita las notificaciones para poder usar todas las características de nuestra App.")
        }
        self.pushLocalNotification(title: title, messageBody: messageBody)
    }
}

        
    // MARK: -Redireccionamiento a ajustes para cambiar ajustes de la app.
private func redireccionamientoAjustes(alertMessage: String) {
    
    let alertController = UIAlertController (title: "CUIDADO", message: alertMessage, preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(title: "Ir a Ajustes", style: .default) { (_) -> Void in
        
        guard let ajustesURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(ajustesURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(ajustesURL, completionHandler: { (success) in
                    print("Ajustes abierto: \(success)") // True
                })
            } else {
                // <iOS 10
                UIApplication.shared.openURL(ajustesURL)
            }
        }
    }
    
    alertController.addAction(settingsAction)
    let cancelAction = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
    alertController.addAction(cancelAction)
    if presentedViewController == nil {
        self.present(alertController, animated: true, completion: nil)
    } else{
        self.dismiss(animated: false) {
            self.present(alertController, animated: true, completion: nil)
        }
    }
  }

}

// MARK: - TableView de la Carta

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = menus[indexPath.row]
        let  cell = carta.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.textLabel?.text = menu.nombre
        cell.detailTextLabel?.text = String(menu.precio ) + "€"
        
        return cell
    }
    
}

// MARK: - Ubicación
    extension ViewController: CLLocationManagerDelegate {
        
        //Permisos de ubicación
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

            switch status {
            case .denied:
                print("El usuario denegó el seguimiento de su ubicación.")
                self.redireccionamientoAjustes(alertMessage:  "Permita acceso a su ubicación para poder usar las funcionalidades de la app.")
                
            case .notDetermined:
                print("Permisos de ubicación no determinados.")

            case .restricted:
                print("Permisos de ubicación restringidos.")
                self.redireccionamientoAjustes(alertMessage:  "Permita acceso a su ubicación para poder usar las funcionalidades de la app.")

            case .authorizedWhenInUse:
                print("El usuario aceptó el seguimiento de su ubicación mientra usa la app.")
                self.redireccionamientoAjustes(alertMessage: "Acepte el seguimiento de su ubicación todo el tiempo para obtener mejores resultados.")

            case .authorizedAlways:
                print("Permiso de ubicación aceptado!!")
                DispatchQueue.main.async { [weak self] in
                    if let strongSelf = self {
                        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                            if CLLocationManager.isRangingAvailable() {
                                strongSelf.startScanning()
                                return
                            }
                        } else {
                            print("Ubicación no en contrada!")
                        }
                    }
                }
            default:
                print("Nada encontrado")
            }
        }
    
        //Ubicación del dispositivo
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                let locValue:CLLocationCoordinate2D = manager.location!.coordinate
                print("Ubicación:  \(locValue.latitude) \(locValue.longitude)")
            }
        
        //Regiones monitorizadas
        func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
            print("Los datos de las Beacon controladas son: \(manager.monitoredRegions)")
        }
        
        //ESTADO DEL BEACON DENTRO DE LA REGION
        func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
            print("control inside state")
        }

        //entrada DE REGION
        func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
            manager.startUpdatingLocation()
            print("control en didEnterRegion")
        }
        
        //salida DE REGION
        func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            manager.stopRangingBeacons(in: region as! CLBeaconRegion)
            manager.stopUpdatingLocation()
            print("control en didExitRegion")
        }

        func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
            
            //IMPRIME NUMERO DE BEACONS
            print("control en didrangebeacons \(beacons.count)")

            //ACTUALIZACION DE POSICION SI HAY BEACONS
            if beacons.count > 0 {
                actualizarPosicion(beacons[0].proximity)
            } else {
                actualizarPosicion(.unknown)
            }
        }
      
    }

// MARK: - Notificaciones
extension ViewController: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}
