//
//  MissionMapTitleAnnotationView.swift
//  Mavsdk-Swift-Example
//
//  Created by Dmytro Malakhov on 7/26/21.
//

import Foundation
import MapKit
import Combine

class MissionMapTitleAnnotationView: MKAnnotationView {
    let label = UILabel(frame: CGRect(x: -100, y: -70, width: 200, height: 50))
    
    var cancellable = AnyCancellable {}
    
    init(annotation: MKAnnotation?) {
        super.init(annotation: annotation, reuseIdentifier: "missionTitle")

        label.textAlignment = .center
        addSubview(label)
        
        cancellable = MissionOperator.shared.$currentMission
            .sink { [weak self] (mission) in
                self?.label.text = mission?.title
            }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
