---
layout: default
title: "Chapter 9: Autonomous Troubleshooting Guide"
nav_order: 10
---
# Chapter 9: Autonomous Troubleshooting Guide

## 1. PID Issues (Stuttering & Overshooting)

| **Symptom**            | **Probable Cause**                                 | **Fix**                                                      |
| ---------------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| **Violent Shaking**    | $K_p$ is too high.                                 | Lower your $K_p$ value by 20% increments.                    |
| **Robot stops early**  | Friction is higher than motor power.               | Increase $K_i$ slightly or lower the `derivative_tolerance`. |
| **Never stops moving** | $K_i$ is "winding up" or tolerances are too tight. | Lower $K_i$ or increase `small_error_tolerance`.             |
| **Overshoots Target**  | $K_d$ is too low (not enough braking).             | Increase $K_d$ to add more damping/braking force.            |

### **How to "Tune" from scratch:**

1. Set $K_i$ and $K_d$ to **0**.
    
2. Increase $K_p$ until the robot reaches the target but **oscillates** (bounces) slightly.
    
3. Increase $K_d$ until the bouncing stops.
    
4. If the robot stops 1 inch short of the target, add a very small $K_i$ (start at 0.001).
    

---

## 2. Odometry Issues (The "Drift")

If your robot thinks it is at $(10, 10)$ but it is actually at $(15, 8)$, you have an Odometry drift problem.

|**Symptom**|**Probable Cause**|**Fix**|
|---|---|---|
|**Inaccurate X/Y**|Wrong `wheel_diameter` in code.|Measure your tracking wheels with a caliper. Standard is usually 2.75" or 2".|
|**Turning breaks X/Y**|Wrong `dist_from_center` value.|Measure the distance from the center of the robot to your tracking wheels exactly.|
|**Position "jumps"**|Encoder wires are loose or static.|Ensure cables are secure and spray tiles with anti-static spray.|
|**Angle is wrong**|Inertial sensor not calibrated.|Ensure `Inertial.calibrate()` runs while the robot is **completely still**.|

> **Pro Tip:** If your robot is consistently off by a certain percentage (e.g., it always thinks 24 inches is 22 inches), multiply your wheel diameter by a "scaling factor" (like $1.05$) to calibrate it.

---

## 3. Boomerang & Pathing Issues

### **Problem: The robot circles the target forever.**

- **Why:** Your `small_error_tolerance` is too small, or your robot is too fast to "catch" the point.
    
- **Fix:** Increase the tolerance or lower the `max_output` (voltage).
    

### **Problem: The curve is too wide or too sharp.**

- **Why:** The `dlead` parameter is incorrectly set.
    
- **Fix:** * **Too Wide:** Lower `dlead` (closer to 0.1).
    
    - **Too Sharp:** Raise `dlead` (closer to 0.7).
        

### **Problem: The robot arrives but faces the wrong way.**

- **Why:** Your `a` (angle) parameter is in the wrong format (Degrees vs Radians) or the `dir` (direction) is wrong.
    
- **Fix:** Ensure you use Degrees (0-360) and check that `dir` is `1` for forward and `-1` for reverse.
    

---

## 4. Hardware Safety Checklist

Before you spend hours changing code, check these three physical things:

1. **Wheel Friction:** Pick the robot up and spin the tracking wheels. They should spin freely for several seconds. If they stop instantly, they are too tight.
    
2. **Motor Temperature:** If motors are hot to the touch, the PID is fighting itself. Lower your $K_p$.
    
3. **Center of Mass:** If your robot is "back-heavy," the front tracking wheels might lift off the ground during acceleration, ruining your Odometry.