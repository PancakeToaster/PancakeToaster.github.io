---
layout: default
title: "Chapter 5: Odometry"
nav_order: 6
---

# 1. What is Odometry? (The Simple Version)

Imagine you are in a dark room with a blindfold on. You are standing on a giant piece of grid paper. You know you started at the exact center $(0, 0)$.

To figure out where you are after walking around, you need two pieces of information:

1. **How far did your feet move?** (Distance)
    
2. **What direction were you pointing?** (Heading)
    

If you take 5 steps forward while facing "North," you know you are now at $(0, 5)$. If you turn right and take 3 steps, you are at $(3, 5)$. **Odometry** is just a robot using math to do this constantly—about 100 times every second—so it always knows its $(X, Y)$ position on the field.

### Why do we need "Tracking Wheels"?

Standard drive wheels can slip or "burn out" on the foam tiles. Odometry usually uses small, unpowered **Tracking Wheels** (with encoders) that touch the ground lightly. Because they aren't connected to motors, they don't slip, giving the robot a much more accurate "step count".

---

# 2. `trackXYOdomWheel()` Line-by-Line Breakdown

This function runs in a background "task" (a loop that never stops) to keep the robot's coordinates updated.

### **The Setup**

C++

```
void trackXYOdomWheel() {
  resetChassis(); // Clears motor encoders to start at 0
  double prev_heading_rad = 0; // Stores the angle from the previous loop
  double prev_horizontal_pos_deg = 0, prev_vertical_pos_deg = 0; // Stores last wheel positions
```

### **The Loop**

C++

```
  while (true) {
    // 1. Get current sensor readings
    double heading_rad = degToRad(getInertialHeading()); // Get current angle in radians
    double horizontal_pos_deg = horizontal_tracker.position(degrees); // Side-to-side wheel
    double vertical_pos_deg = vertical_tracker.position(degrees); // Forward-backward wheel

    // 2. Calculate "Deltas" (How much did things change since the last 10ms?)
    double delta_heading_rad = heading_rad - prev_heading_rad; // The turn amount
    
    // Convert degrees of wheel rotation into actual inches on the floor
    double delta_horizontal_in = (horizontal_pos_deg - prev_horizontal_pos_deg) * horizontal_tracker_diameter * M_PI / 360.0;
    double delta_vertical_in = (vertical_pos_deg - prev_vertical_pos_deg) * vertical_tracker_diameter * M_PI / 360.0;

    // 3. Local Movement Calculation
    // If the robot didn't turn, movement is a simple straight line.
    if (fabs(delta_heading_rad) < 1e-6) {
      delta_local_x_in = delta_horizontal_in;
      delta_local_y_in = delta_vertical_in;
    } else {
      // If the robot DID turn, it moved in a tiny arc (part of a circle). 
      // This math calculates the "chord" (straight line distance) of that arc.
      double sin_multiplier = 2.0 * sin(delta_heading_rad / 2.0);
      delta_local_x_in = sin_multiplier * ((delta_horizontal_in / delta_heading_rad) + horizontal_tracker_dist_from_center);
      delta_local_y_in = sin_multiplier * ((delta_vertical_in / delta_heading_rad) + vertical_tracker_dist_from_center);
    }

    // 4. Global Transformation
    // We know how far we moved relative to the ROBOT (Local). 
    // Now we use Sine and Cosine to figure out how far we moved relative to the FIELD (Global).
    double polar_radius_in = sqrt(pow(delta_local_x_in, 2) + pow(delta_local_y_in, 2)); // Total distance moved
    double polar_angle_rad = local_polar_angle_rad - heading_rad - (delta_heading_rad / 2); // The direction

    x_pos += polar_radius_in * cos(polar_angle_rad); // Update global X
    y_pos += polar_radius_in * sin(polar_angle_rad); // Update global Y

    // 5. Store values for the next loop
    prev_heading_rad = heading_rad;
    prev_horizontal_pos_deg = horizontal_pos_deg;
    prev_vertical_pos_deg = vertical_pos_deg;

    wait(10, msec); // Wait 10 milliseconds and repeat
  }
}
```

---

# 3. Parameters Explained

|**Variable**|**Meaning in Middle School Terms**|
|---|---|
|`horizontal_tracker_diameter`|The size of your tracking wheel. Needed to know that 1 full spin = ~8.6 inches.|
|`dist_from_center`|How far the wheel is from the middle of the robot. If a wheel is off-center, it will spin just because the robot is turning, even if the robot isn't moving forward! This variable cancels that out.|
|`delta` ($\Delta$)|A fancy math symbol for "The Change." ($New Value - Old Value$)|
|`radians`|A different way to measure angles. Instead of 0-360, it uses 0 to 6.28 ($2\pi$). Computers prefer this for trigonometry.|

---

# 4. Usage Examples for Odometry

### **Example 1: The "Self-Correcting" Intake**

You can use your $(X, Y)$ position to make decisions automatically.

C++

```
// If the robot is in the middle of the field (X > 70), start spinning the intake.
if (x_pos > 70.0) {
    Intake.spin(fwd, 12, volt);
}
```

### **Example 2: Distance to Target**

Instead of guessing how far to drive, you can use the Pythagorean Theorem ($a^2 + b^2 = c^2$) to find the exact distance to a goal.

C++

```
double targetX = 120.0, targetY = 120.0;
double distance = hypot(targetX - x_pos, targetY - y_pos);

// Drive until you are within 5 inches of the goal
while(distance > 5.0) {
    driveChassis(6, 6);
    distance = hypot(targetX - x_pos, targetY - y_pos);
    wait(10, msec);
}
```

### **Example 3: Manual Calibration**

If the robot bumps into a wall, you can "reset" its position to a known value to fix any tiny errors that built up.

C++

```
// If the back bumper switch is pressed against the starting wall:
if (Bumper.pressing()) {
    x_pos = 0;
    y_pos = 0;
    inertial_sensor.setRotation(0, degrees);
}
```