# 📋 Robot Control Project Documentation

This project contains a professional-grade control system for a VEX V5 robot, featuring high-precision Odometry, PID control, and Boomerang pathfinding.

---

## 1. `pid.cpp`: Line-by-Line Logic

This class manages the "Correction Math" for the robot. It ensures that when you say "Go 24 inches," the robot actually goes exactly 24 inches and stops smoothly.

C++

```
double PID::update(double input) {
  // 1. Find the distance to the goal
  current_error = target - input; 

  // 2. The "Brake" (Derivative)
  // We subtract the previous error from current error to see how fast we are moving.
  derivative = current_error - prev_error; 
  prev_error = current_error;

  // 3. The "Muscle" (Integral)
  // If we are within a certain range but not at the target, we start adding up the error.
  if (fabs(current_error) >= integral_range && integral_range != 0) { 
    sum_error = 0; // Too far away? Don't use integral yet.
  } else { 
    sum_error += current_error; // Add current error to a running total.
    
    // Safety: Cap the integral so the robot doesn't go crazy.
    if (fabs(sum_error) * ki > integral_max && integral_max != 0) {
      sum_error = sign(sum_error) * integral_max / ki;
    }
  }

  // 4. Resetting Logic
  // If we cross the target (overshoot), reset the 'muscle' to prevent shaking.
  if (sign(sum_error) != sign(current_error) || (fabs(current_error) <= small_error_tolerance)) {
    sum_error = 0;
  }

  // 5. Arrival Check
  // If error is tiny AND speed (derivative) is tiny for a certain amount of time...
  if (arrive == true && fabs(current_error) <= small_error_tolerance && fabs(derivative) <= derivative_tolerance) { 
    if (Brain.timer(msec) - small_check_time >= small_error_duration) {
      arrived = true; // We have officially arrived!
    }
  } else {
    small_check_time = Brain.timer(msec); // Not there yet, reset the timer.
  }

  // 6. Return the motor voltage (P + I + D)
  return (kp * current_error) + (ki * sum_error) + (kd * derivative);
}
```

---

## 2. Odometry Explained: `trackXYOdomWheel()`

**Odometry** is like a GPS for your robot. It uses sensors to track every tiny move the robot makes on the field.

### How it works (The Simple Way):

Imagine you are walking on a giant sheet of graph paper.

1. **Vertical Wheel:** Tells you how far you moved **Forward/Backward**.
    
2. **Horizontal Wheel:** Tells you how far you moved **Sideways** (strafing).
    
3. **Inertial Sensor:** Tells you what **Direction** you are facing.
    

If you know you walked 10 inches at a 45-degree angle, you can use math (Sine and Cosine) to figure out your new X and Y coordinates on the graph paper.

### Code Breakdown:

- **`delta_heading`**: The change in angle since the last check.
    
- **`delta_vertical_in`**: How many inches the forward wheel rolled.
    
- **`x_pos += ...`**: We take the "local" move (relative to the robot) and rotate it to "global" coordinates (relative to the field).
    

---

## 3. The Boomerang Algorithm

The **Boomerang** is a smart movement that uses a "Carrot Point" to help the robot arrive at a destination while facing a specific direction.

### What is a "Carrot Point"?

Imagine a donkey chasing a carrot on a stick. If you move the stick, the donkey turns to follow it.

- The **Carrot Point** is a fake target placed in front of the actual goal.
    
- By aiming for the carrot instead of the goal, the robot naturally curves into the final position.
    

### Code Breakdown:

C++

```
// 1. Find distance to the real goal
double h = hypot(x - x_pos, y - y_pos); 

// 2. Place the 'Carrot' in front of the goal
// 'dlead' is how far away the carrot is. 
// Higher dlead = wider curve. Lower dlead = sharper turn.
double carrot_x = x - h * cos(degToRad(a)) * dlead;
double carrot_y = y - h * sin(degToRad(a)) * dlead;

// 3. Target Angle
// Find the angle from the robot's current spot to the Carrot.
double target_angle = radToDeg(atan2(carrot_x - x_pos, carrot_y - y_pos));

// 4. Move!
// Linear speed is based on distance to goal (h).
// Turning speed is based on angle to carrot (target_angle).
double move_output = movePID.update(h); 
double turn_output = turnPID.update(getAngleError(target_angle));
```

---

## 4. Examples for Your Docs

### **Example 1: Driving to a Point**

C++

```
// Move to the middle of the field (0,0) from anywhere!
// Final angle: 90 degrees. Lead: 0.5.
boomerang(0, 0, 1, 90, 0.5, 3000, true, 12);
```

### **Example 2: Setting up a PID for a Lift**

C++

```
PID liftPID(0.8, 0.1, 0.5); // Tune these for your specific motor
liftPID.setTarget(500);      // Move lift to 500 units
while(!liftPID.targetArrived()){
  liftMotor.spin(fwd, liftPID.update(liftMotor.position(deg)), volt);
}
```

### **Example 3: Resetting Position (Odom)**

C++

```
// If you start in the corner, tell the robot where it is.
x_pos = -60; // 60 inches from center
y_pos = -60; 
correct_angle = 45; // Facing diagonally
```
