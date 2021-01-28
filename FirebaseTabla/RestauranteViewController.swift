//
//  RestauranteViewController.swift
//  FirebaseTabla
//
//  Created by Fernando Santana Falcón on 29/12/20.
//

import UIKit

class RestauranteViewController: UIViewController {

    @IBOutlet weak var boton: UIButton!
    @IBAction func botonPulsado(_ sender: UIButton) {
        self.redireccionamientoAjustes(alertMessage: "Permita el acceso a su ubicación y acepte las notificaciones para mejores resultados")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
