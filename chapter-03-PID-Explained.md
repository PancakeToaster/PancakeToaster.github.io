---
layout: default
title: "Chapter 3: PID Explained"
nav_order: 4
---
# Chapter 3: PID Explained

To make PID as simple as possible, let’s stop thinking about math and start thinking about **driving a car.**

Imagine you are sitting in the passenger seat, and your job is to tell the driver how to push the gas pedal to stop exactly at a red light.

---

### 1. **P** is for **Proportion** (The "Look Ahead" Rule)

**The Concept:** The farther away the red light is, the harder you tell the driver to push the gas. As you get closer, you tell them to let off the pedal.

- **In the code:** `proportional = kp * current_error;`
    
- **Simple Explanation:** If you are 100 feet away, you apply a lot of power. If you are only 1 foot away, you apply almost zero power. It's a simple ratio.
    
- **The Problem:** If you only use **P**, the car might stop a few inches short because there isn't enough power to overcome the friction of the tires on the road.
    

---

### 2. **I** is for **Integral** (The "Impatient" Rule)

**The Concept:** Imagine the car has stopped 2 inches short of the line. The driver isn't pushing the gas because **P** is too small. You wait 1 second... 2 seconds... 3 seconds... and you get impatient. You start yelling, "Go! Go! Go!" until the driver nudges the car that last little bit.

- **In the code:** `sum_error += current_error;`
    
- **Simple Explanation:** This is a timer. It adds up all the time you spent **not** at the target. The longer you wait, the higher the power grows, forcing the robot to finish the move.
    
- **The Problem:** If you get **too** impatient, you might make the driver slam the gas at the last second and overshoot the line.
    

---

### 3. **D** is for **Derivative** (The "Brake" Rule)

**The Concept:** You see the red light coming up fast. You look at the speedometer and realize, "Wait, we are going too fast to stop in time!" You tell the driver to start tapping the brakes **before** you hit the line.

- **In the code:** `derivative = current_error - prev_error;`
    
- **Simple Explanation:** This looks at your **speed**. If your error is disappearing very quickly, it means you are moving fast. The **D** term creates "counter-power" (braking) to slow you down so you land perfectly.
    

---

### How it looks in your code (The Line-by-Line)

C++

```
// 1. How far is the goal?
current_error = target - input; 

// 2. How fast are we moving? (The Brake)
derivative = current_error - prev_error; 

// 3. Are we stuck? (The Muscle)
// If we are close to the goal, start the "Impatient Timer"
if (fabs(current_error) < integral_range) {
    sum_error += current_error; 
}

// 4. Final Math: Power = (Push) + (Yelling) - (Braking)
return (kp * current_error) + (ki * sum_error) + (kd * derivative);
```

---

### Summary Table for Students

|**Part**|**Nickname**|**What it does**|**What happens if it's too high?**|
|---|---|---|---|
|**P**|The Gas|Gets you moving toward the goal.|The robot will shake or bounce like a spring.|
|**I**|The Muscle|Fixes the "almost there" gap.|The robot will zoom past the goal or go crazy.|
|**D**|The Brake|Smooths out the landing.|The robot will move very slowly and feel "heavy."|

### A "Golden Rule" for Coding It:

When you start testing your robot, always set **I** and **D** to zero. Only change **P** until the robot moves. Once it moves but starts bouncing, add a little **D** to "soak up" the bounce. Only add **I** if the robot is consistently stopping short.

---

## 🛠️ The 3-Step Tuning Guide (The "Trial and Error" Method)

Before you start, make sure your robot is on a full field with a fresh battery. Set your `ki` and `kd` to **0** in your code.

#### **Step 1: Find your P (The Gas)**

Start with a very small number for `kp` (like 0.1).

1. Run the robot. It probably won't reach the target.
    
2. Keep doubling the number (0.2, 0.4, 0.8...) until the robot reaches the target.
    
3. **The Goal:** You want the robot to move quickly to the target, overshoot it slightly, and "bounce" back and forth maybe 2 or 3 times before stopping.
    
    - _If it shakes violently:_ Your `kp` is too high!
        
    - _If it never reaches the goal:_ Your `kp` is too low.
        

#### **Step 2: Find your D (The Brake)**

Now that your robot is "bouncing" because of the high `kp`, we use `kd` to smooth it out.

1. Start with a small `kd` (like 1.0).
    
2. Increase it slowly.
    
3. **The Goal:** You want the `kd` to "soak up" the bounce. The robot should zoom toward the target and slow down perfectly right at the line without any shaking.
    
    - _If the robot moves like it's driving through molasses:_ Your `kd` is too high.
        

#### **Step 3: Find your I (The Muscle)**

Most of the time, you don't even need `ki`. But if your robot stops exactly 0.5 inches away from the goal every time and won't move that last bit:

1. Set a very tiny `ki` (like 0.001).
    
2. **The Goal:** The robot should settle near the target, wait half a second, and then "nudge" itself perfectly onto the line.

---

### 💡 Final Pro-Tips for Students

- **Fresh Battery:** A battery at 100% pushes harder than a battery at 50%. Always tune with a battery around 80-90%.
    
- **The "Push" Test:** While your PID is holding the robot at a target, try to push the robot with your hand. A well-tuned PID will fight back and return to the spot immediately.
    
- **Keep a Notebook:** Write down your numbers! "Kp 2.5 was too shaky, Kp 2.1 was perfect." You will forget these numbers otherwise.