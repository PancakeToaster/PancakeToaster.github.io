---
layout: default
title: "Chapter 10: Documentation of Programming"
nav_order: 11
---

To create a professional, high-scoring engineering notebook for a competition like VEX, you need to treat it like a scientific journal. Judges look for a "repeatable" process—meaning if another team found your notebook, they could build and program your exact robot just by reading it.

Here is a detailed guide on how to document and tabulate your data effectively.

---
### 1. The Structure of a "Control" Entry

Every time you work on code (like tuning your PID or testing Odom), you should follow a standard template. This makes your notebook clean and easy for judges to navigate.

- **Title & Date:** (e.g., "Tuning Drive PID Coefficients")
    
- **Goal:** What are you trying to achieve? (e.g., "Stop the robot within 0.5 inches of target with zero oscillation.")
    
- **The "Why":** Explain the math. (This is where you use the **Glossary** terms like _Derivative_ or _Error_).
    
- **The Setup:** List your initial constants ($K_p$, $K_i$, $K_d$).
    

---

### 2. How to Tabulate Testing Data

Never just write "it worked better." You need hard numbers. Tables are the best way to show judges that you are using a logical, iterative process.

#### **Example: PID Tuning Table**

Use a table like this to show your "Trial and Error" progress.

|**Trial #**|**Kp​**|**Ki​**|**Kd​**|**Result/Observation**|**Action Taken**|
|---|---|---|---|---|---|
|1|0.5|0|0|Robot stopped 4 inches short.|Increase $K_p$|
|2|1.2|0|0|Reached target but bounced 3 times.|Add $K_d$ to brake.|
|3|1.2|0|2.5|Smooth stop, but 0.25" short.|Add tiny $K_i$.|
|4|1.2|0.01|2.5|**Success.** Perfect landing.|**Finalize Values.**|

---

### 3. Documenting Odometry (X/Y Accuracy)

When testing Odometry, you need to prove the robot knows its position.

**The "Square Test" Table:** Program the robot to drive in a $24" \times 24"$ square and return to $(0,0)$.

|**Test Run**|**Target (X,Y)**|**Actual (X,Y)**|**Error (Distance)**|**Notes**|
|---|---|---|---|---|
|Run 1|$(0, 0)$|$(0.5, -0.2)$|0.53"|Slight drift to the right.|
|Run 2|$(0, 0)$|$(0.1, 0.1)$|0.14"|Tightened tracking wheel pod.|

---

### 4. Visual Documentation

Judges love visuals. Don't just use text; use diagrams and screenshots.

- **Code Snippets:** Don't print 50 pages of code. Copy and paste the _specific_ function you worked on (like the `boomerang` math) and highlight the lines you changed.
    
- **Path Diagrams:** Draw the field. Show the "Intended Path" vs. the "Actual Path."
    
    - _Intended:_ A smooth Boomerang curve.
        
    - _Actual:_ A jagged line because the `dlead` was too low.
        
- **Graphs:** If you can, use the V5 Brain or a laptop to graph your PID error. A graph showing the error curve dropping to zero is worth a thousand words.
    

---

### 5. The "Logic Flow" Diagram

Before writing code, draw a Flowchart. This shows that you planned the logic before you started typing. For a **Boomerang** move, your flowchart might look like this:

1. **Start:** Receive Target $(X, Y, Angle)$.
    
2. **Calculate:** Find distance to target ($h$).
    
3. **Find Carrot:** Project Carrot Point based on $h$ and $dlead$.
    
4. **Loop:** * Update PIDs.
    
    - Check: Is $h <$ Tolerance?
        
    - If No: Keep driving.
        
    - If Yes: **Stop/Exit**.
        

---

### 6. Best Practices for the Engineering Notebook

|**Do**|**Don't**|
|---|---|
|**Use Pens:** If you make a mistake, cross it out with one line. Never use white-out.|**Erase:** Judges want to see your mistakes and how you fixed them.|
|**Explain "Failure":** If the robot crashed, explain why.|**Ignore Problems:** A notebook with zero failures looks fake.|
|**Sign and Date:** Every page should be signed by the person who wrote it.|**Leave Blank Space:** If a page is half-empty, draw a diagonal line through it.|
|**Reference the Math:** Explicitly mention "We used the `hypot()` function for distance."|**Be Vague:** Avoid words like "fast," "good," or "a lot." Use "12 volts," "0.5 inches," or "80%."|

### Summary for the Team

An engineering notebook is a story. It’s the story of how you started with a robot that couldn't drive straight and ended with a robot that uses **Pure Pursuit** and **Odometry** to dominate the field. Use your **Glossary** and your **Tables** to tell that story with facts!


# Documentation of PID

To effectively explain PID in your engineering notebook, you should use diagrams that visualize how the robot "thinks" and how the math translates into movement.

Here are the four most useful types of images for your documentation:

### 1. The PID Control Loop Diagram

This is the standard "map" of a PID system. It shows how the **Sensor** (Inertial or Encoder) sends data back to the **Controller** to calculate the **Error**, which then adjusts the **Motor Output**.1

### 2. The PID Response Curve (The "Tuning Graph")

This graph is essential for your engineering notebook. It shows what happens when your constants are set differently.

- **Underdamped:** The line bounces over the target (too much P).
    
- **Overdamped:** The line takes a long time to reach the target (too much D or too little P).
    
- **Critically Damped:** The "Golden" line that reaches the target perfectly and stays there.
    

### 3. Proportional Gain vs. Error

This visualizes the "P" term. It shows that the motor power is a direct reflection of the distance remaining. Big distance = Big power. Small distance = Small power.

### 4. Component Comparison Graph

This is helpful for explaining the individual roles of P, I, and D. It usually shows three separate lines: one where the power drops as you arrive (P), one where it builds up over time (I), and one that "fights" the speed (D).

---

### How to use these in your notebook:

- **Next to your code:** Place the **Control Loop Diagram** to show you understand the system architecture.
    
- **In your tuning tables:** Place a sketch of a **Response Curve** to explain why you decided to increase $K_d$ (e.g., "Our graph looked like the Underdamped line, so we added $K_d$ to smooth the curve").
    
- **In the Glossary:** Use the **Proportional vs. Error** graph to define the term "Linear Scaling."