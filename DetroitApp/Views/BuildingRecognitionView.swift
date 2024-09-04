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
    @State private var identifiedVenue: String? = nil
    @State private var showVenueEvents = false
    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                ARViewContainer(identifiedVenue: $identifiedVenue, showConfirmation: $showConfirmation)
                    .edgesIgnoringSafeArea(.all)
                    .navigationBarHidden(true)
                
                if showConfirmation, let venue = identifiedVenue {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showVenueEvents = true
                                ARViewContainer.stopSession = true
                            }) {
                                Text("View Events at \(venue)")
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                } else if !showConfirmation {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("No recognizable venue detected")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            Spacer()
                        }
                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $showVenueEvents, onDismiss: {
                identifiedVenue = nil
                showConfirmation = false
                ARViewContainer.stopSession = false
            }) {
                if let venue = identifiedVenue {
                    NavigationView {
                        VenueEventsView(venueName: venue)
                    }
                }
            }
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var identifiedVenue: String?
    @Binding var showConfirmation: Bool
    static var stopSession = false

    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        return arView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        if ARViewContainer.stopSession {
            uiView.session.pause()
        }
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
                  let currentFrame = arView.session.currentFrame,
                  !ARViewContainer.stopSession else { return }

            let pixelBuffer = currentFrame.capturedImage
            parent.performImageRecognition(pixelBuffer)
        }

        func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
            DispatchQueue.main.async {
                if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .horizontal {
                    let planeNode = SCNNode()
                    node.addChildNode(planeNode)
                }
            }
        }
    }

    func performImageRecognition(_ pixelBuffer: CVPixelBuffer) {
        if #available(iOS 17.0, *) {
            guard let model = try? VNCoreMLModel(for: DetroitVens().model) else { return }
            let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
                DispatchQueue.main.async {
                    if let results = vnRequest.results as? [VNClassificationObservation], let topResult = results.first {
                        if topResult.confidence > 0.80 {
                            self.identifiedVenue = topResult.identifier
                            self.showConfirmation = true
                        } else {
                            self.identifiedVenue = nil
                            self.showConfirmation = false
                        }
                    }
                }
            }
            request.imageCropAndScaleOption = .centerCrop
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
}

struct BuildingRecognitionView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingRecognitionView()
    }
}

