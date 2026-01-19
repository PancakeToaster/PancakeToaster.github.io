## 1. `pid.cpp` (The PID Controller Class)

The `PID` class provides a feedback loop mechanism that calculates the precise power needed to reach a target while minimizing overshoot.

### `PID(double kp, double ki, double kd)`

**Description:** The constructor that initializes the Proportional ($K_p$), Integral ($K_i$), and Derivative ($K_d$) constants. It also sets up default tolerances and internal timers.

- **Example 1: Initializing a Drive PID**
    
    C++
    
    ```
    PID drivePID(1.5, 0.01, 10.0); // Balanced for straight movement
    ```
    
- **Example 2: Initializing a Sharp Turn PID**
    
    C++
    
    ```
    PID turnPID(3.0, 0, 15.0); // High D-gain to prevent overshooting during spins
    ```
    
- **Example 3: Low-Power Precision PID**
    
    C++
    
    ```
    PID slowPID(0.5, 0.005, 2.0); // For very slow, careful movements
    ```
    

---

### `update(double input)`

**Description:** The core math engine. It takes the current sensor value (input), compares it to the target, and returns a voltage output.

- **Example 1: Basic Loop Usage**
    
    C++
    
    ```
    double power = myPID.update(InertialSensor.heading());
    ```
    
- **Example 2: Maintaining Distance**
    
    C++
    
    ```
    // Using ultrasonic sensor to stay 10 inches from a wall
    double output = wallPID.update(DistanceSensor.objectDistance(inches));
    ```
    
- **Example 3: Arm Height Control**
    
    C++
    
    ```
    // Calculating power to hold a lift at a specific potentiometer value
    double liftVoltage = liftPID.update(liftPot.angle(degrees));
    ```
    

---

### `targetArrived()`

**Description:** Checks if the robot has reached its destination and stayed there within the "tolerance" range for a set amount of time.

- **Example 1: Blocking Autonomous Movement**
    
    C++
    
    ```
    while(!movePID.targetArrived()) {
        driveChassis(movePID.update(getPos()), movePID.update(getPos()));
        wait(10, msec);
    }
    ```
    
- **Example 2: Sequencing Actions**
    
    C++
    
    ```
    if(turnPID.targetArrived()) {
        claw.open(); // Only open claw once the turn is fully finished
    }
    ```
    
- **Example 3: Debugging**
    
    C++
    
    ```
    if(movePID.targetArrived()) {
        Brain.Screen.print("Robot has settled at target.");
    }
    ```
    

---

### `setSmallBigErrorTolerance(double small, double big)`

**Description:** Defines two tiers of error ranges. The robot is "arrived" if it stays within these bounds for the required time.

- **Example 1: High Precision Mode**
    
    C++
    
    ```
    pid.setSmallBigErrorTolerance(0.1, 0.5); // Very strict for scoring
    ```
    
- **Example 2: Fast Movement Mode**
    
    C++
    
    ```
    pid.setSmallBigErrorTolerance(2.0, 5.0); // Loose for traveling across field
    ```
    
- **Example 3: Standard Default**
    
    C++
    
    ```
    pid.setSmallBigErrorTolerance(1.0, 3.0); // General purpose
    ```
    

---

## 2. `motor-control.cpp` (Chassis & Movement)

This file handles the logic for driving the robot and performing complex maneuvers.

### `driveChassis(double left, double right)`

**Description:** Directly sets the voltage (typically -12.0 to 12.0) for the left and right motor groups.

- **Example 1: Full Speed Forward**
    
    C++
    
    ```
    driveChassis(12.0, 12.0);
    ```
    
- **Example 2: Pivot Turn Right**
    
    C++
    
    ```
    driveChassis(6.0, -6.0);
    ```
    
- **Example 3: Gentle Creep**
    
    C++
    
    ```
    driveChassis(2.0, 2.0);
    ```
    

---

### `turnToAngle(double angle, double time_limit, bool exit, double max_output)`

**Description:** Rotates the robot in place to a specific compass heading using the Inertial Sensor.

- **Example 1: Basic 90-Degree Turn**
    
    C++
    
    ```
    turnToAngle(90, 1000, true, 12); // Turn to 90deg, 1s limit, full power
    ```
    
- **Example 2: Slow, Precise 180**
    
    C++
    
    ```
    turnToAngle(180, 2000, true, 6); // Max 6 volts for a more controlled turn
    ```
    
- **Example 3: Chained Turn (No Stop)**
    
    C++
    
    ```
    turnToAngle(45, 800, false, 12); // Don't brake motors after finishing
    ```
    

---

### `driveTo(double distance_in, double time_limit, bool exit, double max_output)`

**Description:** Drives in a straight line for a specific number of inches.

- **Example 1: Drive 2 Tiles**
    
    C++
    
    ```
    driveTo(48.0, 3000, true, 11); // Drive 48 inches forward
    ```
    
- **Example 2: Reverse Movement**
    
    C++
    
    ```
    driveTo(-24.0, 1500, true, 12); // Drive 24 inches backward
    ```
    
- **Example 3: Short Nudge**
    
    C++
    
    ```
    driveTo(5.0, 500, true, 5); // Short, slow nudge to push an object
    ```
    

---

### `boomerang(double x, double y, int dir, double a, double dlead, ...)`

**Description:** Advanced pathing that moves the robot to an (X, Y) coordinate and ensures it is facing angle `a` upon arrival.

- **Example 1: Corner Goal Arc**
    
    C++
    
    ```
    // Drive to (24, 24), face 90 degrees, 0.5 lead factor
    boomerang(24, 24, 1, 90, 0.5, 3000, true, 12); 
    ```
    
- **Example 2: Reverse Curve**
    
    C++
    
    ```
    // Curve backward to (-12, 12) and face 0 degrees
    boomerang(-12, 12, -1, 0, 0.3, 2000, true, 10);
    ```
    
- **Example 3: Tight "S" Curve**
    
    C++
    
    ```
    // Navigate a tight curve with a low dlead factor
    boomerang(48, 0, 1, 0, 0.2, 4000, true, 12);
    ```
    

---

### `trackXYOdomWheel()`

**Description:** A background task function that calculates the robot's global position using encoder tracking wheels.

- **Example 1: Starting the Task**
    
    C++
    
    ```
    vex::task odomTask(trackXYOdomWheel); // Run tracking in the background
    ```
    
- **Example 2: Conditional Trigger**
    
    C++
    
    ```
    if(x_pos > 100.0) { intake.stop(); } // Stop intake if robot crosses field line
    ```
    
- **Example 3: Position Reset**
    
    C++
    
    ```
    if(reset_button.pressing()) { x_pos = 0; y_pos = 0; } // Manual recalibration
    ```
    

---

### `scaleToMax(double& left, double& right, double max_output)`

**Description:** Adjusts motor powers proportionally so that if one side is commanded over the limit, the turn ratio stays the same.

- **Example 1: Capping Speed for Curves**
    
    C++
    
    ```
    scaleToMax(l_volt, r_volt, 10.0); // Ensure neither side exceeds 10V
    ```
    
- **Example 2: Battery Conservation**
    
    C++
    
    ```
    scaleToMax(l, r, 8.0); // Limit draw during long movements
    ```
    
- **Example 3: Correcting Saturation**
    
    C++
    
    ```
    // If l=15 and r=10, scaleToMax(12) makes l=12 and r=8
    scaleToMax(left_calc, right_calc, 12.0);
    ```