import UIKit

extension Array where Element: UIView {
    @MainActor
    func intersectingViews() -> [UIView] {
        var result: Set<Element> = []
        for i in 0..<self.count {
            guard let window = self[i].window else { continue }
            let frame1 = self[i].convert(self[i].bounds, to: window)
            
            for j in (i + 1)..<self.count {
                guard let window2 = self[j].window, window2 === window else { continue }
                let frame2 = self[j].convert(self[j].bounds, to: window2)
                
                if frame1.intersects(frame2) {
                    result.insert(self[i])
                    result.insert(self[j])
                }
            }
        }
        
        return Array(result)
    }
}
