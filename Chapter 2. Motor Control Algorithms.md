### 1. Bang-Bang (On/Off)

**Complexity:** ⭐ This is the simplest form of control. It’s either 100% power or 0% power.

- **How it works:** If your robot is behind the target, go full speed. If it's past the target, stop.
    
- **The Problem:** It’s very jerky. Imagine driving a car by only slamming the gas or slamming the brakes—it’s bad for your gears and very shaky.
    

### 2. Slew Rate (Ramping)

**Complexity:** ⭐⭐ This is a small upgrade to manual control that prevents the robot from tipping over.

- **How it works:** It limits how fast the motor power can change. If you push the joystick to 100, the code "ramps" the power (20... 40... 60... 80... 100) instead of jumping instantly.
    
- **The Problem:** It doesn't help with accuracy; it just makes the robot smoother.
    

### 3. PID Control (The Standard)

**Complexity:** ⭐⭐⭐ This is what most competitive VEX teams use. It uses math to calculate "Error" (how far you are from the target).

- **P (Proportional):** Big move when far away, small move when close.
    
- **I (Integral):** Fixes the tiny errors that stop the robot just short of the goal.
    
- **D (Derivative):** The "brake" that slows the robot down so it doesn't overshoot.
    
- **The Problem:** It can be hard to "tune" (finding the right numbers for Kp, Ki, and Kd).
    

### 4. Feedforward (Prediction)

**Complexity:** ⭐⭐⭐⭐ This is often added to a PID to make it even stronger.

- **How it works:** Instead of waiting for an error to happen, you tell the motor exactly how much power it needs to overcome things like gravity or friction.
    
- **Example:** If you have a heavy arm, you give the motor a little "base power" just to hold it up, then let the PID do the actual moving.
    

### 5. Motion Profiling (Trapezoidal / S-Curve)

**Complexity:** ⭐⭐⭐⭐⭐ This is how industrial robots move. Instead of just "going to a point," the robot calculates a "flight plan."

- **How it works:** You tell the robot its **Max Velocity** and **Max Acceleration**. It creates a perfect math curve: it speeds up at a safe rate, cruises at a steady speed, and slows down perfectly.
    
- **The Benefit:** This is the most consistent way to move. It’s very easy on the hardware and ensures the robot ends up in the exact same spot every single time.