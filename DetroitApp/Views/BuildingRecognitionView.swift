//
//  BuildingRecognitionView.swift
//  DetroitApp
//
//  Created by Blair Myers on 5/2/24.
//

import SwiftUI
import ARKit
import Vision

struct BuildingRecognitionView: View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator  // Set the delegate to the coordinator
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update the view during SwiftUI state changes
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: ARViewContainer

        init(_ parent: ARViewContainer) {
            self.parent = parent
        }

        func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            guard let arView = renderer as? ARSCNView,
                  let currentFrame = arView.session.currentFrame else { return }

            let pixelBuffer = currentFrame.capturedImage
            parent.performImageRecognition(pixelBuffer)
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            DispatchQueue.main.async {
                if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
                    let planeNode = SCNNode()
                    // Customize your plane node here
                    node.addChildNode(planeNode)
                }
            }
        }
    }
    
    func performImageRecognition(_ pixelBuffer: CVPixelBuffer) {
        guard let model = try? VNCoreMLModel(for: DetroitVenuesModel_2().model) else { return }
        let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
            DispatchQueue.main.async {
                if let results = vnRequest.results as? [VNClassificationObservation] {
                    let topResult = results.first
                    print("Top classification result: \(topResult?.identifier ?? "unknown")")
                }
            }
        }
        request.imageCropAndScaleOption = .centerCrop  // Adjust this according to your model's training
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification.\n\(error.localizedDescription)")
        }
    }
}

struct BuildingRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingRecognitionView()
    }
}
