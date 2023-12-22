//
//  ImmersiveView.swift
//  QHoops
//
//  Created by Tim Mitra on 2023-12-20.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
  @State private var goalEntity: Entity?
  @State private var confetti: Entity?
  @State private var cheering: Entity?
  @State private var goalScored: EventSubscription?
  @State private var goalCelebration: Bool = false
  var body: some View {
    RealityView { content in
      // Add the initial RealityKit content
      if let scene = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
        content.add(scene)
        /* Occluded floor */
        let floor = ModelEntity(mesh: .generatePlane(width: 100, depth: 100), materials: [OcclusionMaterial()])
        floor.generateCollisionShapes(recursive: false)
        floor.components[PhysicsBodyComponent.self] = .init(
          massProperties: .default,
          mode: .static
        )
        content.add(floor)
        // detect a goal
        confetti = content.entities.first?.findEntity(named: "ConfettiEmitter")
        confetti?.components.set(OpacityComponent(opacity: 0.0))
        goalEntity = content.entities.first?.findEntity(named: "Goal")
        goalEntity?.components.set(OpacityComponent(opacity: 0.0))
        goalScored = content.subscribe(to: CollisionEvents.Began.self, on: goalEntity) { collisionEvent in
          print("Goal detected \(collisionEvent.entityA.name) and \(collisionEvent.entityB.name)")
          goalCelebration = true
        }
        /* I need to research this some more.
        guard let cheering = content.entities.first?.findEntity(named: "cheering"),
              let resource = try? await AudioFileResource(named: "/Root/Resources/cheering-and-clapping-crowd-1-5995.mp3") else { return }
        let audioPlaybackController = cheering.prepareAudio(resource)
        audioPlaybackController.play()
         */
      }
    } update: { content in
      if let _ = content.entities.first {
        if goalCelebration == true {
          confetti?.components.set(OpacityComponent(opacity: 1.0))
        }
      }
    }
    .gesture(dragGesture)
    .gesture(tapGesture)
  }
  var dragGesture: some Gesture {
    DragGesture()
      .targetedToAnyEntity()
      .onChanged { value in
        value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
        value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
      }
  }
  var tapGesture: some Gesture {
    TapGesture()
      .targetedToAnyEntity()
      .onEnded { value in
        // do nothing
        value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic
        value.entity.components[PhysicsMotionComponent.self]?.linearVelocity = [0,-20,-5]
      }
  }
}

#Preview {
  ImmersiveView()
    .previewLayout(.sizeThatFits)
}
