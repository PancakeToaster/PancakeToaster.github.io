### 🛠️ Detailed Breakdown: How it Works

The `moveToPoint(x, y, timeout, maxSpeed)` function runs through a fast internal loop (usually every 10–20 milliseconds) following these steps:

1. **Coordinate Math:** It looks at your current $(x, y)$ from the tracking wheels and calculates the distance to the target $(x_{goal}, y_{goal})$.
    
2. **Angle Calculation:** It determines the **Target Heading**. If the robot is at $(0,0)$ and the target is at $(10,10)$, the math says "Turn to 45 degrees."
    
3. **The "Swing" (Curvature):** This is the "Pure Pursuit" part. Instead of stopping to turn, the code calculates how much faster the left wheels need to spin compared to the right wheels to create an arc.
    
4. **PID Speed Control:** * **Linear PID:** As the robot gets closer to the point, it automatically lowers the motor voltage so it doesn't "Bang" into the target.
    
    - **Angular PID:** It constantly makes tiny steering corrections to stay on the arc.
        
5. **Exit Condition:** The function ends when the robot is within a certain distance (e.g., 0.5 inches) or if the `timeout` clock runs out.
    

---

### 📝 3 Examples of `moveToPoint` in Action

Here are three ways you would actually use this in your autonomous code. (Note: The specific syntax for `timeout` and `maxSpeed` might vary slightly depending on your version of the template).

#### Example 1: The Simple "Sprint"

Use this for the very first move of a match to grab a goal or a game piece quickly.

C++

```
// Move to 24 inches forward and 0 inches side-to-side
// Timeout after 2000ms, max speed 100%
chassis.moveToPoint(0, 24, 2000, 100); 
```

- **Result:** The robot drives straight at full speed and slows down right as it hits the 24-inch mark.
    

#### Example 2: The "Smooth Curve" (Sequential Points)

This is where the algorithm shines. By calling two points in a row, the robot doesn't stop between them; it creates a fluid motion.

C++

```
chassis.moveToPoint(12, 12, 1500, 80); // Move to the first corner
chassis.moveToPoint(0, 24, 1500, 80);  // Curve toward the second point
```

- **Result:** Because of the curvature logic, the robot will "round off" the first point and transition smoothly into the second move, saving precious seconds in autonomous.
    

#### Example 3: Reaching Backward (Reverse Movement)

Sometimes your intake is on the front, but you need to move to a goal with your back "MOGO" hitch.

C++

```
// Many templates use a boolean (true/false) to indicate driving in reverse
chassis.moveToPoint(0, -24, 2000, 60, true); 
```

- **Result:** The robot uses its rear-facing logic to back up toward the coordinate $(-24, 0)$ at a slower, more controlled speed (60%) to ensure it doesn't miss the goal.