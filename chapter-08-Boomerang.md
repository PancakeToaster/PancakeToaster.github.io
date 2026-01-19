---
layout: default
title: "Chapter 8: Boomerang Algorithm Breakdown"
nav_order: 9
---
# Chapter 8: Boomerang Algorithm Breakdown

# Boomerang Algorithm Breakdown (`motor-control.cpp`)

The Boomerang algorithm is a "Pure Pursuit" variation. Instead of driving straight to a point, it aims for a "carrot point" slightly in front of the target to create a smooth curve.

### **Parameter Definitions**

|**Parameter**|**Description**|
|---|---|
|`x`, `y`|The global coordinates of the target on the field.|
|`dir`|Direction of travel: `1` for forward, `-1` for backward.|
|`a`|The final heading (angle) the robot should face when it arrives.|
|`dlead`|The "lead" factor (usually 0.0 to 1.0). Determines how wide the curve is.|
|`exit`|If `true`, the robot stops at the end. If `false`, it carries momentum into the next command.|

### **Code Logic Breakdown**

C++

```
void boomerang(double x, double y, int dir, double a, double dlead, ...) {
  is_turning = true;
  PID movePID(move_kp, move_ki, move_kd); // Control forward/backward speed
  PID turnPID(turn_kp, turn_ki, turn_kd); // Control steering

  while(!movePID.targetArrived()) {
    // 1. Calculate distance from current (x_pos, y_pos) to target (x, y)
    double h = hypot(x - x_pos, y - y_pos); 

    // 2. The Carrot Point Logic:
    // This creates a target angle based on the final angle (a) and the current distance (h).
    // As h gets smaller, the robot's target angle shifts more toward the final desired angle.
    double carrot_x = x - h * cos(degToRad(a)) * dlead;
    double carrot_y = y - h * sin(degToRad(a)) * dlead;

    // 3. Calculate the angle needed to face that carrot point.
    double target_angle = radToDeg(atan2(carrot_x - x_pos, carrot_y - y_pos));

    // 4. Calculate PID Outputs
    // Linear power is based on distance to the ACTUAL target.
    double move_output = movePID.update(h); 
    // Rotational power is based on the angle to the CARROT point.
    double turn_output = turnPID.update(getAngleError(target_angle));

    // 5. Motor Mixing
    // Combines forward speed and turning speed into left/right voltages.
    double left_output = move_output + turn_output;
    double right_output = move_output - turn_output;

    // 6. Safety Scaling: Ensure we don't exceed max voltage while maintaining the curve ratio.
    scaleToMax(left_output, right_output, max_output);

    // 7. Slew Rate: Prevent "jerking" by limiting how fast voltage can change per loop.
    if(left_output - prev_left_output > max_slew_fwd) {
      left_output = prev_left_output + max_slew_fwd;
    }
    
    driveChassis(left_output, right_output);
    prev_left_output = left_output;
    wait(10, msec);
  }
}
```

---

## Usage Examples with Code Snippets
### **Scenario A: Executing a Boomerang Curve**

_Moving to a goal while curving around an obstacle to face a specific direction._

C++

```
// Target: X=36, Y=36 (middle of the field)
// Final Angle: 180 degrees (facing the back wall)
// Lead: 0.6 (medium curve)
// Max Speed: 10 volts
boomerang(36.0, 36.0, 1, 180.0, 0.6, 3000, true, 10.0);
```

### **Scenario B: Multi-Point Pathing (Chaining)**

_Using the `exit` parameter to move through multiple points without stopping._

C++

```
// 1. Curve toward the first point but don't stop (exit = false)
boomerang(24, 24, 1, 45, 0.5, 2000, false, 12.0);

// 2. Immediately transition into a second curve to the final goal
boomerang(48, 0, 1, 0, 0.4, 2000, true, 12.0);
```

### **Scenario C: Fine-Tuning the "Carrot"**

_Comparing different `dlead` values._

C++

```
// dlead = 0.1: Very sharp, direct movement. Almost a straight line then a turn.
boomerang(24, 24, 1, 90, 0.1, 3000, true, 12);

// dlead = 0.9: Very wide, sweeping arc. Useful for avoiding a big center obstacle.
boomerang(24, 24, 1, 90, 0.9, 3000, true, 12);
```