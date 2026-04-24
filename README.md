# Scientific Pro Calculator

**App:** Scientific Pro Calculator
**Version:** 1.0.0
**Built by:** [Tateru Pro](https://github.com/ushanboe/tateruProPlus) (one-shot AI build, 2026-04-24)
**Last updated:** 2026-04-25

A full-featured scientific calculator for Android — symbolic computation, graphing, matrices, statistics, complex numbers, unit conversion, and 90+ physical constants. **Built end-to-end by Tateru Pro from a single Spec Chat paragraph, with no manual coding.**

This repo exists as a public **sample app** demonstrating what Tateru's automated build pipeline can produce on a complex, feature-dense brief.

---

## Build stats

| | |
|---|---|
| **Build time** | ~1 hour 56 minutes (one-shot, fully autonomous) |
| **LLM tokens** | 6.1M total across the 9-agent pipeline |
| **Files generated** | 52 Dart files |
| **Build strategy** | 4-phase staged (Foundation → Screens → Logic → Polish) |
| **Build mode** | AI Spec Chat (single conversational paragraph as input) |
| **Output** | Installable Android APK + full Flutter source |
| **Pipeline version** | Tateru Pro v1.0.0-beta.3 (post curated-package-library mod 9.90) |

This was the **first sample app built end-to-end on the curated-package-library pipeline** (mod 9.90 — Tateru's distilled tested-package catalogue). Bob hit some token-budget pressure on the largest screens during the staged build, leaving a few files truncated, but Agent Orange's review-and-fix loop completed the unfinished files in the REVIEW phase. The APK built successfully and runs on Android — proving the self-healing properties of the staged pipeline.

---

## What works today

- ✅ Up to 100-digit significand, 9-digit exponent
- ✅ Basic arithmetic, percentage, modulo, negation
- ✅ Fractions and mixed numbers
- ✅ Unlimited braces, operator priority, repeated operations
- ✅ Variables and symbolic computation
- ✅ Matrices and vectors
- ✅ Complex numbers, rectangular ↔ polar conversion
- ✅ Trigonometric and hyperbolic functions
- ✅ Powers, roots, logarithms
- ✅ Degrees / minutes / seconds conversion
- ✅ Fixed point, scientific, engineering display formats
- ✅ Memory operations (10 extended memories)
- ✅ Result history
- ✅ Binary, octal, hexadecimal numeral systems
- ✅ Logical / bitwise operations and rotations
- ✅ Haptic feedback
- ✅ 90+ physical constants
- ✅ 250+ unit conversions
- ✅ Reverse Polish notation mode
- ✅ Multiple high-quality themes
- ✅ Statistics and regression analysis
- ✅ Sums and products of series
- ✅ Limits

## Known limitations (one build, no human cleanup)

- ⚠️ **Graphing** — 2D function plots, integral area, and 3D graphs were specced but render incompletely. Likely fixable via Tateru's in-app refinement panel — not yet attempted.
- ⚠️ Equations with multiple variables / systems of equations may not solve all cases
- ⚠️ Derivatives and integrals work for common cases but not validated exhaustively

These are honest limitations of a single autonomous build pass. A second refinement round would address most of them.

---

## The original spec (paste into Tateru's Spec Chat to reproduce)

> Users can choose from several high-quality themes.
>
> The calculator has many functions, such as:
> - up to 100 digits of significand and 9 digits of exponent
> - basic arithmetic operations including percentage, modulo and negation
> - fractions and mixed numbers
> - periodic numbers and their conversion to fractions
> - unlimited number of braces
> - operator priority
> - repeated operations
> - equations (with one or more variables, systems of equations)
> - variables and symbolic computation
> - derivatives and integrals
> - graphs of functions, equations, integral area and limits; 3D graphs
> - calculation details — extended information about a calculation like all complex roots, unit circle etc.
> - matrices and vectors
> - statistics
> - regression analysis
> - complex numbers
> - conversion between rectangular and polar coordinates
> - sums and products of series
> - limits
> - advanced number operations such as random numbers, combinations, permutations, common greatest divisor, etc.
> - trigonometric and hyperbolic functions
> - powers, roots, logarithms, etc.
> - degrees, minutes and seconds conversion
> - fixed point, scientific and engineering display format
> - display exponent as SI units prefix
> - memory operations with 10 extended memories
> - clipboard operations with various clipboard formats
> - result history
> - binary, octal and hexadecimal numeral systems
> - logical operations
> - bitwise shifts and rotations
> - haptic feedback
> - more than 90 physical constants
> - conversion among 250 units
> - Reverse Polish notation

That single paragraph was the entire input. Tateru's pipeline expanded it into a 4-phase staged build of 52 Dart files.

---

## Build it yourself

This project was built with [Tateru Pro](https://github.com/ushanboe/tateruProPlus) — a desktop app that turns a one-paragraph idea into an installable Android APK end-to-end, with no human in the loop.

1. Install Tateru Pro (Linux beta available, macOS coming): see the [latest release](https://github.com/ushanboe/tateruProPlus/releases/latest)
2. Bring your own Anthropic API key (BYOK)
3. Open the AI Spec Chat panel
4. Paste the spec above (or write your own)
5. Review the generated brief in the wizard
6. Click Launch — walk away — install the APK on your phone

For more on how Tateru works, see [tateru.app](https://tateru.app) (or the public deep-dive at /how-it-works).

---

## Standard Flutter run instructions

```bash
flutter pub get
flutter run                      # debug build
flutter build apk --release      # release APK
```

---

## License

MIT — feel free to fork, modify, and ship your own version. No royalties, no attribution required.
