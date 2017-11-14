//
//  ViewController.swift
//  tryARKitWithMagicaVoxel
//
//  Created by kenta.imai on 2017/10/31.
//  Copyright © 2017年 henteko07. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Zip
import Alamofire

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    @IBAction func tap(_ recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: .featurePoint)
        guard let hitResult = results.first else { return }
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory)
        Alamofire.download("https://s3-ap-northeast-1.amazonaws.com/miso-lab-c93/henteko/miso-lab-kun.zip", to: destination).response { response in
            let downloadZipURL = response.destinationURL
            
            do {
                let filePath = try Zip.quickUnzipFile(downloadZipURL!)

                let node = SCNNode()
                let dir = filePath.appendingPathComponent("miso-lab-kun/miso-lab-kun.scn")
                let idleScene = try SCNScene.init(url: dir, options: nil)

                let texData = try Data.init(contentsOf: (filePath.appendingPathComponent("miso-lab-kun/miso-lab-kun_tex.png")))
                let material = SCNMaterial()
                material.diffuse.contents = UIImage(data: texData)

                for child in idleScene.rootNode.childNodes {
                    child.geometry?.firstMaterial = material
                    node.addChildNode(child)
                }

                node.position = SCNVector3Make(hitResult.worldTransform.columns.3.x,
                                               hitResult.worldTransform.columns.3.y + 0.1,
                                               hitResult.worldTransform.columns.3.z)
                self.sceneView.scene.rootNode.addChildNode(node)
            } catch let e {
                print(e)
            }
        }
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
