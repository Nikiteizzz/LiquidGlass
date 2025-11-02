import SwiftUI

final class NonRenderableHostingView<Content: View>: UIView {
    override class var layerClass: AnyClass {
        NonRenderableLayer.self
    }
    
    private var hostingController: UIHostingController<Content>?
    
    var content: () -> Content
    
    init(content: @escaping () -> Content) {
        self.content = content
        super.init(frame: .zero)
        
        setupStyle()
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard
            let parentViewController = self.parentViewController(),
            let hostingController
        else { return }
        
        parentViewController.addChild(hostingController)
        hostingController.didMove(toParent: parentViewController)
    }
    
    private func setupStyle() {
        backgroundColor = .clear
    }
    
    private func setupHostingController() {
        let hostingController = UIHostingController(rootView: content())
        self.hostingController = hostingController
        
        setupHostingView()
    }
    
    private func setupHostingView() {
        guard
            let hostingView = hostingController?.view
        else { return }
        
        hostingView.backgroundColor = .clear
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(hostingView)
        
        addConstraints([
            hostingView.topAnchor.constraint(equalTo: topAnchor),
            hostingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingView.widthAnchor.constraint(equalTo: widthAnchor),
            hostingView.heightAnchor.constraint(equalTo: heightAnchor),
        ])
    }
}

struct NonRenderableHostingViewRepresentable<Content: View>: UIViewRepresentable {
    var content: () -> Content
    
    func makeUIView(context: Context) -> NonRenderableHostingView<Content> {
        .init(content: content)
    }
    
    func updateUIView(_ uiView: NonRenderableHostingView<Content>, context: Context) { }
}
