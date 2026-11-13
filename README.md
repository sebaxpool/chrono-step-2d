# ChronoStep 2D - Modular Kinematic Framework for Godot 4

ChronoStep 2D is a decoupled, deterministic 2D platformer framework designed to showcase clean architecture, finite state machines (FSM), and precise physics math without relying on hardcoded template scripts.

## Core Architectural Modules

### 1. Data-Oriented Movement (`src/core/movement_data.gd`)
* **Purpose:** Inherits from `Resource` to decouple physics variables from character logic. 
* **Benefit:** Allows fine-tuning speeds, gravity multipliers, and assistive windows directly from the Godot Inspector without modifying source code.

### 2. Input Buffering System (`src/core/input_buffer.gd`)
* **Purpose:** Stores recent player actions using millisecond timestamps (`Time.get_ticks_msec()`).
* **Benefit:** Eliminates input dropping by allowing actions (like jumping right before hitting the floor) to execute cleanly.

### 3. Finite State Machine & Kinematics (`src/actors/player/`)
* **`PlayerController` (`CharacterBody2D`):** Acts as the central actor delegating physics to active states.
* **`GroundState` & `AirState`:** Manage standard movement, asymmetric gravity (higher fall multiplier than rise), and jump cuts.
* **`DashState` & `DashJumpState`:** Implements an advanced hierarchical state (HFSM) allowing horizontal explosive dashes (`dash_speed`) and mid-air *Dash Jumps* preserving momentum (Mega Man X style).
* **`Corner Correction`:** Automatically adjusts the player's horizontal position by a few pixels if their head brushes against the edge of a ceiling block during a jump.
* **`Coyote Time Extension`:** Automatically stretches the coyote window to match the exact `dash_duration` when initiating a dash from the edge of a platform.

### 4. Camera Pipeline (`src/core/camera_target.gd` + PhantomCamera2D)
* **Purpose:** Implements a custom smoothing and precision window filter (`precision_window_x`) on top of PhantomCamera2D.
* **Benefit:** Prevents micro-movements from shaking the camera while preserving a smooth Super Mario World-style horizontal lookahead and velocity clamping during high-speed dashes.

## Current Roadmap (Active Development)

- [ ] Implement `HurtboxComponent` with invulnerability frames (i-frames) and hit-stop freeze frames.
- [ ] Add directional downward slash pogo physics integration in `AirState`.
- [ ] Build automated GDScript unit tests for state transition edge cases.
- [ ] Implement surface-dependent friction overrides (ice, slopes, moving platforms).
