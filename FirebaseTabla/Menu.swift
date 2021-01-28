//
//  Menu.swift
//  FirebaseTabla
//
//  Created by Fernando Santana Falcón on 27/12/20.
//

import Foundation

class Menu {
    var nombre: String
    var precio: Double
    var primerPlato: String
    var segundoPlato: String
    var postre: String
    var imagen: String

    
    init(nombre: String, precio: Double, primerPlato: String, segundoPlato: String,  postre: String, imagen: String) {
        self.nombre = nombre
        self.precio = precio
        self.primerPlato = primerPlato
        self.segundoPlato = segundoPlato
        self.postre = postre
        self.imagen = imagen
    }
}
