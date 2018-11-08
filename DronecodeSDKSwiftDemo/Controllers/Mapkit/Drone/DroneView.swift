import MapKit

class DroneView: MKAnnotationView {

    init(annotation: MKAnnotation?) {
        super.init(annotation: annotation, reuseIdentifier: "drone")
        
        calloutOffset = CGPoint(x: -5, y: 5)

        image = UIImage(named: "annotation-drone")

        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.font = detailLabel.font.withSize(12)
        detailLabel.text = "drone"
        
        addSubview(detailLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
