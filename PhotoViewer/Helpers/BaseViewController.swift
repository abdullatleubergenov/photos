import UIKit

typealias View = UIView

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .secondarySystemBackground
        setupSubviews()
    }

}

@objc extension BaseViewController {
    
    func setupSubviews() {
        embedSubviews()
        setSubviewsConstraints()
    }
    
    func embedSubviews() {}
    func setSubviewsConstraints() {}
    
}
