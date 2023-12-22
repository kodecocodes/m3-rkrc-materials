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
  @State private var goal: Entity?
  @State private var goalScored: EventSubscription?
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
        goal = content.entities.first?.findEntity(named: "Goal")
        goalScored = content.subscribe(to: CollisionEvents.Began.self, on: goal) { collisionEvent in
          print("Goal detected \(collisionEvent.entityA.name) and \(collisionEvent.entityB.name)")
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
