# Chrono-Step 2D

A high-precision, modular 2D action-platformer framework built in **Godot 4**. Designed around deterministic kinematic control, decoupled combat/visual pipelines, and extensible state-driven mobility.

## Core Architectural Pillars

- **Data-Driven Kinematics (MovementData):** Custom Resource definitions decouple physical tuning (acceleration curves, friction, terminal velocity, coyote windows, and dash vectors) from state execution logic.
- **Hierarchical Finite State Machine (StateMachine):** Node-based FSM managing clean state lifecycles (GroundState, AirState, DashState, DashJumpState) with strict separation of concerns.
- **Momentum-Preserving Aerial Trajectories (DashJumpState):** Specialized aerial state inheriting from AirState to preserve horizontal dash inertia across jumps without premature air-drag clamping.
- **Frame-Accurate Input Buffering (InputBuffer):** Pre-landing action queuing and Coyote Time validation to guarantee responsive execution under high-tempo platforming.
- **Decoupled Slope Alignment & Ledge Normal Filtering (SlopePivot):** Separates the upright physical environment collider (WorldCollision) from rotatable sub-trees (Visuals and HurtboxComponent). Uses bottom-hemisphere pivot invariance and direct space-state vertical raycasting (PhysicsDirectSpaceState2D.intersect_ray) to align smoothly with terrain normals while eliminating false angular tilting on 90-degree ledge vertices.
- **Precision Camera Pipeline (CameraTarget):** Intermediate tracking proxy integrated with PhantomCamera2D, featuring a horizontal deadzone precision window (precision_window_x) and velocity-driven lookahead (max_lookahead_speed).
- **Modular Combat Components (HitboxComponent / HurtboxComponent):** Decoupled Area2D combat nodes. HurtboxComponent operates as an independent sibling to Visuals under SlopePivot, inheriting 1:1 angular slope alignment without being distorted by visual squash-and-stretch scaling.

## Project Structure

```
text
res://
├── node_2d.tscn                         # Movement Gym & integration testbed
└── src/
    ├── actors/
    │   └── player/
    │       ├── player_controller.gd     # Root CharacterBody2D orchestrator
    │       ├── slope_pivot.gd           # Bottom-anchored slope alignment & raycast filter
    │       ├── camera_target.gd         # Precision window & dynamic lookahead proxy
    │       └── states/                  # Modular FSM states (Ground, Air, Dash, DashJump)
    ├── combat/
    │   ├── hitbox_component.gd          # Modular damage dealer Area2D
    │   └── hurtbox_component.gd         # Modular damage receiver Area2D
    └── core/
        ├── movement_data.gd             # Kinematic configuration Resource
        ├── input_buffer.gd              # Action lookahead & coyote timer manager
        └── state_machine.gd             # Base FSM controller & state interface
```
