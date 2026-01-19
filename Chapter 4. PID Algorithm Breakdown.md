The PID (Proportional-Integral-Derivative) controller is the "correction engine" that ensures the robot reaches a target smoothly.

### **Parameter Definitions**

| **Parameter**           | **Description**                                                                            |
| ----------------------- | ------------------------------------------------------------------------------------------ |
| `kp` (Proportional)     | The main "punch." Power proportional to how far away the target is.                        |
| `ki` (Integral)         | The "muscle." Increases power over time if the robot is stuck or struggling with friction. |
| `kd` (Derivative)       | The "brake." Slows the robot down as it approaches the target to prevent overshooting.     |
| `small_error_tolerance` | How close to the target is "good enough" for a precise stop.                               |
| `small_error_duration`  | How many milliseconds the robot must stay in that "good enough" zone to exit.              |

### **Code Logic Breakdown**

Here is the line-by-line logic for the `update` function:

C++

```
double PID::update(double input) {
  // 1. Calculate the current distance from the goal
  current_error = target - input; 

  // 2. Calculate Derivative: How fast is the error changing?
  // (current error - last error) / time. This acts as a brake.
  derivative = (current_error - prev_error); 
  prev_error = current_error;

  // 3. Integral Logic: Accumulate error over time to overcome friction.
  if (fabs(current_error) >= integral_range && integral_range != 0) { 
    sum_error = 0; // Don't start "winding up" the integral until we are close.
  } else { 
    sum_error += current_error; // Add current error to the running total.
    
    // Safety: Prevent Integral Windup (capping the max power the integral can provide)
    if (fabs(sum_error) * ki > integral_max && integral_max != 0) {
      sum_error = sign(sum_error) * integral_max / ki;
    }
  }

  // 4. Stabilization: Clear integral if we overshoot the target or are perfectly centered.
  if (sign(sum_error) != sign(current_error) || (fabs(current_error) <= small_error_tolerance)) {
    sum_error = 0;
  }

  // 5. Final Calculation: Combine all three terms.
  proportional = kp * current_error;
  integral = ki * sum_error;
  derivative_term = kd * derivative; // Note: In your code this is simplified to kd * derivative

  // 6. Arrival Check: Are we within tolerance and moving slowly enough (derivative check)?
  if (arrive == true && fabs(current_error) <= small_error_tolerance && fabs(derivative) <= derivative_tolerance) { 
    if (Brain.timer(msec) - small_check_time >= small_error_duration) {
      arrived = true; // Stayed in the zone long enough!
    }
  } else {
    small_check_time = Brain.timer(msec); // Reset timer if we move out of the zone.
  }

  return proportional + integral + derivative_term; // Output voltage to motors.
}
```

## Usage Examples with Code Snippets
### **Scenario A: Turning using the PID Controller**

_How to manually use the PID class to rotate your robot._

C++

```
PID turnPID(2.5, 0, 10); // Create PID with Kp=2.5, Ki=0, Kd=10
turnPID.setTarget(90);    // We want to face 90 degrees

while(!turnPID.targetArrived()) {
    double currentHeading = InertialSensor.heading();
    double power = turnPID.update(currentHeading);
    
    // Apply power: Left motor positive, Right motor negative to spin
    driveChassis(power, -power); 
    wait(10, msec);
}
stopChassis(brake); // Stop once arrived
```
