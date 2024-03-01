//
//  ViewModel.swift
//  Immersive Ball Shooter
//
//  Created by Henry Lam on 29/2/2024.
//
import Foundation
import RealityKit

class ViewModel {
    private var contentEntity = Entity()
    private let colors: [PhysicallyBasedMaterial.Color] = [
        .gray, .orange, .yellow, .red, .blue, .purple, .brown, .blue, .cyan, .magenta, .white
    ]
    
    func setupContentEntity() -> Entity {
        return contentEntity
    }
    
    func getTargetEntity(name: String) -> Entity? {
        return contentEntity.children.first { $0.name == name }
    }
    
    func addCube(name: String, greenball: String? = nil) -> Entity {
        let color: PhysicallyBasedMaterial.Color = greenball == "true" ? .green : colors.randomElement()!
        
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: color)
        material.roughness = 0.4
        material.metallic = 0.2

        let entity = ModelEntity(
            mesh: .generateBox(size: 1, cornerRadius: 9999),
            materials: [material],
            collisionShape: .generateBox(size: SIMD3<Float>(repeating: 0.5)),
            mass: 0.0
        )
        
        entity.name = name
        entity.components.set(InputTargetComponent(allowedInputTypes: .indirect))
        entity.components.set(HoverEffectComponent())
        
        let physicsMaterial = PhysicsMaterialResource.generate(friction: 0.8, restitution: 0.0)
        entity.components.set(PhysicsBodyComponent(shapes: entity.collision!.shapes, mass: 0.0, material: physicsMaterial, mode: .dynamic))
        
        entity.position = getRandomPosition()
        
        let go = FromToByAnimation<Transform>(
            name: "go",
            from: .init(scale: .init(repeating: 1), translation: entity.position),
            to: .init(
                scale: .init(repeating: 1),
                translation: getRandomPosition()
            ),
            duration: 30,
            bindTarget: .transform
        )
        
        let goAnimation = try! AnimationResource.generate(with: go)
        let animation = try! AnimationResource.sequence(with: [goAnimation, goAnimation, goAnimation])
        
        entity.playAnimation(animation, transitionDuration: 30)
        
        contentEntity.addChild(entity)
        
        return entity
    }
    
    func changeToRandomColor(entity: Entity) {
        guard let modelEntity = entity as? ModelEntity else { return }
        modelEntity.model?.materials = [SimpleMaterial(color: colors.randomElement()!, isMetallic: false)]
    }
    
    func removeModel(entity: Entity) -> Bool {
        guard let modelEntity = entity as? ModelEntity else { return false }
        
        if let material = modelEntity.model?.materials.first as? PhysicallyBasedMaterial,
           "\(material.baseColor.tint)".contains("0 1 0 1") {
               let fadeOut = FromToByAnimation<Transform>(
                   name: "fadeOut",
                   from: .init(scale: .init(repeating: 1), translation: entity.position),
                   to: .init(scale: .init(repeating: 0), translation: entity.position),
                   duration: 0.5,
                   timing: .easeOut,
                   bindTarget: .transform
               )
               let fadeOutAnimation = try! AnimationResource.generate(with: fadeOut)
               let animation = try! AnimationResource.sequence(with: [fadeOutAnimation])
               
               modelEntity.playAnimation(animation, transitionDuration: 0.3)
               return true
        } else {
               modelEntity.model?.mesh = .generateBox(size: 2, cornerRadius: 9999)
               return false
        }
    }
    
    private func getRandomPosition() -> SIMD3<Float> {
        return SIMD3(
            x: Float.random(in: -10...10),
            y: Float.random(in: -10...10),
            z: Float.random(in: -10...10)
        )
    }
}
