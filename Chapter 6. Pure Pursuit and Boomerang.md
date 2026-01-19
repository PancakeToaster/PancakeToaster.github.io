# 1. What is Pure Pursuit? 

### The "Carrot on a Stick" Trick

Imagine you are holding a carrot on a long stick in front of a donkey. As the donkey moves toward the carrot, you move the stick. The donkey never stops; it just keeps curving to follow the carrot.

- In `moveToPoint`, the **Target Point** is the carrot.
    
- The **Look-Ahead** is the length of the stick.
    
- The robot is constantly "steering" toward that point while driving forward, which creates a smooth curve instead of a sharp, jerky turn.
    

### The Math (Simplified)

Every second, the robot asks itself three questions:

- **"How far away am I?"** It uses the distance formula (math you'll learn in Algebra) to see if it needs to go full speed or start slowing down.
    
- **"Where am I facing?"** It looks at its **Odometry** (those tracking wheels on your 1/16" poly mounts) to see its current angle.
    
- **"How much do I need to turn?"** This is the **Curvature**. Instead of stopping to turn, it just tells one side of the drivetrain to spin a little faster than the other. This lets it "arc" toward the target.
    

### 2. The Mathematical Steps

When you call `moveToPoint(x, y)`, the code performs these calculations dozens of times per second:

1. Distance Calculation: It uses the Pythagorean theorem to find how far it is from the target:
    
    $$\text{Distance} = \sqrt{(x_{target} - x_{robot})^2 + (y_{target} - y_{robot})^2}$$
    
2. Target Bearing: It calculates the angle ($\theta$) required to face the point using atan2:
    
    $$\text{Target Angle} = \operatorname{atan2}(y_{target} - y_{robot}, x_{target} - x_{robot})$$
    
3. **Error Calculation:** It compares the **Target Angle** to the robot’s **Current Heading** (from Odometry).
    
4. **Curvature (The Secret Sauce):** Instead of stopping to turn, it calculates a "Curvature" value. It tells the robot: _"To hit that point while moving forward, the left wheels need to spin at 90% power and the right wheels at 70% power."_

### The Two "Coaches" (Dual PID)

Inside the `moveToPoint` code, there are two "Coaches" shouting instructions at the same time:

1. **The Distance Coach (Linear PID):** "We’re far away, go fast!" ... "Okay, we’re getting close, slow down... slow down... STOP!"
    
2. **The Steering Coach (Angular PID):** "You're drifting left! Turn right!" ... "Now you're straight, keep it there!"
    

Because both coaches work at the same time, the robot can drive forward and turn at once. This saves a lot of time during a 15-second autonomous period.

### When does it stop? (The "Close Enough" Rule)

In the real world, a robot almost never hits a coordinate perfectly. If you tell it to go to $(10, 10)$, it might get to $(10.1, 9.9)$ and start wiggling forever trying to be perfect.

To fix this, the code has Exit Conditions:

- **The "Good Enough" Zone:** If the robot is within 0.5 inches of the target, it counts as a win.
    
- **The "Settling" Timer:** The robot has to stay in that zone for a split second to make sure it didn't just fly past it.
    
- **The "I'm Stuck" Timer:** If the robot hits a wall or a game piece and hasn't moved for 2 seconds, the code "gives up" and moves to the next command so you don't waste your whole autonomous run.

---

# 2. What is the Boomerang Algorithm?

The Boomerang algorithm is an "upgrade" to Pure Pursuit. Pure Pursuit is great for following a line, but it has one big problem: **It doesn't care what direction you are facing when you arrive.**

If you want to arrive at a goal facing exactly 90 degrees to score a point, Pure Pursuit might leave you facing 70 or 110 degrees. **Boomerang fixes this** by projecting the "Carrot Point" based on your desired final heading.

### **Boomerang Line-by-Line Breakdown**

Here is how the logic works inside `motor-control.cpp`:

C++

```
// 1. Calculate the distance to the ACTUAL goal
double h = hypot(x - x_pos, y - y_pos); 

// 2. Calculate the "Carrot Point" (The virtual target)
// We take the final target (x, y) and "stretch" it out based on the desired angle (a).
// dlead is the "Lead Factor" - it controls how far away the carrot is.
double carrot_x = x - h * cos(degToRad(a)) * dlead;
double carrot_y = y - h * sin(degToRad(a)) * dlead;

// 3. Aim at the Carrot
// atan2 finds the angle from our current (x_pos, y_pos) to the (carrot_x, carrot_y).
double target_angle = radToDeg(atan2(carrot_x - x_pos, carrot_y - y_pos));

// 4. Drive Logic
// Linear power (forward speed) is based on the REAL target distance (h).
double move_output = movePID.update(h); 
// Turning power is based on the angle to the CARROT.
double turn_output = turnPID.update(getAngleError(target_angle));
```

---
### What is a "Carrot Point"?

In your code, the **Carrot Point** is a virtual goal that "dangles" in front of the robot.

Think of a cartoon donkey with a carrot hanging from a stick on its head. The donkey (the robot) moves toward the carrot. Because the stick is attached to the donkey, the carrot is always moving, pulling the donkey along a path.

In the `boomerang` function, the carrot point isn't just the final destination $(x, y)$. It is a point calculated to be some distance away from the destination, aligned with the **final angle** you want to reach.

### 🍎 Why is the "Carrot Point" useful

Think of the **Boomerang** code like this: If you try to run directly at a chair and sit down, you might hit the chair or sit on the edge. But if you imagine a "Ghost Chair" (the **Carrot Point**) 2 feet behind the real chair, you will naturally walk toward the ghost chair and "land" perfectly in the real chair while facing the right way.

---
# 3. Examples of Boomerang & Carrot Logic

### **Example 1: The "Wide Sweep" (High Lead)**

If you have a big obstacle in the middle of the field, you want a wide, circular path. You set `dlead` to a higher value (like 0.8). This puts the "carrot" far away, forcing the robot to take a wide turn.

C++

```
// dlead = 0.8 (Wide curve to avoid a center obstacle)
boomerang(48, 48, 1, 90, 0.8, 3000, true, 12);
```

### **Example 2: The "Tight Hook" (Low Lead)**

If you are already close to a goal and just need to snap into a specific angle, you use a low `dlead` (like 0.2). The carrot is very close to the target, so the robot drives more directly.

C++

```
// dlead = 0.2 (Sharp turn to face a goal exactly)
boomerang(12, 24, 1, 0, 0.2, 1500, true, 10);
```

### **Example 3: The "Backwards Boomerang"**

If your robot has a claw on the back, you use a direction (`dir`) of `-1`. The math flips, and the robot "backs into" the carrot point.

C++

```
// dir = -1 (Reverse curve to score with a rear-mounted lift)
boomerang(-24, 0, -1, 180, 0.5, 2500, true, 11);
```

---

# Summary Table

|**Term**|**Simple Definition**|**Role in Your Code**|
|---|---|---|
|**Pure Pursuit**|Following a point ahead of you.|The basic way your robot follows a path.|
|**Carrot Point**|The "fake" target the robot aims for.|Calculated using `carrot_x` and `carrot_y`.|
|**Boomerang**|Curving to hit a specific final angle.|The function `boomerang()` that handles X, Y, and Angle.|
|**dlead**|How far the carrot is from the goal.|Determines if your curve is "Wide" or "Sharp."|
|**h (Hypotenuse)**|Straight line distance to the goal.|Used to slow down the robot as it gets close.|
