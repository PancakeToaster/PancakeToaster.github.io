---
layout: default
title: "Appendix B: The Robot Coding Glossary"
nav_order: 91
---

### **General Concepts**

- **Autonomous:** The period of a match where the robot moves by itself using code, with no help from a human driver.
    
- **Chassis:** The "base" or "frame" of the robot, including the wheels and the motors that make it move.
    
- **Coefficient:** A fancy math word for a "multiplier." In PID, $K_p$, $K_i$, and $K_d$ are coefficients that change how much power we give the motors.
    
- **Constants:** Numbers in your code that don’t change while the program is running (like your PID gains).
    

---

### **PID Terms**

- **Error:** The distance between where the robot is and where it wants to be. If the goal is 24 inches and you are at 20, the **error** is 4.
    
- **Settling:** The moment at the end of a move when the robot stops wobbling and sits perfectly still at the target.
    
- **Tolerance:** The "close enough" range. If your tolerance is 0.5 inches, the robot will consider itself "arrived" even if it's 0.4 inches away.
    
- **Oscillation:** When a robot bounces back and forth over a target like a spring. Usually caused by a $K_p$ that is too high.
    
- **Integral Windup:** When the "impatient" part of PID ($K_i$) builds up too much power while the robot is stuck, causing it to launch forward dangerously once it breaks free.
    

---

### **Odometry & Pathing Terms**

- **Odometry (Odom):** The system that tracks the robot's $(X, Y)$ position on the field.
    
- **Heading:** The direction the robot is facing (usually measured from 0 to 360 degrees).
    
- **Radians:** A different way to measure circles. Instead of 360 degrees, a full circle is $2\pi$ (about 6.28) radians. Computers love radians for trigonometry.
    
- **Delta ($\Delta$):** A Greek letter used in math to mean "The Change." For example, **Delta X** is how much your X-position changed since the last loop.
    
- **Carrot Point:** A temporary "fake" target used in Boomerang to pull the robot into a smooth curve.
    
- **Lead Factor (`dlead`):** A setting that decides how far away the "Carrot" is. It determines if your turn is a wide circle or a sharp hook.
    

---

### **The "Mathy" Functions**

- **Atan2:** A special math function that takes $(X, Y)$ coordinates and tells you exactly what angle you need to turn to face that point.
    
- **Hypot (Hypotenuse):** A function that calculates the straight-line distance between two points (using the $a^2 + b^2 = c^2$ rule).
    
- **Slew Rate:** A "speed limit" for how fast your motor power can change. It prevents the robot from jerking so hard that the wheels slip or the robot tips over.
    

---

### **Final Project Tip for the Team**

When you are explaining your code to judges at a competition, use these words! Instead of saying _"We made the robot stay still,"_ say _"We tuned our PID coefficients to minimize oscillation and ensure the robot settled within our small error tolerance."_ It makes a huge difference!