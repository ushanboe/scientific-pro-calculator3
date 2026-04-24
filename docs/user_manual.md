# Scientific Pro Calculator — User Manual

## Table of Contents

1. [Getting Started](#getting-started)
2. [Calculator Screen & Basic Operations](#calculator-screen--basic-operations)
3. [Input Modes: Infix vs RPN](#input-modes-infix-vs-rpn)
4. [Advanced Arithmetic](#advanced-arithmetic)
5. [Symbolic Math & Calculus](#symbolic-math--calculus)
6. [2D Function Graphing](#2d-function-graphing)
7. [3D Surface Graphing](#3d-surface-graphing)
8. [Matrix & Vector Operations](#matrix--vector-operations)
9. [Unit Conversion](#unit-conversion)
10. [Physical Constants Reference](#physical-constants-reference)
11. [Statistics & Data Analysis](#statistics--data-analysis)
12. [Probability Distributions](#probability-distributions)
13. [Hypothesis Testing](#hypothesis-testing)
14. [Regression Analysis](#regression-analysis)
15. [Calculation History & Favorites](#calculation-history--favorites)
16. [Equation Solver](#equation-solver)
17. [Export & Sharing](#export--sharing)
18. [Settings & Customization](#settings--customization)
19. [Troubleshooting](#troubleshooting)

---

## Getting Started

### First Launch

1. Tap the **Scientific Pro Calculator** icon on your home screen to open the app.
2. You will see the **Calculator Screen** with a numeric keypad, function buttons, and a display area at the top.
3. The app defaults to **Infix mode** (traditional equation entry like "2+3*4").
4. A **mode indicator** at the top-left shows your current input mode (Infix or RPN).

### Main Navigation

The app uses a **bottom navigation bar** with tabs for:
- **Calculator**: Main arithmetic and function entry
- **Graphs**: 2D and 3D function plotting
- **Matrix/Vector**: Matrix operations and vector calculations
- **Statistics**: Data analysis and descriptive statistics
- **Equation Solver**: Solve algebraic equations and systems
- **Units**: Unit conversion across 250+ units
- **Constants**: Physical constants reference library
- **History**: View past calculations
- **Favorites**: Quick access to frequently-used functions
- **Settings**: Customize display, themes, and behavior

---

## Calculator Screen & Basic Operations

### The Display

At the top of the Calculator screen, you see:
- **Input field**: Shows the equation as you type (e.g., "2+3*4")
- **Live preview**: Below the input, the **intermediate results** update in real-time as you type
- **Final result**: The complete result appears below the preview
- **Mode indicator**: Top-left shows "Infix" or "RPN"

### Basic Arithmetic

1. **Open the app** → Calculator tab (default)
2. **Tap numbers** to build your equation:
   - Tap `2` → Tap `+` → Tap `3` → Tap `*` → Tap `4`
   - The input field shows: `2+3*4`
   - The live preview shows intermediate steps
3. **Tap `=` (Equals)** to compute the result
   - Result displays: `14` (respecting order of operations)
4. **Tap `C` (Clear)** to reset the input field and start over

### Standard Operations

- **Addition (+)**: Tap `+`
- **Subtraction (−)**: Tap `−`
- **Multiplication (×)**: Tap `×`
- **Division (÷)**: Tap `÷`
- **Power (x^y)**: Tap `x^y` and enter the exponent
- **Square root (√x)**: Tap `√` and enter the value
- **Reciprocal (1/x)**: Tap `1/x`
- **Negation (−x)**: Tap `+/−` to toggle sign

### Decimal & Negative Numbers

- **Decimal point**: Tap `.` to enter decimals (e.g., `3.14`)
- **Negative numbers**: Tap `+/−` after entering a number to negate it, or enter the minus sign directly

### Undo & Redo

- **Undo**: Tap the **Undo arrow** (↶) button to step back one edit
- **Redo**: Tap the **Redo arrow** (↷) button to step forward
- You can undo/redo through your entire editing history within a session

---

## Input Modes: Infix vs RPN

### Infix Mode (Default)

**Infix** is the traditional way to write equations:
- `2 + 3 * 4` = 14 (multiplication first)
- `(2 + 3) * 4` = 20 (parentheses override order)
- Equations are read left-to-right with standard operator precedence

**How to use Infix:**
1. Open the app → Calculator tab
2. Check the **mode indicator** at top-left (should show "Infix")
3. Type your equation: `2+3*4`
4. Tap `=` to calculate
5. The result respects mathematical order of operations

**Parentheses in Infix:**
- Tap `(` to open a group
- Tap `)` to close a group
- Example: `(2+3)*4` = 20

### RPN Mode (Reverse Polish Notation)

**RPN** is a stack-based notation preferred by engineers and scientific professionals:
- Instead of `2 + 3`, you enter `2 ENTER 3 +`
- The **RPN Stack** is displayed on-screen, showing all values waiting to be operated on
- Each operation pops values from the stack and pushes the result back

**How to switch to RPN:**
1. Open the app → Settings tab
2. Scroll to **Input Mode**
3. Toggle **RPN Mode** ON
4. Return to Calculator tab
5. The **mode indicator** now shows "RPN"

**How to use RPN:**
1. Enter a number: `2`
2. Tap `ENTER` (or `↵`) to push it onto the stack
   - Stack display shows: `[2]`
3. Enter the next number: `3`
4. Tap `ENTER` again
   - Stack display shows: `[2, 3]`
5. Tap `+` to add
   - The stack pops 3 and 2, pushes the result 5
   - Stack display shows: `[5]`
6. The **top indicator** shows the current top-of-stack value

**RPN Stack Visualization:**
- Below the input field, you see a **live stack display** showing all values
- The **topmost value** (at the right or bottom) is the next to be used in operations
- When you tap an operator, the top two values pop, the operation executes, and the result pushes back

**Example: Calculate (2 + 3) × 4 in RPN:**
1. Tap `2` → `ENTER` → Stack: `[2]`
2. Tap `3` → `ENTER` → Stack: `[2, 3]`
3. Tap `+` → Stack: `[5]`
4. Tap `4` → `ENTER` → Stack: `[5, 4]`
5. Tap `×` → Stack: `[20]`
6. Result: 20

**Advantages of RPN:**
- No need for parentheses
- Professional notation for advanced calculations
- Reduces input errors in complex expressions

### Switching Between Modes

- Open Settings → **Input Mode** → toggle **RPN Mode**
- The mode indicator updates immediately
- Your calculation history is preserved; you can switch modes anytime

---

## Advanced Arithmetic

### Trigonometric Functions

1. Open Calculator tab
2. Tap the **function menu** (or swipe to reveal more buttons)
3. Choose your angle unit first:
   - Open Settings → **Angle Unit** → select **Degrees**, **Radians**, or **Gradians**
   - The setting applies to all trig functions
4. Enter a value and tap the function:
   - **sin(x)**: Sine
   - **cos(x)**: Cosine
   - **tan(x)**: Tangent
   - **arcsin(x)**, **arccos(x)**, **arctan(x)**: Inverse trig functions

**Example: Calculate sin(30°)**
1. Settings → Angle Unit → Degrees
2. Calculator → Tap `sin`
3. Enter `30`
4. Tap `=`
5. Result: `0.5`

### Hyperbolic Functions

1. Open Calculator → function menu
2. Tap **sinh(x)**, **cosh(x)**, or **tanh(x)**
3. Enter a value and tap `=`

### Logarithms & Exponentials

- **Natural log (ln)**: Tap `ln(x)`, enter value, tap `=`
- **Base-10 log (log)**: Tap `log(x)`, enter value, tap `=`
- **Logarithm with custom base**: Tap `log_b(x)`, enter the base, then the value
- **Exponential (e^x)**: Tap `e^x`, enter the exponent, tap `=`
- **Power (x^y)**: Tap `x^y`, enter the base, then exponent

### Complex Numbers

1. Open Calculator
2. Enter a complex number using the imaginary unit **i**:
   - Example: `3+4i` (3 plus 4 imaginary)
   - Tap the number, then tap `i` to append the imaginary unit
3. Perform operations: `(3+4i) + (1+2i)` = `4+6i`
4. Tap `=` to calculate
5. The result displays in **Cartesian form** (a+bi) by default

**Extended Result Details for Complex Numbers:**
- After calculating, tap the **result** to expand details
- You see:
  - **Cartesian form**: a + bi
  - **Polar form**: r∠θ (magnitude and phase angle)
  - **Magnitude**: |z| = √(a² + b²)
  - **Phase angle**: θ = atan2(b, a)

### High-Precision Arithmetic

**Precision Settings:**
1. Open Settings
2. Scroll to **Precision**
3. Set **Decimal Places** (0–100)
   - Default: 15 decimal places
   - The app supports up to 100-digit significand and 9-digit exponent
4. Toggle **Digit Separators** ON/OFF for readability
   - ON: `1,234,567.89`
   - OFF: `1234567.89`

**Display Formats:**
1. Settings → **Display Format**
2. Choose:
   - **Fixed-point**: Standard decimal notation (e.g., `1234.567`)
   - **Scientific**: Exponent notation (e.g., `1.234567 × 10³`)
   - **Engineering**: Exponent in multiples of 3 (e.g., `1.234567 × 10³` for thousands)
3. Results update immediately

---

## Symbolic Math & Calculus

### Accessing Symbolic Math

1. Open the app → tap **Symbolic** tab (or find it in the navigation menu)
2. You see the **Symbolic Math Screen** with an input field for equations

### Solving Algebraic Equations

**Solve a single-variable equation:**
1. Symbolic tab → Input field
2. Enter an equation with a variable (e.g., `x^2 - 4 = 0`)
3. Tap **Solve** button
4. Select the variable to solve for (e.g., `x`)
5. Results display:
   - **Symbolic solutions**: Exact forms (e.g., `x = 2, x = -2`)
   - **Numeric solutions**: Decimal approximations
   - **Multiplicity**: How many times each root appears

**Example: Solve x^2 - 4 = 0**
1. Symbolic tab
2. Enter: `x^2 - 4 = 0`
3. Tap Solve
4. Select variable: `x`
5. Results: `x = 2` and `x = -2`

### Systems of Equations

1. Symbolic tab
2. Enter multiple equations separated by commas or on separate lines:
   - `2x + y = 5, x - y = 1`
3. Tap **Solve**
4. Select variables (if not auto-detected)
5. Results display the solution set:
   - `x = 2, y = 1`

### Derivatives

**Symbolic derivative:**
1. Symbolic tab
2. Enter a function: `x^3 + 2x^2 - 5x + 3`
3. Tap **Derivative** button
4. Select the variable: `x`
5. Result displays the symbolic derivative:
   - `3x^2 + 4x - 5`

**Numeric derivative at a point:**
1. Symbolic tab
2. Enter: `derivative(x^3, x, at=2)`
3. Tap **Evaluate**
4. Result: the slope at x=2 (e.g., `16`)

### Integrals

**Indefinite integral (antiderivative):**
1. Symbolic tab
2. Enter a function: `x^2 + 3x`
3. Tap **Integral** button
4. Select the variable: `x`
5. Result: `(x^3)/3 + (3x^2)/2 + C` (with constant of integration)

**Definite integral (area under curve):**
1. Symbolic tab
2. Enter: `integral(x^2, x, from=0, to=2)`
3. Tap **Evaluate**
4. Result: `8/3` or `2.667` (the area from x=0 to x=2)

### Limits

1. Symbolic tab
2. Enter: `limit((x^2 - 1)/(x - 1), x, as_x_approaches=1)`
3. Tap **Evaluate**
4. Result: `2` (the limit as x approaches 1)

### Taylor Series Expansions

1. Symbolic tab
2. Enter: `taylor(sin(x), x, center=0, order=5)`
3. Tap **Evaluate**
4. Result: `x - x^3/6 + x^5/120 + ...` (5th-order approximation)

### Simplify Expressions

1. Symbolic tab
2. Enter a complex expression: `(x^2 + 2x + 1) / (x + 1)`
3. Tap **Simplify**
4. Result: `x + 1` (simplified form)

---

## 2D Function Graphing

### Opening the Graph Screen

1. Open the app → tap **Graphs** tab
2. You see the **2D Graph Screen** with an empty plot area
3. Tap **Add Function** to begin

### Plotting a Single Function

1. Graphs tab → **Add Function**
2. Enter a function in terms of `x`: `sin(x)`
3. Tap **Plot**
4. The function curve appears on the graph in a color-coded line
5. Adjust the **axis range**:
   - Tap the **X-axis min/max** fields and enter values (e.g., -10 to 10)
   - Tap the **Y-axis min/max** fields and enter values
   - Tap **Redraw** to update

### Plotting Multiple Functions

1. Graphs tab → Add Function
2. Enter the first function: `sin(x)`
3. Tap **Plot**
4. Tap **Add Function** again
5. Enter the second function: `cos(x)`
6. Tap **Plot**
7. Both curves now appear on the same graph in different colors

### Zoom & Pan

- **Zoom in**: Pinch two fingers together on the graph
- **Zoom out**: Spread two fingers apart
- **Pan**: Drag the graph with one finger to move the view
- **Reset view**: Tap **Reset Zoom** button

### Trace Tool

1. Graphs tab → open a plotted function
2. Tap **Trace** button
3. Tap any point on the curve
4. A crosshair appears, and the coordinates display:
   - `x: 1.5, y: 0.997` (example)
5. Drag your finger along the curve to follow it
6. The coordinates update in real-time

### Integral Area Highlighting

1. Graphs tab → open a plotted function
2. Tap **Integral Area** button
3. A dialog appears asking for the lower and upper bounds
4. Enter **from** (e.g., `0`) and **to** (e.g., `2`)
5. Tap **Highlight**
6. The area under the curve between those bounds is shaded
7. The **integral value** displays below the graph (e.g., "Area = 2.667")

### Limit Visualization

1. Graphs tab → open a function with a limit
2. Tap **Limit Visualization** button
3. Enter the **x-value** the function approaches (e.g., `1`)
4. Tap **Animate**
5. The graph animates, showing how the function approaches the limit value
6. A horizontal line marks the limit value

### Saving Graphs

1. Graphs tab → after plotting functions
2. Tap **Save Graph**
3. Enter a name: "Trig Functions"
4. Tap **Save**
5. The graph is stored and can be retrieved from **Saved Graphs**

### Exporting Graphs

1. Graphs tab → open a saved or current graph
2. Tap **Export**
3. Choose format:
   - **PDF**: Formatted document with the graph image
   - **PNG/Image**: Just the graph image
4. Tap **Export**
5. The file is saved to your device; you can share it via email or messaging

---

## 3D Surface Graphing

### Opening 3D Graphing

1. Graphs tab → tap **3D Surface** button (or find it in the graphing menu)
2. You see the **3D Graph Screen** with an empty 3D plot area
3. Tap **Add Surface** to begin

### Plotting a 3D Surface

1. Graphs tab → **3D Surface** → **Add Surface**
2. Enter a function of two variables (x and y): `sin(x) * cos(y)`
3. Tap **Plot**
4. A 3D mesh surface appears, colored by height
5. Adjust the **axis ranges**:
   - **X range**: -π to π (default)
   - **Y range**: -π to π (default)
   - **Z range**: auto or manual
6. Tap **Redraw** to update

### Rotating & Zooming 3D Surfaces

- **Rotate**: Drag with one finger to rotate the surface in 3D space
- **Zoom**: Pinch to zoom in/out
- **Pan**: Two-finger drag to move the view
- **Reset view**: Tap **Reset View** button

### Parametric Surfaces

1. Graphs tab → **3D Surface** → **Add Surface**
2. Switch to **Parametric Mode**
3. Enter parametric equations:
   - **x(u, v)**: `u * cos(v)`
   - **y(u, v)**: `u * sin(v)`
   - **z(u, v)**: `v`
4. Set parameter ranges:
   - **u**: 0 to 2
   - **v**: 0 to 2π
5. Tap **Plot**
6. A parametric surface (e.g., a cone) renders in 3D

### Color Mapping

- By default, surfaces are colored by **height (z-value)**
- Red = high values, Blue = low values
- Tap **Color Settings** to customize the color scheme

### Saving & Exporting 3D Graphs

1. 3D Surface → after plotting
2. Tap **Save Surface**
3. Enter a name and tap **Save**
4. To export:
   - Tap **Export**
   - Choose **PDF** or **Image**
   - The 3D surface is rendered as a 2D image in the export

---

## Matrix & Vector Operations

### Opening the Matrix/Vector Screen

1. Open the app → tap **Matrix/Vector** tab
2. You see options for **Create Matrix** or **Create Vector**

### Creating a Matrix

1. Matrix/Vector tab → **Create Matrix**
2. A dialog appears asking for **dimensions**:
   - **Rows**: 3
   - **Columns**: 3
3. Tap **Create**
4. A grid appears with 9 cells (3×3)
5. Tap each cell and enter values:
   - Cell (1,1): `1`
   - Cell (1,2): `2`
   - Cell (1,3): `3`
   - ...and so on
6. Tap **Done** to save the matrix

### Matrix Operations

**Addition:**
1. Matrix/Vector tab → select two matrices
2. Tap **A + B** button
3. Result matrix displays
4. Tap **Copy Result** to use it in further calculations

**Multiplication:**
1. Select two matrices
2. Tap **A × B** button
3. Result displays (if dimensions are compatible)

**Transpose:**
1. Select a matrix
2. Tap **Transpose** button
3. Rows and columns swap; result displays

**Determinant:**
1. Select a square matrix
2. Tap **Determinant** button
3. A single value appears (the determinant)

**Inverse:**
1. Select a square, non-singular matrix
2. Tap **Inverse** button
3. The inverted matrix displays
4. Verify: **A × A⁻¹** should equal the identity matrix

**Trace:**
1. Select a square matrix
2. Tap **Trace** button
3. The sum of diagonal elements displays

**Rank:**
1. Select a matrix
2. Tap **Rank** button
3. The rank (number of linearly independent rows/columns) displays

**Eigenvalues & Eigenvectors:**
1. Select a square matrix
2. Tap **Eigenvalues** button
3. A list of eigenvalues appears
4. Tap an eigenvalue to see its corresponding eigenvector

**Decompositions:**
1. Select a matrix
2. Tap **Decompositions**
3. Choose:
   - **LU Decomposition**: A = LU (lower and upper triangular)
   - **QR Decomposition**: A = QR (orthogonal and upper triangular)
   - **SVD**: Singular Value Decomposition
4. Components display in separate matrices

### Creating a Vector

1. Matrix/Vector tab → **Create Vector**
2. Enter the **dimension**: 3
3. Tap **Create**
4. Enter three values: `[1, 2, 3]`
5. Tap **Done**

### Vector Operations

**Dot Product:**
1. Select two vectors of the same dimension
2. Tap **Dot Product** (or **·**)
3. A single number appears (the scalar result)

**Cross Product:**
1. Select two 3D vectors
2. Tap **Cross Product** (or **×**)
3. A new vector appears (perpendicular to both)

**Magnitude:**
1. Select a vector
2. Tap **Magnitude** (or **||v||**)
3. The length of the vector displays

**Normalization:**
1. Select a vector
2. Tap **Normalize**
3. A unit vector (magnitude = 1) in the same direction displays

### Saving Matrices & Vectors

1. After creating a matrix or vector
2. Tap **Save**
3. Enter a name: "Rotation Matrix"
4. Tap **Save**
5. Access saved matrices from the **Saved Matrices** list

---

## Unit Conversion

### Opening Unit Conversion

1. Open the app → tap **Units** tab
2. You see a list of **unit categories**

### Converting Between Units

1. Units tab → select a category: **Length**
2. You see conversion pairs:
   - **From**: Meters (m)
   - **To**: Kilometers (km)
   - **Input field**: Enter a value
3. Enter `5` in the input field
4. The **output** automatically displays: `0.005 km`
5. Tap **Swap** to reverse the conversion (km to m)

### Available Categories

The app supports 250+ units across:
- **Length**: meters, feet, miles, kilometers, inches, yards, nautical miles, etc.
- **Mass**: kilograms, grams, pounds, ounces, tons, etc.
- **Time**: seconds, minutes, hours, days, weeks, years, etc.
- **Temperature**: Celsius, Fahrenheit, Kelvin
- **Energy**: joules, calories, kilowatt-hours, BTU, etc.
- **Power**: watts, horsepower, kilowatts, etc.
- **Pressure**: pascals, atmospheres, bar, psi, etc.
- **Volume**: liters, gallons, milliliters, cubic meters, etc.
- **Speed**: meters/second, kilometers/hour, miles/hour, knots, etc.
- **And many more...**

### SI Prefixes

The app automatically recognizes SI prefixes:
- **kilo (k)**: 1,000 (e.g., 1 km = 1,000 m)
- **mega (M)**: 1,000,000
- **giga (G)**: 1,000,000,000
- **milli (m)**: 0.001
- **micro (μ)**: 0.000001
- **nano (n)**: 0.000000001

**Example: Convert 5 kilometers to millimeters**
1. Units tab → Length
2. From: Kilometers (km)
3. To: Millimeters (mm)
4. Input: `5`
5. Output: `5,000,000 mm`

### Viewing Conversion Chain

1. Units tab → select a conversion
2. Tap **Show Conversion Chain**
3. The full conversion path displays:
   - `5 km → 5,000 m → 5,000,000 mm`

### Favoriting Unit Conversions

1. Units tab → perform a conversion
2. Tap the **Star icon** to favorite it
3. The conversion appears in the **Favorites** tab for quick access

---

## Physical Constants Reference

### Opening the Constants Library

1. Open the app → tap **Constants** tab
2. You see a searchable list of 90+ physical constants

### Browsing Constants

1. Constants tab → scroll through the list
2. Each constant shows:
   - **Name**: "Planck's Constant"
   - **Symbol**: h
   - **Value**: 6.62607015 × 10⁻³⁴
   - **Unit**: J·s (joule-seconds)

### Searching for Constants

1. Constants tab → tap the **Search field**
2. Type: "speed"
3. Results filter to show matching constants:
   - Speed of light (c)
   - Speed of sound (in various media)

### Inserting Constants into Calculations

1. Constants tab → find the constant you need
2. Tap the constant (e.g., "Speed of light")
3. The constant's **symbol** is copied to your clipboard
4. Switch to **Calculator** tab
5. Tap in the input field and paste: `c`
6. The value is used in your calculation

### Favoriting Constants

1. Constants tab → tap the **Star icon** next to a constant
2. The constant is added to **Favorites**
3. Access it quickly from the Favorites tab

### Common Constants

- **Speed of light (c)**: 299,792,458 m/s
- **Planck's constant (h)**: 6.62607015 × 10⁻³⁴ J·s
- **Gravitational constant (G)**: 6.67430 × 10⁻¹¹ m³·kg⁻¹·s⁻²
- **Avogadro's number (Nₐ)**: 6.02214076 × 10²³ mol⁻¹
- **Boltzmann constant (k_B)**: 1.380649 × 10⁻²³ J·K⁻¹
- **Elementary charge (e)**: 1.602176634 × 10⁻¹⁹ C
- **Fine structure constant (α)**: 7.2973525693 × 10⁻³
- **And 82 more...**

---

## Statistics & Data Analysis

### Opening the Statistics Screen

1. Open the app → tap **Statistics** tab
2. You see the **Statistics Screen** with a data entry table

### Entering Data

1. Statistics tab → **New Dataset**
2. A table appears with empty cells
3. Tap the first cell and enter values:
   - `10`
   - `12`
   - `15`
   - `18`
   - `20`
4. Tap **Calculate** to analyze

### Descriptive Statistics

After entering data and tapping **Calculate**, you see:

- **Mean (Average)**: Sum of all values divided by count
  - Example: (10+12+15+18+20) / 5 = 15
- **Median**: Middle value when sorted
  - Example: 15 (the 3rd value in sorted order)
- **Mode**: Most frequently occurring value
  - Example: No mode (all values appear once)
- **Standard Deviation (σ)**: Measure of spread
  - Example: 4.12 (population) or 4.60 (sample)
- **Variance (σ²)**: Square of standard deviation
  - Example: 16.96 (population) or 21.2 (sample)
- **Min & Max**: Smallest and largest values
  - Min: 10, Max: 20
- **Range**: Max − Min
  - Range: 10
- **Count**: Number of data points
  - Count: 5
- **Sum**: Total of all values
  - Sum: 75
- **Quartiles**: Q1 (25th percentile), Q2 (median), Q3 (75th percentile)

### Multiple Columns (Multivariate Data)

1. Statistics tab → **New Dataset**
2. Tap **Add Column**
3. Enter a name: "Height (cm)"
4. Tap **Add Column** again
5. Enter another name: "Weight (kg)"
6. Enter paired data:
   - Row 1: Height = 170, Weight = 65
   - Row 2: Height = 175, Weight = 72
   - ...and so on
7. Tap **Calculate**
8. Statistics are computed for each column independently

### Correlation Analysis

1. Statistics tab → dataset with multiple columns
2. Tap **Correlation**
3. A correlation matrix displays, showing relationships between columns
   - Values range from -1 (negative correlation) to +1 (positive correlation)
   - Example: Height and Weight might show 0.85 (strong positive)

### Saving Datasets

1. Statistics tab → after entering data
2. Tap **Save Dataset**
3. Enter a name: "Class Test Scores"
4. Tap **Save**
5. Retrieve it later from **Saved Datasets**

### Exporting Data

1. Statistics tab → open a dataset
2. Tap **Export**
3. Choose format:
   - **CSV**: Spreadsheet-compatible format
   - **JSON**: For data interchange
4. The file is saved to your device

---

## Probability Distributions

### Opening Probability Distributions

1. Open the app → tap **Statistics** tab
2. Tap **Distributions** button
3. You see a list of available distributions

### Normal Distribution

1. Statistics tab → **Distributions** → **Normal**
2. A dialog appears for parameters:
   - **Mean (μ)**: 0 (default)
   - **Standard Deviation (σ)**: 1 (default)
3. Enter values (or keep defaults for standard normal)
4. Tap **Evaluate**
5. You see options:
   - **PDF at x**: Probability density at a specific x-value
   - **CDF up to x**: Cumulative probability (P(X ≤ x))
   - **Critical value**: x-value for a given probability

**Example: Find P(X ≤ 1) for standard normal**
1. Statistics → Distributions → Normal
2. Keep μ=0, σ=1
3. Tap **CDF**
4. Enter x = 1
5. Result: 0.8413 (84.13% of values are below 1)

### t-Distribution

1. Statistics → Distributions → **t-Distribution**
2. Enter **degrees of freedom (df)**: 10
3. Choose:
   - **PDF at x**: Probability density
   - **CDF**: Cumulative probability
   - **Inverse CDF**: Find x for a given probability
4. Results display

### Chi-Square Distribution

1. Statistics → Distributions → **Chi-Square**
2. Enter **degrees of freedom (df)**: 5
3. Choose PDF, CDF, or inverse CDF
4. Results display

### F-Distribution

1. Statistics → Distributions → **F-Distribution**
2. Enter **df1** (numerator degrees of freedom): 5
3. Enter **df2** (denominator degrees of freedom): 10
4. Results display

### Binomial Distribution

1. Statistics → Distributions → **Binomial**
2. Enter:
   - **n** (number of trials): 10
   - **p** (probability of success): 0.5
3. Choose:
   - **PMF at k**: Probability of exactly k successes
   - **CDF up to k**: Probability of k or fewer successes
4. Enter k and get the result

**Example: Probability of exactly 5 heads in 10 coin flips**
1. Statistics → Distributions → Binomial
2. n = 10, p = 0.5
3. Tap **PMF**
4. Enter k = 5
5. Result: 0.2461 (24.61% chance)

### Poisson Distribution

1. Statistics → Distributions → **Poisson**
2. Enter **λ (lambda)**: 3 (average rate)
3. Choose PMF or CDF
4. Enter k (number of events)
5. Result displays

### Visualizing Distributions

1. Statistics → Distributions → select a distribution
2. After entering parameters, tap **Plot**
3. A graph appears showing:
   - The distribution curve (PDF or PMF)
   - Shaded area for CDF (if applicable)
   - Critical values marked
4. Use the **Trace tool** to read exact values from the curve

---

## Hypothesis Testing

### Opening Hypothesis Testing

1. Open the app → tap **Statistics** tab
2. Tap **Hypothesis Testing** button
3. Choose a test type

### One-Sample t-Test

1. Statistics → Hypothesis Testing → **t-Test (One Sample)**
2. Enter:
   - **Sample data**: Paste your data or enter values
   - **Null hypothesis (H₀)**: μ = 100 (hypothesized mean)
   - **Alternative hypothesis**: Choose:
     - Two-tailed: μ ≠ 100
     - Left-tailed: μ < 100
     - Right-tailed: μ > 100
   - **Significance level (α)**: 0.05 (default)
3. Tap **Calculate**
4. Results display:
   - **Test statistic (t)**: Value of the t-statistic
   - **P-value**: Probability of observing this result if H₀ is true
   - **Conclusion**: "Reject H₀" or "Fail to reject H₀"
   - **95% Confidence interval**: Range for the true mean

**Example: Test if average student height is 170 cm**
1. Collect heights: [168, 169, 171, 172, 170]
2. Statistics → Hypothesis Testing → t-Test
3. H₀: μ = 170, Alternative: μ ≠ 170
4. α = 0.05
5. Results: t = 0.447, p-value = 0.678
6. Conclusion: Fail to reject H₀ (no evidence against 170 cm)

### Two-Sample t-Test

1. Statistics → Hypothesis Testing → **t-Test (Two Sample)**
2. Enter:
   - **Sample 1 data**: [values]
   - **Sample 2 data**: [values]
   - **Null hypothesis**: μ₁ = μ₂ (means are equal)
   - **Alternative**: Two-tailed, left-tailed, or right-tailed
   - **Equal variances?**: Yes or No (assume equal or unequal variances)
   - **α**: 0.05
3. Tap **Calculate**
4. Results include t-statistic, p-value, and conclusion

### z-Test

1. Statistics → Hypothesis Testing → **z-Test**
2. Enter:
   - **Sample data** or **sample mean**
   - **Sample size**: n
   - **Known population standard deviation**: σ
   - **Null hypothesis**: μ = value
   - **Alternative**: Two-tailed, left, or right
   - **α**: 0.05
3. Results display z-statistic and p-value

### Chi-Square Test

1. Statistics → Hypothesis Testing → **Chi-Square Test**
2. Enter **observed frequencies** (from your data)
3. Enter **expected frequencies** (from theory)
4. Tap **Calculate**
5. Results:
   - **χ² statistic**: Test statistic
   - **P-value**: Significance
   - **Conclusion**: Reject or fail to reject H₀

**Example: Test if a die is fair**
1. Roll the die 60 times and count outcomes
2. Observed: [11, 8, 12, 9, 10, 10] (one count per face)
3. Expected: [10, 10, 10, 10, 10, 10] (fair die)
4. Chi-Square Test
5. Results: χ² = 0.8, p-value = 0.977
6. Conclusion: Fail to reject H₀ (die appears fair)

---

## Regression Analysis

### Opening Regression Analysis

1. Open the app → tap **Statistics** tab
2. Tap **Regression** button
3. Choose a regression type

### Linear Regression

1. Statistics → Regression → **Linear**
2. Enter **X data** (independent variable): [1, 2, 3, 4, 5]
3. Enter **Y data** (dependent variable): [2, 4, 5, 4, 6]
4. Tap **Calculate**
5. Results display:
   - **Equation**: y = 0.9x + 1.2
   - **R² (Coefficient of determination)**: 0.85 (85% of variance explained)
   - **Correlation coefficient (r)**: 0.92 (strong positive correlation)
   - **Standard error**: Measure of fit quality
   - **Confidence intervals**: For slope and intercept

### Polynomial Regression

1. Statistics → Regression → **Polynomial**
2. Enter X and Y data
3. Select **degree**:
   - Degree 2: Quadratic (parabola)
   - Degree 3: Cubic
   - Degree 4: Quartic
   - ...up to degree 10
4. Tap **Calculate**
5. Results include the polynomial equation and R² value

**Example: Quadratic fit**
- Data: (1,1), (2,4), (3,9), (4,16)
- Degree: 2
- Result: y = 1.0x² (perfect fit, R² = 1.0)

### Exponential Regression

1. Statistics → Regression → **Exponential**
2. Enter X and Y data (Y should be positive)
3. Tap **Calculate**
4. Results: y = a × e^(bx)
   - **a**: Initial value
   - **b**: Growth/decay rate
   - **R²**: Fit quality

**Example: Bacterial growth**
- Data: Time (hours) vs. Colony count
- Result: y = 100 × e^(0.5x) (exponential growth)

### Power Law Regression

1. Statistics → Regression → **Power Law**
2. Enter X and Y data (both positive)
3. Tap **Calculate**
4. Results: y = a × x^b
   - **a**: Coefficient
   - **b**: Exponent
   - **R²**: Fit quality

### Plotting Regression Curves

1. Statistics → Regression → (choose type and enter data)
2. Tap **Plot**
3. The **Graphs** screen opens with:
   - **Data points**: Scattered plot of your (x, y) pairs
   - **Regression curve**: The fitted line/curve overlaid
   - **Residuals** (optional): Differences between data and fit
4. Use **Trace** to read values from the curve

### Exporting Regression Results

1. Statistics → Regression → (calculate results)
2. Tap **Export**
3. Choose **PDF** or **CSV**
4. Results are saved with equation, R², and plot

---

## Calculation History & Favorites

### Viewing Calculation History

1. Open the app → tap **History** tab
2. You see a **scrollable list** of all past calculations, newest first
3. Each entry shows:
   - **Input**: The equation you entered (e.g., "2+3*4")
   - **Result**: The answer (e.g., "14")
   - **Timestamp**: When the calculation was performed

### Recalling from History

1. History tab → find a calculation
2. **Tap the entry** to recall it
3. The equation is copied to the **Calculator** input field
4. You can edit it and recalculate

### Copying from History

1. History tab → find a calculation
2. **Long-press the entry**
3. A menu appears:
   - **Copy Input**: Copy the equation
   - **Copy Result**: Copy the answer
   - **Copy Both**: Copy "Input = Result"
4. The text is copied to your clipboard

### Clearing History

1. History tab → tap **Clear History** button
2. A confirmation dialog appears
3. Tap **Yes** to delete all history
4. History is permanently cleared (cannot be undone)

### Exporting History

1. History tab → tap **Export** button
2. Choose format:
   - **CSV**: Spreadsheet format (Input, Result, Timestamp columns)
   - **JSON**: Data interchange format
3. Tap **Export**
4. The file is saved to your device

### History Persistence

- Calculation history is **saved automatically** to your device's local storage
- History persists even after you close the app or restart your device
- Only cleared if you manually delete it or uninstall the app

### Adding to Favorites

1. History tab → find a calculation
2. Tap the **Star icon** next to the entry
3. The entry is added to **Favorites**
4. Access it from the **Favorites** tab for quick recall

---

## Favorites & Quick Access

### Opening Favorites

1. Open the app → tap **Favorites** tab
2. You see a list of starred functions, constants, and conversions

### Adding to Favorites

**From any feature:**
1. Find an item (function, constant, conversion, etc.)
2. Tap the **Star icon** (☆) next to it
3. It turns solid (★) and is added to Favorites

**From History:**
1. History tab → find a calculation
2. Tap the Star icon
3. The calculation is saved as a favorite

### Using Favorites

1. Favorites tab → find what you need
2. Tap the item
3. Depending on the type:
   - **Function**: Copied to Calculator input
   - **Constant**: Copied to clipboard
   - **Unit conversion**: Opened in Units tab
   - **Calculation**: Loaded into Calculator
4. Edit or use as needed

### Customizing Favorites Toolbar

1. Settings → **Favorites Toolbar**
2. Toggle which favorites appear in a quick-access toolbar at the top of Calculator
3. Tap and drag to reorder
4. Tap the **X** to remove from toolbar (but keep in Favorites)

### Removing from Favorites

1. Favorites tab → find the item
2. Tap the **Star icon** (★) to toggle it off
3. The item is removed from Favorites

---

## Equation Solver

### Opening the Equation Solver

1. Open the app → tap **Equation Solver** tab
2. You see an **input field** for entering equations

### Solving Single-Variable Equations

1. Equation Solver tab → input field
2. Enter an equation: `x^2 - 4 = 0`
3. Tap **Solve**
4. The app auto-detects the variable (x)
5. Results display:
   - **Symbolic solutions**: Exact forms (x = 2, x = -2)
   - **Numeric solutions**: Decimal values
   - **Multiplicity**: How many times each root appears

### Solving Multi-Variable Equations

1. Equation Solver tab
2. Enter multiple equations separated by commas:
   - `2x + y = 5, x - y = 1`
3. Tap **Solve**
4. The app detects variables (x, y)
5. Results: `x = 2, y = 1`

### Setting Variable Ranges

1. Equation Solver tab → enter an equation
2. Tap **Options**
3. Set **variable range**:
   - **x from**: -10
   - **x to**: 10
4. Tap **Solve**
5. Only solutions within the range are returned

### Visualizing Solutions

1. Equation Solver tab → solve an equation
2. Tap **Plot**
3. The **Graphs** screen opens, showing:
   - The function curve
   - The x-axis (y = 0)
   - **Red dots** marking the solutions (where curve crosses x-axis)

### Using the Variable Grid

1. Equation Solver tab → for multi-variable systems
2. Below the input, a **grid** appears with one row per variable
3. You can:
   - **Enter initial guesses**: Helps the solver converge
   - **Set bounds**: Restrict search range
   - **View results**: After solving, the grid shows the solution

---

## Export & Sharing

### Exporting Calculations

**As PDF:**
1. Calculator tab → after performing a calculation
2. Tap **Export** button
3. Choose **PDF**
4. A formatted PDF is generated with:
   - Calculation input and result
   - Timestamp
   - Display format (e.g., scientific notation)
5. File is saved; you can share it via email or messaging

**As Text:**
1. Calculator tab → tap **Copy Result**
2. The result is copied to your clipboard
3. Paste it into any app (email, notes, messaging)

### Exporting Graphs

1. Graphs tab → open a saved or current graph
2. Tap **Export**
3. Choose:
   - **PDF**: Graph embedded in a document
   - **PNG/Image**: Just the graph image
4. File is saved

### Exporting History

1. History tab → tap **Export**
2. Choose **CSV** or **JSON**
3. The entire history is exported
4. Open in spreadsheet software (CSV) or data tools (JSON)

### Exporting Datasets

1. Statistics tab → open a dataset
2. Tap **Export**
3. Choose **CSV** or **JSON**
4. Data is saved for external analysis

### Sharing via Clipboard

1. Any result or value → tap **Copy**
2. Open email, messaging, or notes app
3. Paste the value
4. Send or save as needed

### Sharing via App Integration

1. After exporting to PDF or image
2. Tap **Share** button (if available)
3. Android share sheet appears with options:
   - Email
   - Messaging
   - Cloud storage (Google Drive, OneDrive, etc.)
   - Other installed apps
4. Select an app and complete the share

---

## Settings & Customization

### Opening Settings

1. Open the app → tap **Settings** tab
2. You see a scrollable list of customization options

### Display Format

1. Settings → **Display Format**
2. Choose:
   - **Fixed-point**: Standard decimal (e.g., 1234.567)
   - **Scientific**: Exponent notation (e.g., 1.234567 × 10³)
   - **Engineering**: Exponent in multiples of 3
3. Selection applies to all results immediately

### Decimal Places

1. Settings → **Decimal Places**
2. Slide or tap to set (0–100)
3. Default: 15
4. Results are rounded to this precision

### Digit Separators

1. Settings → **Digit Separators**
2. Toggle **ON** or **OFF**
   - ON: `1,234,567.89`
   - OFF: `1234567.89`
3. Applies to all numeric displays

### Angle Unit

1. Settings → **Angle Unit**
2. Choose:
   - **Degrees** (°): 360° = full circle
   - **Radians** (rad): 2π rad = full circle
   - **Gradians** (grad): 400 grad = full circle
3. Applies to all trigonometric functions

### Input Mode

1. Settings → **Input Mode**
2. Toggle **RPN Mode** ON or OFF
   - OFF: Infix mode (default)
   - ON: RPN mode
3. The mode indicator updates at the top of Calculator

### Haptic Feedback

1. Settings → **Haptic Feedback**
2. Toggle **ON** or **OFF**
   - ON: Vibration on each button press
   - OFF: No vibration
3. Requires device to support haptic feedback

### Theme

1. Settings → **Theme**
2. Choose:
   - **Light**: Light background, dark text
   - **Dark**: Dark background, light text
   - **System**: Follow device system setting (auto-switches)
3. Theme applies to entire app

### Full-Screen Mode

1. Settings → **Full-Screen Mode**
2. Toggle **ON** or **OFF**
   - ON: Hides status bar and navigation bar for maximum space
   - OFF: Standard view with system UI
3. Useful on small devices

### Precision Options

1. Settings → **Precision**
2. Configure:
   - **Significand digits**: Up to 100
   - **Exponent digits**: Up to 9
   - **Rounding mode**: Round-half-up, round-down, etc.
3. Higher precision uses more memory

### Help & Documentation

1. Settings → **Help & Documentation**
2. Opens the **Help Screen** with a tree-view of topics:
   - Basics
   - Graphing
   - Matrices
   - Statistics
   - Advanced Features
3. Tap a topic to expand and read detailed explanations
4. Tap a function name to jump to its documentation
5. Use **Search** to find help on specific topics

### About

1. Settings → **About**
2. Shows:
   - App name and version
   - Build number
   - Contact email
   - Links to privacy policy and terms of use

---

## Troubleshooting

### Common Issues

**Q: The app crashes when I try to plot a 3D graph.**
- A: Large grids (100×100 or more) can consume significant memory. Try reducing the grid resolution (e.g., 50×50) or restarting the app.

**Q: My calculation result looks wrong.**
- A: Check:
  1. Input mode (Infix vs RPN) — are you in the correct mode?
  2. Angle unit (Degrees vs Radians) — trigonometry depends on this
  3. Decimal places setting — is the result rounded?
  4. Order of operations — use parentheses to clarify
  5. Verify using an alternative method or calculator

**Q: History is not saving.**
- A: Ensure the app has **storage permission**:
  1. Device Settings → Apps → Scientific Pro Calculator → Permissions
  2. Enable **Storage** (or **Files and Media**)
  3. Restart the app

**Q: Haptic feedback is not working.**
- A: Not all devices support haptic feedback. Check:
  1. Device Settings → Vibration → ensure vibration is enabled
  2. App Settings → Haptic Feedback → toggle OFF and back ON
  3. Some devices may not have a haptic motor

**Q: The app is slow when I enter complex equations.**
- A: Real-time preview is debounced to reduce lag, but very complex equations can still slow it down. Try:
  1. Simplifying the equation
  2. Reducing decimal places (Settings → Decimal Places)
  3. Disabling real-time preview (if option available)
  4. Restarting the app

**Q: I can't find the Constants library.**
- A: Tap the **Constants** tab at the bottom of the screen. If it's not visible, your device may have limited screen space. Swipe through the navigation tabs to find it.

**Q: How do I switch from RPN back to Infix?**
- A: Open Settings → Input Mode → toggle **RPN Mode** OFF. The mode indicator changes immediately.

**Q: My saved graphs disappeared.**
- A: Graphs are saved locally. If you uninstalled and reinstalled the app, saved data is lost. To prevent this, export your graphs as PDF before uninstalling.

**Q: Can I import data from a spreadsheet?**
- A: Not directly. Export your spreadsheet as CSV, then manually copy values into the Statistics data entry table. Alternatively, use the app's export feature to send data to spreadsheet software.

**Q: The matrix operations give an error for "singular matrix."**
- A: A singular matrix has no inverse (determinant = 0). This is mathematically correct. Check your matrix values or use a different operation (e.g., rank, SVD).

**Q: How do I clear all my data?**
- A: Device Settings → Apps → Scientific Pro Calculator → Storage → **Clear Data**. This deletes all history, saved graphs, datasets, and settings. Cannot be undone.

---

## Getting Help

If you encounter an issue not covered here:

1. Open the app → Settings → **Help & Documentation**
2. Search for your topic
3. If unresolved, contact: **contact@example.com**

Provide:
- Description of the problem
- Steps to reproduce
- Your device model and Android version
- App version (from Settings → About)

---

*Last Updated: Installation Date*