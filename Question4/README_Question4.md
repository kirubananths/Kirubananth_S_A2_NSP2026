# Question 4: Trial-Count Bias Analysis in EEG Connectivity Metrics

## Overview

This MATLAB script demonstrates the **positive bias** in connectivity metrics (Coherence and WPLI) when using fewer trials, and proves that **PPC is an unbiased estimator**. The analysis compares metrics computed with all trials versus 1/3 of trials to quantify the bias.

**Author:** Kirubananth S  
**Main File:** `Question4_Complete_Code_FIXED.m`  
**Appendix File:** `Question4_StandardFFT_Code.m`  
**Related:** NSP2026 Assignment 2 (Neural Signal Processing), EEG Module

## Scientific Background

### Trial-Count Bias Problem

When estimating connectivity from limited trials, most metrics show **positive bias**:
- Fewer trials → **artificially inflated** connectivity values
- Bias decreases as trial count increases
- Critical issue when comparing studies with different trial counts

### The Three Metrics

**Coherence** - BIASED:
```
C = |E[S₁₂]| / sqrt(E[S₁₁] * E[S₂₂])

Expected bias: E[C] > true_C when N is small
```

**WPLI** - BIASED:
```
WPLI = |E{imag(S₁₂)}| / E{|imag(S₁₂)|}

Expected bias: E[WPLI] > true_WPLI when N is small
```

**PPC** - UNBIASED:
```
PPC = (|Σ exp(i*θⱼ)|² - N) / (N*(N-1))

Mathematical proof: E[PPC] = PLV² regardless of N!
```

### Why PPC is Unbiased

The key insight from Vinck et al. (2010):
1. Naive estimator includes **diagonal terms** (self-products) → bias
2. PPC **excludes diagonal terms** and normalizes by N(N-1)
3. This exactly cancels the 1/N bias term
4. Result: **E[PPC] = PLV²** for any N

## Features

### Question 4(a): Empirical Bias Demonstration
- Compare connectivity metrics using:
  - **Full dataset:** All trials (N ≈ 235)
  - **Reduced dataset:** 1/3 of trials (N ≈ 78)
- Quantify bias: Metric_reduced - Metric_full
- Show that Coherence and WPLI have positive bias
- Show that PPC has minimal/zero bias

### Question 4(b): Mathematical Derivation
- Step-by-step proof that PPC is unbiased
- Printed to console during execution
- Explains why diagonal term removal works
- Shows E[PPC] = PLV² mathematically

## Requirements

### MATLAB Version
- MATLAB R2016b or later (tested with R2023b)

### Toolboxes
1. **Chronux Toolbox** (required for main code)
   - Download from: http://chronux.org/
   - Functions used:
     - `mtfftc` - Multi-taper FFT
     - `dpss` - Discrete prolate spheroidal sequences

2. **MATLAB Signal Processing Toolbox** (standard)
   - Required for appendix code (uses `fft`)

### Custom Functions
None required - all computations are self-contained.

## Directory Setup

### Required Directory Structure

```
your_working_directory/
├── Question4_Complete_Code_FIXED.m    # Main analysis (multi-taper)
├── Question4_StandardFFT_Code.m       # Appendix (standard FFT)
├── M1_ep_v8.mat                       # REQUIRED: M1 protocol data
└── chronux/                           # Or in MATLAB path (main code only)
    ├── spectral_analysis/
    └── ...
```

### Essential Files in Same Directory

**1. Question4_Complete_Code_FIXED.m** (main script)
   - Primary analysis using multi-taper method
   - Submit this code and its results
   - Includes mathematical derivation output

**2. Question4_StandardFFT_Code.m** (appendix)
   - Alternative implementation using standard FFT
   - For comparison purposes only
   - Demonstrates robustness of findings across methods

**3. M1_ep_v8.mat** (REQUIRED)
   - M1 protocol EEG data, unipolar reference
   - Subject: 013AR
   - Must be in the **same directory** as scripts

### Files Created During Execution

**Main Code Output:**
```
your_working_directory/
├── Question4_Complete_Code_FIXED.m
├── M1_ep_v8.mat
└── Question_4_Plots/                           # Created automatically
    ├── Q4a_comprehensive_bias_comparison.png   # 6-panel comparison
    ├── Q4a_comprehensive_bias_comparison.fig
    ├── Q4a_coherence_comparison.png            # Individual metrics
    ├── Q4a_coherence_comparison.fig
    ├── Q4a_wpli_comparison.png
    ├── Q4a_wpli_comparison.fig
    ├── Q4a_ppc_comparison_unbiased.png
    ├── Q4a_ppc_comparison_unbiased.fig
    ├── Q4a_bias_difference_plots.png           # 3-panel bias plots
    ├── Q4a_bias_difference_plots.fig
    └── Q4_results.mat                          # All results saved
```

**Appendix Code Output:**
```
Question_4_Plots_FFT/                           # Different directory
├── Q4_comprehensive_bias_analysis.png          # Single 6-panel plot
├── Q4_comprehensive_bias_analysis.fig
└── Q4_results.mat
```

### Pre-Execution Checklist

Before running the scripts:

**Main Code:**
- [ ] `Question4_Complete_Code_FIXED.m` is in current directory
- [ ] `M1_ep_v8.mat` is in the **same directory**
- [ ] Chronux toolbox is in MATLAB path
- [ ] You have write permissions

**Appendix Code:**
- [ ] `Question4_StandardFFT_Code.m` is in current directory
- [ ] `M1_ep_v8.mat` is in the **same directory**
- [ ] Chronux is NOT required (standard FFT only)
- [ ] You have write permissions

### Quick Setup Commands

```matlab
% Navigate to working directory
cd('/path/to/your/working/directory');

% Verify main script and data
assert(exist('Question4_Complete_Code_FIXED.m', 'file') == 2, 'Main script not found!');
assert(exist('M1_ep_v8.mat', 'file') == 2, 'M1 data file not found!');

% Add Chronux for main code
if ~exist('mtfftc', 'file')
    addpath(genpath('/path/to/chronux/'));
end

% Verify Chronux (main code only)
assert(exist('mtfftc', 'file') == 2, 'Chronux not found!');
assert(exist('dpss', 'file') == 2, 'DPSS function not found!');

fprintf('Setup complete! Ready to run Question4_Complete_Code_FIXED.m\n');

% For appendix code, Chronux is not required
fprintf('Appendix code can run without Chronux (uses standard FFT)\n');
```

## Input Data

### Required File: M1_ep_v8.mat

Must contain a `data` structure with:

```matlab
data.fsample       % Sampling frequency (Hz)
data.timeVals      % Time vector
data.label         % Cell array of electrode labels (must include 'PO3' and 'AF4')
data.numTrials     % Number of trials (typically 235)
data.trial         % Cell array: 64 electrodes × time points per trial
```

### Expected Data Specifications
- **Protocol:** M1
- **Subject:** 013AR
- **Reference:** Unipolar
- **Sampling rate:** 1000 Hz
- **Number of electrodes:** 64 (must include PO3 and AF4)
- **Number of trials:** Typically 235
- **Time range:** Must include [0.25, 0.75] seconds

## Output

### Main Code Output Structure
```
Question_4_Plots/
├── Q4a_comprehensive_bias_comparison.png   # 6 panels: Full/Reduced/Bias for 3 metrics
├── Q4a_comprehensive_bias_comparison.fig
├── Q4a_coherence_comparison.png            # Individual metric comparisons
├── Q4a_coherence_comparison.fig
├── Q4a_wpli_comparison.png
├── Q4a_wpli_comparison.fig
├── Q4a_ppc_comparison_unbiased.png
├── Q4a_ppc_comparison_unbiased.fig
├── Q4a_bias_difference_plots.png           # 3 panels: Bias only
├── Q4a_bias_difference_plots.fig
└── Q4_results.mat                          # MATLAB workspace
```

**Total output:** 5 plots (10 files: .png and .fig for each)

### Results MAT File Contents

```matlab
results.frequency          % Frequency vector (Hz)
results.N_full            % Number of trials (full dataset)
results.N_reduced         % Number of trials (reduced dataset)
results.selected_trials   % Indices of randomly selected trials

% Full dataset metrics
results.full.coherence
results.full.wpli
results.full.ppc

% Reduced dataset metrics
results.reduced.coherence
results.reduced.wpli
results.reduced.ppc

% Bias (Reduced - Full)
results.bias.coherence         % Frequency-domain bias vector
results.bias.wpli             % Frequency-domain bias vector
results.bias.ppc              % Frequency-domain bias vector
results.bias.coherence_mean   % Mean bias across frequencies
results.bias.wpli_mean        % Mean bias across frequencies
results.bias.ppc_mean         % Mean bias across frequencies

% Cross-spectra (for further analysis)
results.S12_full
results.S12_reduced
results.S11_full, S11_reduced
results.S22_full, S22_reduced
```

### Plot Descriptions

**1. Comprehensive Comparison (6 panels):**
- Top row: Full vs Reduced for each metric
  - Coherence: Blue (full) vs Red (reduced)
  - WPLI: Blue (full) vs Red (reduced)
  - PPC: Blue (full) vs Red (reduced)
- Bottom row: Bias plots
  - Shows Reduced - Full for each metric
  - Zero line (black dashed) for reference

**2-4. Individual Metric Comparisons:**
- Larger, detailed views of each metric
- Full vs Reduced overlaid
- Optimized y-axis scaling

**5. Bias Difference Plots (3 panels):**
- Side-by-side bias comparison
- Shows bias magnitude across frequencies
- Highlights PPC's minimal bias

### Mathematical Derivation Output (Console)

During execution, Question 4(b) prints a complete mathematical derivation:

```
QUESTION 4(b): MATHEMATICAL DERIVATION
========================================

STEP 1: Define Phase Locking Value (PLV)
STEP 2: Naive Estimator of PLV²
STEP 3: Expanding the Squared Magnitude
STEP 4: Separating Diagonal and Off-Diagonal Terms
STEP 5: Taking Expectation
STEP 6: Deriving Unbiased Estimator (PPC)
STEP 7: Verify Unbiased Property

CONCLUSION:
  E[PPC] = PLV²  (UNBIASED!)
```

## Usage

### Running the Main Code

```matlab
% Navigate to directory
cd('/path/to/your/working/directory');

% Run main analysis (multi-taper)
Question4_Complete_Code_FIXED
```

### Running the Appendix Code

```matlab
% Navigate to directory
cd('/path/to/your/working/directory');

% Run appendix analysis (standard FFT)
Question4_StandardFFT_Code
```

### Full Setup and Execution

```matlab
% Complete setup script
clear all; close all; clc;

% Set paths
workDir = '/Users/kirubananth/Documents/MATLAB/NS303/Assignment2/';
chronuxPath = '/Users/kirubananth/Documents/MATLAB/chronux/';

% Navigate to working directory
cd(workDir);

% Add Chronux for main code
addpath(genpath(chronuxPath));

% Verify files
assert(exist('Question4_Complete_Code_FIXED.m', 'file') == 2, 'Main script not found!');
assert(exist('M1_ep_v8.mat', 'file') == 2, 'Data file not found!');

% Verify Chronux
assert(exist('mtfftc', 'file') == 2, 'Chronux not found!');

fprintf('Running main analysis (multi-taper)...\n\n');

% Run main analysis
Question4_Complete_Code_FIXED

fprintf('\n\nMain analysis complete! See console for Q4(b) derivation.\n');

% Optional: Run appendix code
fprintf('\nRunning appendix analysis (standard FFT)...\n\n');
Question4_StandardFFT_Code

fprintf('\n\nBoth analyses complete!\n');
```

### Expected Runtime
- **Main code:** ~10-15 seconds
- **Appendix code:** ~5-8 seconds (faster, no multi-taper)
- Includes spectral computation and multiple plot generation

## Algorithm Details

### Main Code: Multi-Taper Bias Analysis

**Parameters:**
```matlab
TW = 2              % Time-bandwidth product
K = 3               % Number of tapers
W = 4 Hz            % Frequency smoothing: ±4 Hz
Frequency range: 0-50 Hz
Data window: [0.25, 0.75]s (stimulus period)
```

**Analysis Workflow:**

**1. Compute Multi-Taper Spectra for ALL Trials:**
```matlab
J_PO3_all = mtfftc(dataPO3_all, tapers, nfft, Fs)
J_AF4_all = mtfftc(dataAF4_all, tapers, nfft, Fs)

S12_full = mean(conj(J_PO3_all) .* J_AF4_all, 2)  % Average over tapers
```

**2. Compute Metrics for Full Dataset (N ≈ 235):**
```matlab
coherence_full = |mean(S12_full, 2)| / sqrt(mean(S11_full, 2) .* mean(S22_full, 2))
wpli_full = |mean(imag(S12_full), 2)| / mean(|imag(S12_full)|, 2)
ppc_full = (|sum(phase_vectors)|² - N) / (N*(N-1))
```

**3. Randomly Select 1/3 of Trials:**
```matlab
rng(42);  % Reproducible seed
N_reduced = round(N_full / 3);
selected_trials = randperm(N_full, N_reduced);
```

**4. Compute Metrics for Reduced Dataset (N ≈ 78):**
```matlab
S12_reduced = S12_full(:, selected_trials);
% Recompute all three metrics with reduced trials
```

**5. Compute Bias:**
```matlab
coherence_bias = coherence_reduced - coherence_full
wpli_bias = wpli_reduced - wpli_full
ppc_bias = ppc_reduced - ppc_full
```

### Expected Results

**Coherence Bias:**
- **Positive bias** (reduced > full)
- Magnitude: typically +0.01 to +0.05
- Frequency-dependent (higher at peaks)

**WPLI Bias:**
- **Positive bias** (reduced > full)
- Magnitude: typically +0.01 to +0.03
- Less than coherence bias

**PPC Bias:**
- **Near zero** (±0.001 or less)
- Fluctuates around zero line
- Demonstrates unbiased property

## Code Structure

```
Question4_Complete_Code_FIXED.m
│
├── SETUP AND DATA LOADING
│   └── Load M1_ep_v8.mat
│
├── FIND TARGET ELECTRODES
│   └── Locate PO3 and AF4
│
├── EXTRACT STIMULUS PERIOD DATA
│   └── All 235 trials, [0.25, 0.75]s
│
├── MULTI-TAPER PARAMETERS
│   └── TW=2, K=3, shared for both analyses
│
├── ANALYSIS 1: ALL TRIALS (N = 235)
│   ├── Compute multi-taper spectra
│   ├── Compute S12, S11, S22
│   └── Compute all three metrics
│
├── QUESTION 4(a): REDUCED TRIALS (1/3)
│   ├── Randomly select ~78 trials
│   ├── Extract reduced spectra
│   ├── Compute all three metrics
│   └── Calculate bias (reduced - full)
│
├── CREATE PLOTS
│   ├── 6-panel comprehensive comparison
│   ├── Individual metric comparisons (3)
│   └── 3-panel bias plots
│
├── SAVE RESULTS
│   └── Q4_results.mat
│
├── QUESTION 4(b): MATHEMATICAL DERIVATION
│   └── Print step-by-step proof to console
│
└── LOCAL HELPER FUNCTIONS
    └── findElectrodeIndex()
```

## Troubleshooting

### Directory and File Issues

1. **"Unable to open file 'M1_ep_v8.mat'"**
   ```matlab
   % Check if file exists
   ls M1_ep_v8.mat
   
   % Check current directory
   pwd
   
   % Navigate to correct location
   cd('/path/to/data/directory/');
   ```

2. **"Electrode 'PO3' not found!" or "Electrode 'AF4' not found!"**
   ```matlab
   % Check available electrodes
   load('M1_ep_v8.mat');
   disp(data.label);
   
   % Verify PO3 and AF4 are present
   ```

### Common Issues

1. **"Chronux toolbox not found" (Main code)**
   ```matlab
   addpath(genpath('/path/to/chronux/'));
   savepath;  % Save for future sessions
   ```

2. **"Undefined function 'mtfftc'" (Main code)**
   - Chronux not in path
   - Solution: Add Chronux to path (see above)

3. **Appendix code doesn't need Chronux**
   - Uses MATLAB's built-in `fft` function
   - No external dependencies

4. **"Index exceeds array bounds" when selecting trials**
   - Check that N_full > 3 (need at least 3 trials)
   - Verify data loaded correctly

5. **Very large bias values (>0.1)**
   - May indicate data quality issues
   - Check that trials are valid
   - Verify electrode signals are not all zeros

6. **PPC bias not near zero**
   - Small deviations (±0.005) are normal
   - Large bias (>0.01) may indicate implementation error
   - Verify phase vector normalization: `S12 ./ abs(S12)`

### Random Seed Reproducibility

The script uses `rng(42)` for reproducible trial selection:
```matlab
% Always get same random trial selection
rng(42);
selected_trials = randperm(N_full, N_reduced);
```

To change the selection:
```matlab
rng(12345);  % Different seed → different trials
```

### Data Verification

```matlab
% Verify M1 data structure
load('M1_ep_v8.mat', 'data');

fprintf('Sampling rate: %d Hz\n', data.fsample);
fprintf('Number of trials: %d\n', data.numTrials);
fprintf('Number of electrodes: %d\n', length(data.label));

% Check if we have enough trials
N_full = data.numTrials;
N_reduced = round(N_full / 3);

fprintf('Full trials: %d\n', N_full);
fprintf('Reduced trials (1/3): %d\n', N_reduced);

if N_reduced < 10
    warning('Very few trials in reduced set. Results may be unreliable.');
end

% Verify stimulus window
stimIdx = find(data.timeVals >= 0.25 & data.timeVals <= 0.75);
fprintf('Stimulus window samples: %d\n', length(stimIdx));

if length(stimIdx) < 100
    error('Stimulus window too short!');
end
```

## Interpretation Guide

### Understanding Bias Results

**Positive Bias Interpretation:**
```
Bias = Metric_reduced - Metric_full

Bias > 0  →  Fewer trials overestimate connectivity (PROBLEM)
Bias = 0  →  Unbiased estimator (IDEAL)
Bias < 0  →  Rare, may indicate implementation error
```

**Expected Magnitudes:**

| Metric | Typical Bias | Interpretation |
|--------|-------------|----------------|
| **Coherence** | +0.02 to +0.05 | Moderate positive bias |
| **WPLI** | +0.01 to +0.03 | Small positive bias |
| **PPC** | ±0.001 to ±0.005 | Near zero (unbiased) |

### Why This Matters

**Clinical/Research Implications:**
- Studies with different trial counts aren't directly comparable
- Coherence/WPLI higher in small-N studies (artifactually)
- PPC enables fair comparison across studies
- Critical for meta-analyses and cross-study comparisons

**Practical Guidelines:**
- **Use PPC** when trial count varies across conditions
- **Use Coherence** for well-controlled, equal-N designs
- **Report trial counts** always (critical for interpretation)
- **Bootstrap** to estimate bias in specific datasets

### Frequency-Dependent Effects

**Bias typically varies with frequency:**
- **Higher bias** at connectivity peaks (where signal is strong)
- **Lower bias** in noise floor (where connectivity is weak)
- **PPC unbiased** across all frequencies

### Mathematical Intuition

**Why Coherence is Biased:**
```
Naive: E[|mean(S12)|] ≠ |E[mean(S12)]|  (Jensen's inequality)
Result: Positive bias proportional to 1/N
```

**Why PPC is Unbiased:**
```
Key: Remove diagonal terms (self-products)
PPC = (off-diagonal sum) / (N*(N-1))
Result: E[PPC] = PLV² exactly
```

## Appendix Code Differences

### Key Changes from Main Code

The `Question4_StandardFFT_Code.m` script is an alternative implementation using **standard FFT** instead of multi-taper method. This demonstrates that the bias findings are **robust across spectral methods**.

**Primary Differences:**

| Aspect | Main Code | Appendix Code |
|--------|-----------|---------------|
| **Spectral Method** | Multi-taper (Chronux) | Standard FFT (MATLAB) |
| **Function Used** | `mtfftc()` | `fft()` |
| **Tapers** | 3 tapers (TW=2, K=3) | No tapers (single FFT) |
| **Frequency Smoothing** | ±4 Hz (W=4) | No smoothing |
| **Plot Count** | 5 plots (10 files) | 1 plot (2 files) |
| **Output Directory** | `Question_4_Plots/` | `Question_4_Plots_FFT/` |
| **Dependencies** | Requires Chronux | Only MATLAB built-in |
| **Computation Time** | ~10-15 seconds | ~5-8 seconds |

**Code Changes:**

1. **Spectral Computation:**
   ```matlab
   % Appendix: Standard FFT
   FFT_PO3 = fft(dataPO3, nfft);
   FFT_AF4 = fft(dataAF4, nfft);
   S12 = conj(FFT_PO3) .* FFT_AF4;
   
   % Main: Multi-taper FFT
   J_PO3 = mtfftc(dataPO3, tapers, nfft, Fs);
   J_AF4 = mtfftc(dataAF4, tapers, nfft, Fs);
   S12 = mean(conj(J_PO3) .* J_AF4, 2);  % Average over tapers
   ```

2. **Plotting:**
   - Appendix: Single 6-panel comprehensive figure
   - Main: 5 separate plots for detailed analysis

3. **No Mathematical Derivation:**
   - Appendix code focuses on empirical results only
   - Main code includes Q4(b) derivation output

**When to Use Each:**

**Use Main Code (Multi-Taper):**
- For final results and submission
- For publication-quality analysis
- When spectral smoothing is desired
- Standard in neuroscience literature

**Use Appendix Code (Standard FFT):**
- To verify findings across methods
- When Chronux is not available
- For faster computation
- To demonstrate robustness

**Expected Consistency:**
- Bias patterns should be **consistent** across both methods
- Coherence and WPLI: positive bias in both
- PPC: near-zero bias in both
- Absolute values may differ (smoothing effect)
- **Key finding unchanged:** PPC is unbiased

## Key Citations

### Bias and PPC
1. **Vinck et al. (2010)** "The pairwise phase consistency: A bias-free measure of rhythmic neuronal synchronization" *NeuroImage* 51:112-122
   - Original PPC derivation
   - Mathematical proof of unbiased property

2. **Vinck et al. (2011)** "An improved index of phase-synchronization for electrophysiological data" *NeuroImage* 55:1548-1565
   - WPLI and its bias properties
   - Comparison of connectivity metrics

3. **Aydore et al. (2013)** "A note on the phase locking value and its properties" *NeuroImage* 74:231-244
   - Detailed analysis of PLV bias
   - Sample size effects

### Spectral Methods
1. **Multi-taper:** Thomson (1982) "Spectrum estimation and harmonic analysis" *IEEE Proceedings* 70:1055-1096
2. **Chronux:** Mitra & Bokil (2008) "Observed Brain Dynamics" Oxford University Press

## Mathematical Summary

### PPC Unbiased Proof (Simplified)

**Step 1:** Naive PLV² estimator
```
PLV²_naive = |(1/N) Σ exp(i*θⱼ)|²
```

**Step 2:** Expand
```
= (1/N²)[Σⱼ Σₖ exp(i*θⱼ) exp(-i*θₖ)]
= (1/N²)[N + Σⱼ≠ₖ exp(i*(θⱼ-θₖ))]
```

**Step 3:** Take expectation
```
E[PLV²_naive] = (1/N) + ((N-1)/N)·PLV²
                = PLV² + (1/N)(1 - PLV²)  ← BIAS!
```

**Step 4:** Remove bias → PPC
```
PPC = (|Σ exp(i*θⱼ)|² - N) / (N*(N-1))
    = (off-diagonal terms only) / (number of pairs)

E[PPC] = PLV²  ← UNBIASED!
```

## Version History

- **v1.0** (2026-04-13): Initial implementation
  - Multi-taper bias analysis (main code)
  - Standard FFT alternative (appendix code)
  - Empirical demonstration of bias (Q4a)
  - Mathematical derivation (Q4b)
  - Comprehensive plotting and documentation

## License

Academic use only. Part of NSP2026 coursework submission.

## Contact

For questions about this analysis:
- Author: Kirubananth S
- Course: NSP2026 - Neural Signal Processing
- Assignment: Assignment 2, Question 4
- Institution: IISc Bangalore

## Related Files

- **Question 3:** Computes connectivity metrics (provides baseline for Q4)
- **Q3_results.mat:** Could be used as input (alternative to recomputing)
