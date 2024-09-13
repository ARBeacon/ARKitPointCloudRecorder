//
//  ContentView.swift
//  ARFrameRecorder
//
//  Created by Maitree Hirunteeyakul on 9/13/24.
//

import SwiftUI
import SceneKit
import ARKit

struct ContentView: View {
    @StateObject private var arViewModel = ARViewModel()
    @State private var isSaving = false
    @State private var showSaveCompletePopup = false
    
    private func displaySaveCompletePopup(){
        withAnimation {
            showSaveCompletePopup = true
        }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showSaveCompletePopup = false
                }
            }
        
    }
    
    var body: some View {
        ZStack {
            ARViewContainer(arViewModel: arViewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                Spacer()
                Button(action: {
                    isSaving = true
                    Task{
                        await arViewModel.flush()
                        isSaving = false
                    }
                    displaySaveCompletePopup()
                }) {
                    Text("Flush")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isSaving)
                .padding()
                
            }
            
            if showSaveCompletePopup {
                HStack {
                    Spacer()
                    VStack{
                        Text("Saved").font(.title3)
                        Text("Your ARFrames was saved and the ARSession was reinitiated")
                    }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Spacer()
                    
                }
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                .zIndex(1)
            }
        }
    }
}

class ARViewModel: NSObject, ObservableObject {
    @Published var sceneView: ARSCNView?
    
    override init() {
        super.init()
        sceneView = makeARView()
    }
    
    func makeARView() -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = self
        sceneView.session.delegate = self
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: [.removeExistingAnchors,.resetSceneReconstruction,.resetTracking])
        return sceneView
    }
    
    func flush() async {
        await sceneView?.session.pause()
        
        await ARFrameManager.get().save()
        
        DispatchQueue.main.async {
            guard let sceneView = self.sceneView else { return }
            
            sceneView.scene.rootNode.childNodes.forEach { $0.removeFromParentNode() }
            
            let configuration = ARWorldTrackingConfiguration()
            sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetSceneReconstruction, .resetTracking])
        }
    }
}

extension ARViewModel: ARSessionDelegate, ARSCNViewDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.main.async {
            self.plotFeaturePoints(frame: frame)
        }
        ARFrameManager.get().addFrame(arFrame: frame)
    }
    
    private func plotFeaturePoints(frame: ARFrame) {
        guard let rawFeaturePoints = frame.rawFeaturePoints else { return }
        
        let points = rawFeaturePoints.points
        
        sceneView?.scene.rootNode.childNodes.filter { $0.name == "FeaturePoint" }.forEach { $0.removeFromParentNode() }
        
        let sphereNode = SCNNode(geometry: SCNSphere(radius: 0.002))
        sphereNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        
        points.forEach { point in
            let clonedSphereNode = sphereNode.clone()
            clonedSphereNode.name = "FeaturePoint"
            clonedSphereNode.position = SCNVector3(point.x, point.y, point.z)
            sceneView?.scene.rootNode.addChildNode(clonedSphereNode)
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arViewModel: ARViewModel
    
    func makeUIView(context: Context) -> ARSCNView {
        return arViewModel.sceneView ?? ARSCNView()
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
}

#Preview {
    ContentView()
}
