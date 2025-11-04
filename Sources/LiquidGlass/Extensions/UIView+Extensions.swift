import SwiftUI

internal extension UIView {
    func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
    
    func allSubviews<T: UIView>(ofType type: T.Type) -> [T] {
        var result = [T]()
        
        for subview in subviews {
            if let match = subview as? T {
                result.append(match)
            }
            result.append(contentsOf: subview.allSubviews(ofType: type))
        }
        
        return result
    }
}
