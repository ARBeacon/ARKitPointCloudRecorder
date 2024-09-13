//
//  ARFrameManager.swift
//  ARFrameRecorder
//
//  Created by Maitree Hirunteeyakul on 9/13/24.
//

import Foundation
import ARKit

struct ARFrameData: Encodable{
    var timestamp: TimeInterval
    var camera: ARCamera
    var rawFeaturePoints: ARPointCloud?
    
    enum CodingKeys: String, CodingKey {
        case timestamp, camera, rawFeaturePoints
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(camera, forKey: .camera)
        if let points = rawFeaturePoints{
            try container.encode(points, forKey: .rawFeaturePoints)
        }
    }
}

class ARFrameManager {
    private var arFramesData: [ARFrameData] = []
    
    private static var instance: ARFrameManager?
    static func get() -> ARFrameManager {
        if let instance = instance {
            return instance
        } else {
            let newInstance = ARFrameManager()
            instance = newInstance
            return newInstance
        }
    }
    
    public func addFrame(arFrame: ARFrame){
        self.arFramesData.append(ARFrameData(timestamp: arFrame.timestamp, camera: arFrame.camera, rawFeaturePoints: arFrame.rawFeaturePoints))
    }
    
    public func save() async {
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss" // Example format: "2024-10-03_14-22-30"
        let dateTimeString = formatter.string(from: currentDateTime)
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("\(dateTimeString).json")
            
            do {
                let data = try JSONEncoder().encode(self.arFramesData)
                try data.write(to: fileURL, options: .atomic)
                print("File saved: \(fileURL)")
            } catch {
                print("Error saving file: \(error.localizedDescription)")
            }
        }
        
        self.arFramesData = [];
    }
    
}

extension ARPointCloud: Encodable  {
    enum CodingKeys: String, CodingKey {
        case points, identifiers
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(points, forKey: .points)
        try container.encode(identifiers, forKey: .identifiers)
    }
}

extension ARCamera: Encodable {
    enum CodingKeys: String, CodingKey {
        case transform, eulerAngles
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(transform, forKey: .transform)
        try container.encode(eulerAngles, forKey: .eulerAngles)
    }
}


extension simd_float4x4: Encodable {
    enum CodingKeys: String, CodingKey {
        case columns
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let columnsArray = [
            [columns.0.x, columns.0.y, columns.0.z, columns.0.w],
            [columns.1.x, columns.1.y, columns.1.z, columns.1.w],
            [columns.2.x, columns.2.y, columns.2.z, columns.2.w],
            [columns.3.x, columns.3.y, columns.3.z, columns.3.w]
        ]
        
        try container.encode(columnsArray, forKey: .columns)
    }
}
