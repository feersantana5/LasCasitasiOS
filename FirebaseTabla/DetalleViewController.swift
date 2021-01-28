//
//  DetalleViewController.swift
//  FirebaseTabla
//
//  Created by Fernando Santana Falcón on 27/12/20.
//

import UIKit
import FirebaseStorage

class DetalleViewController: UIViewController {
    
    @IBOutlet weak var nombreDetalle:UILabel!
    @IBOutlet weak var precioDetalle:UILabel!
    @IBOutlet weak var primerPlatoDetalle:UILabel!
    @IBOutlet weak var segundoPlatoDetalle:UILabel!
    @IBOutlet weak var postreDetalle:UILabel!
    @IBOutlet weak var imagenDetalle: UIImageView!
    
    var campoNombre:String!
    var campoPrecio:Double!
    var campoPrimerPlato:String!
    var campoSegundoPlato:String!
    var campoPostre:String!
    var campoImagen:String!
    
    // Initialize Storage
    var storage = Storage.storage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title =  campoNombre

        nombreDetalle.text = campoNombre
        primerPlatoDetalle.text = campoPrimerPlato
        precioDetalle.text = String(campoPrecio) + " €"
        segundoPlatoDetalle.text = campoSegundoPlato
        postreDetalle.text = campoPostre
        
        // Create a storage reference from the URL
        let storageRef = storage.reference(forURL: campoImagen)
          // Download the data, assuming a max size of 1MB
        storageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            // Create a UIImage, add it to the array
            let pic = UIImage(data: data!)
            self.imagenDetalle.image = pic
          }
    }
    
}

