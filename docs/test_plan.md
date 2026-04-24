# Scientific Pro Calculator — Test Plan

Run these tests on a real Android device after installing the APK. For each test, mark **Pass / Fail / Skip**. Failed tests should be filed as refinement instructions.

---

## Test 1: First Launch & Calculator Screen

1. Fresh install. Launch the app — Expect Calculator screen to appear with numeric keypad, function buttons, and empty input field.
2. Check the **mode indicator** at top-left — Expect to show "Infix" (default mode).
3. Tap `2` → Tap `+` → Tap `3` — Expect input field displays "2+3" and live preview shows "5".
4. Tap `*` → Tap `4` — Expect input field displays "2+3*4" and live preview updates.
5. Tap `=` — Expect result displays "14" (respecting order of operations: 3×4=12, then 2+12=14).
6. Tap `C` — Expect input field clears and returns to empty state.

---

## Test 2: Undo & Redo

1. Calculator screen. Enter: `5` + `3` — Expect input shows "5+3".
2. Tap the **Undo** (↶) button — Expect the last operator (`+`) is removed; input shows "5".
3. Tap **Undo** again — Expect `3` is removed; input shows "5".
4. Tap the **Redo** (↷) button — Expect `3` reappears; input shows "5 3".
5. Tap **Redo** again — Expect `+` reappears; input shows "5+3".

---

## Test 3: Decimal & Negative Numbers

1. Calculator screen. Tap `3` → Tap `.` → Tap `1` → Tap `4` — Expect input shows "3.14".
2. Tap `=` — Expect result displays "3.14".
3. Tap the **+/−** button — Expect result toggles to "-3.14".
4. Tap `+/−` again — Expect result toggles back to "3.14".

---

## Test 4: Trigonometric Functions (Degrees Mode)

1. Open **Settings** → **Angle Unit** → select **Degrees**.
2. Return to Calculator. Tap the **function menu** (or swipe to reveal more buttons).
3. Tap `sin` — Expect a function button labeled "sin" appears in the input.
4. Tap `30` → Tap `=` — Expect result displays "0.5" (sin(30°) = 0.5).
5. Tap the **function menu** again. Tap `cos` → Tap `0` → Tap `=` — Expect result displays "1" (cos(0°) = 1).

---

## Test 5: Complex Numbers

1. Calculator screen. Tap `3` → Tap the **i** button (imaginary unit) — Expect input shows "3i".
2. Tap `+` → Tap `4` → Tap `=` — Expect result displays "4+3i".
3. Tap the **result** to expand details — Expect to see:
   - Cartesian form: 4+3i
   - Polar form: 5∠36.87° (magnitude and phase)
   - Magnitude: 5

---

## Test 6: RPN Mode Toggle

1. Open **Settings** → **Input Mode** → toggle **RPN Mode** ON.
2. Return to Calculator. Check the **mode indicator** at top-left — Expect to show "RPN".
3. Tap `2` → Tap `ENTER` — Expect the **RPN Stack** display shows `[2]`.
4. Tap `3` → Tap `ENTER` — Expect stack displays `[2, 3]`.
5. Tap `+` — Expect stack pops 2 and 3, pushes 5; stack displays `[5]`.
6. Tap `4` → Tap `ENTER` — Expect stack displays `[5, 4]`.
7. Tap `×` — Expect stack displays `[20]` (5 × 4 = 20).
8. Toggle RPN Mode OFF in Settings — Expect mode indicator returns to "Infix".

---

## Test 7: Display Format & Decimal Places

1. Calculator screen. Tap `1` → Tap `/` → Tap `3` → Tap `=` — Expect result displays a decimal approximation (e.g., "0.333333").
2. Open **Settings** → **Display Format** → select **Scientific**.
3. Return to Calculator — Expect the same result now displays in scientific notation (e.g., "3.333333 × 10⁻¹").
4. Settings → **Decimal Places** → set to `5`.
5. Return to Calculator — Expect result now shows "3.33333" (5 decimal places).
6. Settings → **Display Format** → select **Fixed-point**.
7. Return to Calculator — Expect result displays "0.33333" (5 decimal places, fixed format).

---

## Test 8: 2D Function Graphing

1. Open the **Graphs** tab — Expect an empty plot area and an **Add Function** button.
2. Tap **Add Function** — Expect an input dialog appears.
3. Enter `sin(x)` → Tap **Plot** — Expect a sine curve renders on the graph (smooth oscillating line).
4. Pinch two fingers to **zoom in** — Expect the graph magnifies.
5. Spread two fingers to **zoom out** — Expect the graph shrinks back.
6. Drag with one finger to **pan** — Expect the view shifts.
7. Tap **Reset Zoom** — Expect the graph returns to default view.
8. Tap **Trace** → Tap a point on the curve — Expect a crosshair appears and coordinates display (e.g., "x: 1.5, y: 0.997").

---

## Test 9: Integral Area Visualization

1. Graphs tab → open the `sin(x)` function from Test 8.
2. Tap **Integral Area** button — Expect a dialog appears asking for bounds.
3. Enter **from**: `0`, **to**: `π` (or `3.14159`) → Tap **Highlight** — Expect the area under the sine curve from 0 to π is shaded.
4. Below the graph, a value displays (e.g., "Area = 2.0") — Expect this matches the integral of sin(x) from 0 to π.

---

## Test 10: 3D Surface Graphing

1. Graphs tab → tap **3D Surface** (or find it in the graphing menu).
2. Tap **Add Surface** — Expect an input dialog appears.
3. Enter `sin(x) * cos(y)` → Tap **Plot** — Expect a 3D mesh surface renders (colorful grid).
4. Drag with one finger on the surface — Expect it rotates in 3D space.
5. Pinch to **zoom in/out** — Expect the surface magnifies or shrinks.
6. Tap **Reset View** — Expect the surface returns to default orientation.

---

## Test 11: Matrix Operations

1. Open the **Matrix/Vector** tab — Expect options for **Create Matrix** and **Create Vector**.
2. Tap **Create Matrix** → Enter dimensions: **Rows**: 2, **Columns**: 2 → Tap **Create** — Expect a 2×2 grid appears.
3. Fill in values:
   - (1,1): `1`
   - (1,2): `2`
   - (2,1): `3`
   - (2,2): `4`
4. Tap **Done** — Expect the matrix is saved.
5. Tap **Determinant** — Expect a value displays (e.g., "-2" for the 2×2 matrix [[1,2],[3,4]]).
6. Tap **Transpose** — Expect rows and columns swap; the matrix now shows [[1,3],[2,4]].

---

## Test 12: Unit Conversion

1. Open the **Units** tab — Expect a list of unit categories.
2. Tap **Length** — Expect conversion fields appear (From: Meters, To: Kilometers).
3. Enter `5` in the input field — Expect the output automatically displays "0.005 km".
4. Tap **Swap** — Expect the conversion reverses (From: km, To: m, input: 0.005, output: 5).
5. Change **From** to "Miles" and **To** to "Kilometers" — Expect real-time preview updates.
6. Tap **Show Conversion Chain** — Expect the full conversion path displays (e.g., "5 miles → 8.047 km").

---

## Test 13: Physical Constants

1. Open the **Constants** tab — Expect a searchable list of 90+ physical constants.
2. Scroll through the list — Expect to see constants like "Speed of light (c)", "Planck's constant (h)", etc.
3. Tap the **Search field** → Type "speed" — Expect results filter to show speed-related constants.
4. Tap **Speed of light** — Expect the constant's symbol (c) is copied to clipboard.
5. Switch to **Calculator** tab → Tap in the input field → Paste — Expect the symbol `c` appears.
6. Tap **Star icon** next to a constant — Expect it's added to **Favorites**.

---

## Test 14: Calculation History

1. Calculator screen. Perform several calculations:
   - `2 + 2 = 4`
   - `10 - 3 = 7`
   - `5 * 6 = 30`
2. Open the **History** tab — Expect a list of all three calculations, newest first.
3. Tap the first calculation (`5 * 6`) — Expect the equation is loaded into the Calculator input field.
4. Modify it: Clear and enter `5 * 7` → Tap `=` — Expect result is `35` and the history updates.
5. Long-press a history entry — Expect a context menu appears with options: **Copy Input**, **Copy Result**, **Copy Both**.
6. Select **Copy Result** — Expect the result is copied to clipboard.
7. Tap **Clear History** → Confirm **Yes** — Expect all history is deleted and the list becomes empty.

---

## Test 15: Statistics & Descriptive Analysis

1. Open the **Statistics** tab — Expect a data entry table.
2. Tap **New Dataset** — Expect an empty table appears.
3. Enter values: `10`, `12`, `15`, `18`, `20`
4. Tap **Calculate** — Expect results display:
   - Mean: 15
   - Median: 15
   - Standard Deviation: ~4.12 (population) or ~4.60 (sample)
   - Min: 10, Max: 20
5. Tap **Add Column** → Name it "Heights" — Expect a second column appears.
6. Enter paired data (e.g., values 160, 165, 170, 175, 180).
7. Tap **Correlation** — Expect a correlation matrix displays showing the relationship between the two columns.

---

## Test 16: Probability Distributions

1. Statistics tab → Tap **Distributions** → Select **Normal** — Expect a dialog appears for parameters.
2. Keep **Mean (μ)**: 0 and **Std Dev (σ)**: 1 (standard normal).
3. Tap **CDF** → Enter x: `1` → Tap **Calculate** — Expect result displays "0.8413" (cumulative probability up to 1).
4. Return and select **Binomial** → Enter **n**: 10, **p**: 0.5.
5. Tap **PMF** → Enter k: `5` — Expect result displays "0.2461" (probability of exactly 5 successes in 10 trials).
6. Tap **Plot** — Expect the Graphs screen opens showing the distribution curve.

---

## Test 17: Hypothesis Testing

1. Statistics tab → Tap **Hypothesis Testing** → Select **t-Test (One Sample)**.
2. Enter sample data: `[100, 102, 98, 101, 99]`
3. Set **Null hypothesis**: μ = 100, **Alternative**: Two-tailed, **α**: 0.05.
4. Tap **Calculate** — Expect results display:
   - Test statistic (t): A value
   - P-value: A probability
   - Conclusion: "Fail to reject H₀" or "Reject H₀"
5. Change **α** to 0.01 and recalculate — Expect the conclusion may change based on stricter significance level.

---

## Test 18: Linear Regression

1. Statistics tab → Tap **Regression** → Select **Linear**.
2. Enter **X data**: `[1, 2, 3, 4, 5]`
3. Enter **Y data**: `[2, 4, 5, 4, 6]`
4. Tap **Calculate** — Expect results display:
   - Equation: y = mx + b (e.g., "y = 0.9x + 1.2")
   - R²: A value between 0 and 1 (e.g., 0.85)
   - Correlation coefficient (r): (e.g., 0.92)
5. Tap **Plot** — Expect the Graphs screen opens showing data points and the regression line overlaid.

---

## Test 19: Equation Solver

1. Open the **Equation Solver** tab — Expect an input field for equations.
2. Enter: `x^2 - 4 = 0` → Tap **Solve** — Expect results display: `x = 2, x = -2`.
3. Enter: `x^3 - 1 = 0` → Tap **Solve** — Expect results display three solutions (one real: x=1, two complex).
4. Enter a system: `2x + y = 5, x - y = 1` → Tap **Solve** — Expect results: `x = 2, y = 1`.
5. Tap **Plot** — Expect the Graphs screen opens showing the function curve with red dots marking solutions.

---

## Test 20: Symbolic Math & Calculus

1. Open the **Symbolic** tab — Expect an input field for symbolic operations.
2. Enter: `x^2 + 3x` → Tap **Derivative** → Select variable: `x` — Expect result displays "2x + 3".
3. Enter: `x^2` → Tap **Integral** → Select variable: `x` — Expect result displays "(x^3)/3 + C".
4. Enter: `(x^2 - 1) / (x - 1)` → Tap **Simplify** — Expect result displays "x + 1".
5. Enter: `sin(x)` → Tap **Taylor Series** → Set order: 5 → Expect result displays the 5th-order Taylor expansion.

---

## Test 21: Favorites & Quick Access

1. Calculator screen. Perform a calculation: `2 + 2 = 4`.
2. In the History tab, tap the **Star icon** next to this calculation — Expect it's added to Favorites.
3. Open **Constants** tab → Find "Speed of light" → Tap the **Star icon** — Expect it's added to Favorites.
4. Open **Favorites** tab — Expect both the calculation and constant appear in the list.
5. Tap the calculation in Favorites — Expect it's loaded into the Calculator input.
6. Settings → **Favorites Toolbar** → Toggle some favorites ON/OFF — Expect a toolbar at the top of Calculator shows/hides items.

---

## Test 22: Settings & Theme Customization

1. Open **Settings** → **Theme** → Select **Dark**.
2. Return to Calculator — Expect the entire app switches to dark theme (dark background, light text).
3. Settings → **Theme** → Select **Light** — Expect the app switches back to light theme.
4. Settings → **Theme** → Select **System** — Expect the theme follows the device's system setting.
5. Settings → **Haptic Feedback** → Toggle **OFF** → Return to Calculator → Tap a button — Expect no vibration.
6. Settings → **Haptic Feedback** → Toggle **ON** → Return to Calculator → Tap a button — Expect a vibration (if device supports it).
7. Settings → **Full-Screen Mode** → Toggle **ON** — Expect the status bar and navigation bar are hidden.
8. Settings → **Full-Screen Mode** → Toggle **OFF** — Expect the UI returns to normal.

---

## Test 23: Export & Sharing

1. Calculator screen. Perform a calculation: `sin(π/2) = 1`.
2. Tap **Export** → Choose **PDF** — Expect a PDF file is generated and saved.
3. Graphs tab → Open a plotted function → Tap **Export** → Choose **PDF** — Expect a PDF with the graph image is saved.
4. History tab → Tap **Export** → Choose **CSV** — Expect a CSV file with all history entries is saved.
5. Statistics tab → Open a dataset → Tap **Export** → Choose **JSON** — Expect a JSON file with the dataset is saved.
6. After exporting, tap **Share** (if available) — Expect Android's share sheet appears with options (email, messaging, cloud storage, etc.).

---

## Test 24: Help & Documentation

1. Open **Settings** → **Help & Documentation** — Expect a tree-view of help topics appears.
2. Tap **Basics** → Expect it expands showing sub-topics (e.g., "Getting Started", "Calculator Modes").
3. Tap a sub-topic (e.g., "Trigonometric Functions") — Expect detailed explanation and instructions render.
4. Tap the **Search field** → Type "matrix" — Expect results filter to show matrix-related topics.
5. Tap a result — Expect the help article displays.

---

## Test 25: Stress Test (Rapid Navigation & State Management)

1. Calculator screen. Tap buttons rapidly: `1`, `+`, `2`, `=`, `C`, `3`, `*`, `4`, `=` — Expect the app does not crash and results display correctly.
2. Rapidly switch between tabs: Calculator → Graphs → Matrix → Statistics → Calculator — Expect smooth transitions and no crashes.
3. Open a graph, zoom rapidly (pinch in and out), pan (drag), then switch to another tab — Expect no lag or crashes.
4. Enter a very long equation: `1+2+3+4+5+6+7+8+9+10+11+12+13+14+15+16+17+18+19+20` → Tap `=` — Expect the app computes and displays the result (210) without freezing.
5. Force-stop the app (Device Settings → Apps → Scientific Pro Calculator → **Force Stop**).
6. Relaunch the app — Expect it starts normally, history and settings are preserved, and no data is lost.
7. Open History → Perform more calculations → Force-stop → Relaunch — Expect all new calculations are saved.

---

## Test 26: Permission & Graceful Degradation

1. Device Settings → Apps → Scientific Pro Calculator → **Permissions** → Disable **Storage** (or **Files and Media**).
2. Return to the app → Try to export a calculation as PDF — Expect a permission error message or graceful fallback (e.g., "Storage permission required").
3. Device Settings → Re-enable **Storage** permission.
4. Return to the app → Try to export again — Expect the export succeeds.

---

## Test 27: Data Persistence & App Lifecycle

1. Calculator screen. Perform a calculation: `2 + 2 = 4`.
2. Open History — Expect the calculation is listed.
3. Add it to Favorites — Expect the Star icon is filled.
4. Close the app (tap Home or back button).
5. Relaunch the app — Expect:
   - History still shows the calculation
   - Favorites still shows the starred item
   - Settings are preserved (theme, decimal places, etc.)
6. Perform a new calculation in a different mode (RPN) → Close → Relaunch — Expect the mode is preserved.

---

## Test 28: Edge Cases & Error Handling

1. Calculator screen. Tap `/` → Tap `0` → Tap `=` — Expect an error message ("Division by zero") or "Infinity" result.
2. Enter: `sqrt(-1)` → Tap `=` — Expect the result displays as a complex number (0+1i) or an error, depending on implementation.
3. Matrix/Vector tab → Create a 3×3 matrix → Try to invert it with determinant = 0 — Expect an error ("Singular matrix").
4. Statistics tab → Enter an empty dataset → Tap **Calculate** — Expect an error ("No data provided") or graceful handling.
5. Equation Solver → Enter an equation with no solution (e.g., `x^2 + 1 = 0` in real numbers) → Expect results show complex solutions or "No real solutions".

---

## Test 29: Display Format Edge Cases

1. Calculator screen. Set **Decimal Places** to 0 → Perform a calculation: `1 / 3` → Expect result displays "0" (rounded).
2. Set **Decimal Places** to 100 → Perform the same calculation — Expect the result displays with up to 100 decimal places.
3. Set **Display Format** to **Engineering** → Calculate `0.000001` → Expect result displays as "1.0 × 10⁻⁶" (exponent in multiples of 3).
4. Set **Digit Separators** to ON → Calculate `1234567.89` → Expect result displays as "1,234,567.89".
5. Set **Digit Separators** to OFF → Expect result displays as "1234567.89".

---

## Test 30: Multi-Variable & Complex Workflows

1. Equation Solver → Solve a system:
   - `x + y + z = 6`
   - `2x - y + z = 3`
   - `x + y - z = 0`
   - Expect results: `x = 1, y = 2, z = 3`
2. Matrix/Vector → Create a 3×3 matrix with these solutions → Compute eigenvalues — Expect numeric results.
3. Statistics → Enter a dataset → Run linear regression → Plot on Graphs → Expect the data and regression line render correctly.
4. Symbolic → Compute the derivative of the regression equation → Expect the symbolic derivative displays.
5. All operations complete without crashes or data loss — Expect the app remains stable throughout.

---

*All tests completed. Document results and file any failures as refinement instructions.*