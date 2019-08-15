//
//  GNGScene.swift
//  GNG
//
//  Created by André Valdivia on 8/14/19.
//  Copyright © 2019 Andre Valdivia. All rights reserved.
//

import Foundation
import UIKit

class MainViewController: UIViewController{
    
    let spiralButton = UIButton(type: .system)
    let test3DButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        
        spiralButton.setTitle("Spiral", for: .normal)
        test3DButton.setTitle("Test 3D", for: .normal)
        
        view.backgroundColor = .white
        
//        let stackView = UIStackView(arrangedSubviews: [spiralButton, test3DButton])
        let stackView = UIStackView(arrangedSubviews: [spiralButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        spiralButton.addTarget(self, action: #selector(handleSpiralButton), for: .touchUpInside)
        test3DButton.addTarget(self, action: #selector(handleTest3DButton), for: .touchUpInside)
    }
    
    @objc func handleSpiralButton(){
        let gameViewController = GNGViewController(data: FileManager.spiral())
        navigationController?.pushViewController(gameViewController, animated: true)
    }
    
    @objc func handleTest3DButton(){
        let data = Data(dimension: 3, classes: nil)
        data.insert(data: [0,0,0], clase: 0)
        data.insert(data: [3,3,3], clase: 0)
        data.insert(data: [0,0,3], clase: 0)
        data.insert(data: [0,3,3], clase: 0)
        data.insert(data: [0,3,0], clase: 0)
        let gameViewController = GNGViewController(data: data)
        navigationController?.pushViewController(gameViewController, animated: true)
    }
}
