# ChronoStep 2D — Deterministic-Feel Action Platformer Framework (Godot 4)

ChronoStep 2D is a modular kinematic character controller and combat foundation built in GDScript for Godot 4.x. It focuses on responsive, frame-accurate movement mechanics tailored for fast-paced 2D action platformers.

## Architecture & Engineering Trade-offs

* **Data-Driven Kinematics (`MovementData`):** Physics parameters are decoupled from state logic via custom `Resource` files, allowing hot-swapping movement profiles without mutating controller state.
* **Typed Finite State Machine (`StateMachine`):** Strictly typed node-based states eliminate deep conditional branching inside `_physics_process` while maintaining deterministic state transitions.
* **Sub-pixel & Raycast Corner Correction:** Uses `test_move` transformation sweeps during upward velocity frames to nudge the collision hull around pixel ledges without breaking vertical momentum.
* **Timestamp Input Buffering (`InputBuffer`):** Replaces frame-dependent timers with millisecond tick evaluation (`Time.get_ticks_msec()`) to ensure consistent jump and dash windows across variable frame rates.

## Current Roadmap (Active Development)

- [ ] Implement `HurtboxComponent` with invulnerability frames (i-frames) and hit-stop freeze frames.
- [ ] Add directional downward slash pogo physics integration in `AirState`.
- [ ] Build automated GDScript unit tests for state transition edge cases.
- [ ] Implement surface-dependent friction overrides (ice, slopes, moving platforms).
