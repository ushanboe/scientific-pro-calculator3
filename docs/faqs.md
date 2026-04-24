# Scientific Pro Calculator — Frequently Asked Questions

## General Usage

### 1. What is the difference between Infix and RPN modes?

**Infix** is the traditional way to write math: `2 + 3 * 4 = 14`. You type the equation as you'd write it on paper, and the app respects order of operations (multiplication before addition).

**RPN (Reverse Polish Notation)** is a stack-based method: to calculate 2 + 3, you enter `2 ENTER 3 +`. It's faster for complex calculations once you learn it, and requires no parentheses. Professional engineers and scientists often prefer RPN.

Switch between them in **Settings → Input Mode**.

### 2. How do I switch between Infix and RPN modes?

Open **Settings** → scroll to **Input Mode** → toggle **RPN Mode** ON or OFF.

The mode indicator at the top-left of the Calculator screen shows which mode is active.

### 3. Can I use both modes in the same session?

Yes. You can switch between Infix and RPN anytime via Settings. Your calculation history is preserved across mode switches.

### 4. What angle units does the app support?

Three: **Degrees** (°), **Radians** (rad), and **Gradians** (grad).

Set your preferred unit in **Settings → Angle Unit**. All trigonometric functions (sin, cos, tan, etc.) will use that unit. For example:
- sin(30°) = 0.5 (in Degrees mode)
- sin(π/6) ≈ 0.5 (in Radians mode)

### 5. How do I calculate complex numbers?

Enter them using the imaginary unit **i**:
- Example: `3 + 4i` (3 plus 4i)
- Operations: `(3+4i) + (1+2i) = 4+6i`

After calculating, tap the result to see extended details:
- Cartesian form: a + bi
- Polar form: r∠θ (magnitude and phase angle)

### 6. Can I undo/redo my calculations?

Yes. Tap the **Undo** (↶) and **Redo** (↷) buttons in the Calculator. You can step back through your entire editing history within a session.

### 7. How do I copy a result to my clipboard?

After calculating, tap **Copy Result** (or long-press the result). The value is copied and you can paste it into any app (email, notes, etc.).

### 8. Does the app work offline?

Yes, completely. All calculations happen on your device. No internet connection is required.

### 9. How do I change the display format (fixed, scientific, engineering)?

Open **Settings → Display Format** and choose:
- **Fixed-point**: Standard decimal (1234.567)
- **Scientific**: Exponent notation (1.234567 × 10³)
- **Engineering**: Exponent in multiples of 3

### 10. Can I adjust decimal places?

Yes. Open **Settings → Decimal Places** and set a value from 0 to 100. Default is 15. Results will be rounded to this precision.

## High-Precision Arithmetic

### 11. What does "100-digit significand" mean?

The app can represent numbers with up to 100 significant digits. For example:
- Standard calculator: 1.234567890123456789 (16 digits)
- Scientific Pro Calculator: 1.2345678901234567890123456789...0123456789 (up to 100 digits)

This is useful for very precise scientific and financial calculations.

### 12. How precise are the calculations?

The app supports:
- **Significand**: Up to 100 digits
- **Exponent**: Up to 9 digits (range from 10^-999999999 to 10^999999999)

Precision depends on your settings (Decimal Places) and the complexity of operations.

### 13. Why does my result have a different number of decimal places than I set?

The app rounds to your specified decimal places. However, intermediate calculations use full precision internally. For example:
- Set to 5 decimal places
- Calculate: 1/3 = 0.33333
- But internally, more digits are retained for further calculations

## Graphing

### 14. How do I plot a function?

1. Open **Graphs** tab
2. Tap **Add Function**
3. Enter a function in terms of x: `sin(x)`
4. Tap **Plot**
5. Adjust the axis range if needed

### 15. Can I plot multiple functions on the same graph?

Yes. Tap **Add Function** multiple times. Each function appears in a different color.

### 16. How do I zoom and pan on a graph?

- **Zoom in**: Pinch two fingers together
- **Zoom out**: Spread two fingers apart
- **Pan**: Drag with one finger
- **Reset**: Tap **Reset Zoom**

### 17. What is the Trace tool?

Tap **Trace** on a graph, then tap any point on a curve. A crosshair shows the exact coordinates. Drag your finger along the curve to follow it in real-time.

### 18. How do I visualize an integral (area under a curve)?

1. Graphs tab → open a function
2. Tap **Integral Area**
3. Enter the lower and upper bounds (e.g., from 0 to 2)
4. Tap **Highlight**
5. The area under the curve is shaded, and the integral value is displayed

### 19. Can I plot 3D surfaces?

Yes. Graphs tab → tap **3D Surface** → **Add Surface**. Enter a function of two variables (e.g., `sin(x) * cos(y)`). Rotate and zoom with your fingers.

### 20. Can I plot parametric curves?

Yes, for 3D surfaces. In **3D Surface** mode, switch to **Parametric Mode** and enter equations for x(u,v), y(u,v), and z(u,v).

## Matrices & Vectors

### 21. How do I create a matrix?

1. Open **Matrix/Vector** tab
2. Tap **Create Matrix**
3. Enter dimensions (rows × columns)
4. Tap **Create**
5. Fill in the cells with values
6. Tap **Done**

### 22. What matrix operations are supported?

Addition, multiplication, transpose, inversion, determinant, trace, rank, eigenvalues/eigenvectors, and decompositions (LU, QR, SVD).

### 23. What is a singular matrix, and why can't I invert it?

A singular matrix has a determinant of 0 and no inverse. Mathematically, it's non-invertible. Check your matrix values or use alternative operations (e.g., rank, SVD).

### 24. How do I compute a dot product?

1. Create two vectors
2. Select both
3. Tap **Dot Product**
4. A single number (scalar) appears

### 25. What's the difference between dot and cross products?

- **Dot product**: Scalar result. Measures how aligned two vectors are. Result is a number.
- **Cross product**: Vector result (3D only). Perpendicular to both input vectors. Result is a new vector.

## Unit Conversion

### 26. How many units does the app support?

Over 250 units across length, mass, time, temperature, energy, power, pressure, volume, speed, and more.

### 27. How do I convert between units?

1. Open **Units** tab
2. Select a category (e.g., Length)
3. Choose "From" and "To" units
4. Enter a value
5. The conversion appears instantly

### 28. What are SI prefixes?

Shorthand for powers of 10:
- **kilo (k)**: 1,000
- **mega (M)**: 1,000,000
- **milli (m)**: 0.001
- **micro (μ)**: 0.000001
- **nano (n)**: 0.000000001

The app recognizes these automatically. For example, "km" = kilometers = 1,000 meters.

### 29. Can I convert temperature?

Yes. **Units → Temperature** supports Celsius (°C), Fahrenheit (°F), and Kelvin (K). Example: 0°C = 32°F = 273.15 K.

### 30. How do I see the full conversion chain?

After performing a conversion, tap **Show Conversion Chain**. You'll see the intermediate steps (e.g., 5 km → 5,000 m → 5,000,000 mm).

## Physical Constants

### 31. What physical constants are included?

The app includes 90+ constants such as:
- Speed of light (c)
- Planck's constant (h)
- Gravitational constant (G)
- Avogadro's number (Nₐ)
- Boltzmann constant (k_B)
- Elementary charge (e)
- And many more

### 32. How do I use a physical constant in a calculation?

1. Open **Constants** tab
2. Find the constant (search if needed)
3. Tap it
4. The constant's symbol is copied to your clipboard
5. Switch to **Calculator**
6. Paste the symbol into your equation
7. The constant's value is used in the calculation

### 33. Can I search for constants?

Yes. Constants tab → tap the **Search field** → type a keyword (e.g., "speed"). Results filter in real-time.

## Statistics & Data Analysis

### 34. How do I enter data for statistical analysis?

1. Open **Statistics** tab
2. Tap **New Dataset**
3. Enter values in the table (one per row)
4. Tap **Calculate**
5. Mean, median, standard deviation, etc. appear

### 35. What statistics does the app compute?

Mean, median, mode, standard deviation, variance, min, max, range, sum, count, and quartiles (Q1, Q2, Q3).

### 36. Can I analyze multiple columns of data?

Yes. Tap **Add Column** to add more variables. Enter paired data (e.g., height and weight). The app computes statistics for each column and correlation between columns.

### 37. What is standard deviation?

A measure of how spread out data is from the mean. Low standard deviation = data is clustered near the mean. High standard deviation = data is scattered. The app computes both population (σ) and sample (s) standard deviation.

### 38. Can I export my data?

Yes. Statistics tab → open a dataset → **Export** → choose **CSV** or **JSON**. The file is saved to your device.

## Probability & Hypothesis Testing

### 39. What probability distributions are available?

Normal, t, chi-square, F, binomial, and Poisson.

### 40. How do I evaluate a probability distribution?

1. Statistics tab → **Distributions**
2. Choose a distribution (e.g., Normal)
3. Enter parameters (mean, standard deviation)
4. Choose PDF (probability density) or CDF (cumulative probability)
5. Enter a value and get the result

### 41. What's the difference between PDF and CDF?

- **PDF (Probability Density Function)**: Probability at a specific value
- **CDF (Cumulative Distribution Function)**: Probability up to and including a value

Example (Normal distribution):
- PDF at x=0: "How likely is exactly 0?" (small number)
- CDF up to x=0: "How likely is ≤0?" (0.5 for standard normal)

### 42. How do I run a hypothesis test?

1. Statistics tab → **Hypothesis Testing**
2. Choose a test (t-test, z-test, chi-square)
3. Enter your data, null hypothesis, and significance level (α, usually 0.05)
4. Tap **Calculate**
5. Results show test statistic, p-value, and conclusion (reject or fail to reject)

### 43. What does p-value mean?

The p-value is the probability of observing your data (or more extreme) if the null hypothesis is true. 
- **Low p-value** (< 0.05): Reject the null hypothesis (statistically significant)
- **High p-value** (≥ 0.05): Fail to reject the null hypothesis (not significant)

### 44. Can I run a two-sample t-test?

Yes. Statistics → Hypothesis Testing → **t-Test (Two Sample)**. Enter data from two groups and the app compares their means.

## Regression Analysis

### 45. What regression types are supported?

Linear, polynomial (degrees 2–10), exponential, and power law.

### 46. How do I perform linear regression?

1. Statistics tab → **Regression** → **Linear**
2. Enter X data (independent variable)
3. Enter Y data (dependent variable)
4. Tap **Calculate**
5. Results: equation (y = mx + b), R², and correlation coefficient

### 47. What does R² mean?

R² (coefficient of determination) ranges from 0 to 1:
- **R² = 1**: Perfect fit (all data points on the line)
- **R² = 0.9**: Excellent fit (90% of variance explained)
- **R² = 0.5**: Moderate fit (50% of variance explained)
- **R² ≈ 0**: Poor fit (regression line doesn't match data)

Higher R² = better fit.

### 48. Can I plot the regression curve with my data?

Yes. Statistics → Regression → (enter data) → **Plot**. The Graphs screen opens showing your data points and the fitted curve overlaid.

## Equation Solver

### 49. How do I solve an equation?

1. Open **Equation Solver** tab
2. Enter an equation: `x^2 - 4 = 0`
3. Tap **Solve**
4. Results: `x = 2, x = -2`

### 50. Can I solve a system of equations?

Yes. Enter multiple equations separated by commas:
- `2x + y = 5, x - y = 1`
- Results: `x = 2, y = 1`

### 51. How do I solve equations with multiple variables?

Enter all equations and the app auto-detects variables. If you want to solve for a specific variable, the app will show options.

### 52. Can I visualize the solutions on a graph?

Yes. Equation Solver → (solve an equation) → **Plot**. The Graphs screen shows the function curve and red dots marking the solutions (where the curve crosses the x-axis).

## History & Favorites

### 53. How do I recall a past calculation?

1. Open **History** tab
2. Find the calculation
3. Tap it
4. The equation is loaded into the Calculator input field
5. Edit or recalculate as needed

### 54. How do I clear my calculation history?

History tab → **Clear History** → **Yes**. All history is permanently deleted (cannot be undone).

### 55. Does the app save history between sessions?

Yes. Calculation history is saved locally to your device and persists even after you close the app or restart your phone.

### 56. How do I add something to Favorites?

Tap the **Star icon** (☆) next to any item (function, constant, unit conversion, or calculation). It turns solid (★) and is added to Favorites.

### 57. How do I use Favorites?

Favorites tab → find what you need → tap it. Depending on the type, it's copied to the Calculator, pasted into a field, or opened in the relevant feature.

### 58. Can I customize the Favorites toolbar?

Yes. Settings → **Favorites Toolbar** → toggle which items appear in the quick-access toolbar at the top of the Calculator. Drag to reorder.

## Export & Sharing

### 59. Can I export my calculations?

Yes. Calculator → **Export** → choose **PDF** or **Text**. The file is saved to your device.

### 60. How do I export a graph?

Graphs tab → open a graph → **Export** → choose **PDF** or **Image**. The graph is saved as a file.

### 61. Can I export history as a CSV file?

Yes. History tab → **Export** → **CSV**. The file opens in spreadsheet software with Input, Result, and Timestamp columns.

### 62. How do I share an exported file?

After exporting, tap **Share** (if available). Android's share sheet appears with options: email, messaging, cloud storage, etc. Select an app and complete the share.

## Settings & Customization

### 63. How do I enable/disable haptic feedback?

Settings → **Haptic Feedback** → toggle ON or OFF. When ON, you feel a vibration on each button press (if your device supports it).

### 64. Can I switch between light and dark themes?

Yes. Settings → **Theme** → choose **Light**, **Dark**, or **System** (auto-switches based on device setting).

### 65. What is full-screen mode?

Settings → **Full-Screen Mode** → toggle ON. The status bar and navigation bar are hidden, giving you more space for calculations. Useful on small devices.

### 66. How do I access the help documentation?

Settings → **Help & Documentation**. A tree-view appears with topics (Basics, Graphing, Matrices, Statistics, etc.). Tap to expand and read detailed explanations. Use **Search** to find specific topics.

### 67. What is the RPN mode indicator?

A small label at the top-left of the Calculator screen showing "Infix" or "RPN". It reminds you which input mode is active.

## Data & Privacy

### 68. Is my data shared with anyone?

No. All data (calculations, graphs, history, settings) is stored locally on your device. The app does not connect to any server or share data with third parties.

### 69. Does the app require internet?

No. The app is 100% offline. All calculations happen on your device.

### 70. How do I delete all my data?

Device Settings → Apps → Scientific Pro Calculator → **Storage** → **Clear Data**. All history, saved graphs, datasets, and settings are permanently deleted. Cannot be undone.

### 71. Does the app collect analytics or crash reports?

No. The app does not collect any usage data, analytics, or crash reports.

### 72. Can I back up my data?

Manually export your data:
- History → **Export** → CSV or JSON
- Graphs → **Export** → PDF or Image
- Statistics datasets → **Export** → CSV or JSON
- Matrices → **Export** (if available)

Store these files on cloud storage or a computer for safekeeping.

## Troubleshooting

### 73. Why does the app crash when I plot a large 3D graph?

Large grids (100×100+) consume significant memory. Try reducing the grid resolution (50×50) or restarting the app.

### 74. My calculation result seems wrong. What should I check?

1. **Input mode**: Are you in Infix or RPN? Check the mode indicator.
2. **Angle unit**: For trig functions, check Settings → Angle Unit (Degrees vs Radians).
3. **Decimal places**: Is the result rounded? Check Settings → Decimal Places.
4. **Order of operations**: Use parentheses to clarify (e.g., `(2+3)*4` vs `2+3*4`).
5. **Verify independently**: Use another calculator or method to double-check.

### 75. History is not saving. What do I do?

Ensure the app has storage permission:
1. Device Settings → Apps → Scientific Pro Calculator → **Permissions**
2. Enable **Storage** or **Files and Media**
3. Restart the app

### 76. The app is slow when I type complex equations.

The app debounces real-time preview to reduce lag, but very complex equations can still slow it. Try:
1. Simplifying the equation
2. Reducing decimal places
3. Restarting the app

### 77. Haptic feedback is not working.

Not all devices have a haptic motor. Check:
1. Device Settings → Vibration → enabled?
2. App Settings → Haptic Feedback → toggle OFF and back ON
3. If still not working, your device may not support haptics

### 78. How do I report a bug?

Contact: **contact@example.com**

Include:
- Description of the bug
- Steps to reproduce
- Your device model and Android version
- App version (Settings → About)

## Advanced Topics

### 79. How do I calculate derivatives symbolically?

Symbolic tab → enter a function → **Derivative** → select the variable. The symbolic derivative is displayed (e.g., d/dx of x² = 2x).

### 80. How do I compute definite integrals?

Symbolic tab → enter: `integral(f(x), x, from=a, to=b)` → **Evaluate**. The result is the area under the curve from a to b.

### 81. Can I find limits of functions?

Yes. Symbolic tab → enter: `limit(f(x), x, as_x_approaches=value)` → **Evaluate**. The limit is computed symbolically.

### 82. How do I use Taylor series?

Symbolic tab → enter: `taylor(sin(x), x, center=0, order=5)` → **Evaluate**. The Taylor expansion is displayed (5th-order approximation around x=0).

### 83. What is eigenvalue decomposition useful for?

Eigenvalues and eigenvectors are used in:
- Stability analysis of systems
- Principal component analysis (PCA)
- Vibration analysis
- Quantum mechanics

Matrix/Vector → select a square matrix → **Eigenvalues** to compute them.

### 84. How do I interpret a correlation coefficient?

Correlation (r) ranges from -1 to +1:
- **r ≈ +1**: Strong positive correlation (as x increases, y increases)
- **r ≈ 0**: No correlation (x and y are independent)
- **r ≈ -1**: Strong negative correlation (as x increases, y decreases)

Statistics → open a multi-column dataset → **Correlation** to compute.

### 85. When should I use polynomial vs exponential regression?

- **Polynomial**: Data follows a curved pattern (parabola, cubic, etc.). Use if R² is high.
- **Exponential**: Data grows or decays exponentially (bacteria, radioactive decay). Use if data is always positive and grows/shrinks rapidly.

Try both and compare R² values.

## Contact & Support

### 86. How do I contact support?

Email: **contact@example.com**

Provide:
- Description of your issue
- Steps to reproduce (if applicable)
- Device model and Android version
- App version (Settings → About)

### 87. Is there a user manual?

Yes. Settings → **Help & Documentation** or open the **User Manual** from the app menu. It covers all features in detail.

### 88. Where can I find the privacy policy?

Settings → **Privacy Policy** or open it from the app menu. The policy explains what data is collected and how it's used.

### 89. Where are the terms of use?

Settings → **Terms of Use** or open from the app menu. It outlines your rights and responsibilities when using the app.

### 90. Can I suggest a feature?

Email: **contact@example.com**

Include:
- Description of the feature
- Why it would be useful
- Any relevant examples or use cases

---

*Last Updated: Installation Date*