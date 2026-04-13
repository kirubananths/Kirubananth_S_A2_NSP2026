# Question 3: EEG Connectivity Metrics from Spectra

## Overview

This MATLAB script computes three connectivity metrics (Coherence, WPLI, and PPC) directly from cross-spectra and auto-spectra **WITHOUT using FieldTrip's connectivity functions**. All formulas match the lecture slides exactly.

**Author:** Kirubananth S  
**Main File:** `Question3Codeforsubmission.m`  
**Appendix File:** `Question3_StandardFFT_Code_FIXED.m`  
**Related:** NSP2026 Assignment 2 (Neural Signal Processing), EEG Module

## Key Features

### Main Analysis (Multi-Taper Method)
- **Electrode pair:** PO3 and AF4
- **Data:** Subject 013AR, protocol M1, unipolar reference
- **Time window:** Stimulus period [0.25, 0.75] seconds
- **Spectral method:** Multi-taper (Chronux) with TW=2, K=3 tapers
- **Frequency smoothing:** ±4 Hz (reduces spectral variance)

### Three Connectivity Metrics Computed

**Question 3(a): Coherence**
- Formula: `C = |E[S₁₂]| / sqrt(E[S₁₁] * E[S₂₂])`
- Measures magnitude of phase consistency
- Range: [0, 1]
- Biased by trial count (higher coherence with more trials)

**Question 3(b): WPLI (Weighted Phase Lag Index)**
- Formula (Slide 78): `WPLI = |E{imag(S₁₂)}| / E{|imag(S₁₂)|}`
- Reduces volume conduction artifacts
- Uses only imaginary part of cross-spectrum
- Range: [0, 1]

**Question 3(c): PPC (Pairwise Phase Consistency)**
- Formula (Slide 82): `PPC = (|Σ exp(i*θⱼ)|² - N) / (N*(N-1))`
- Phase-only metric (unit vectors)
- Unbiased estimator of squared PLV
- Range: [0, 1]

## Requirements

### MATLAB Version
- MATLAB R2016b or later (tested with R2023b)

### Toolboxes
1. **Chronux Toolbox** (required for main code only)
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
├── Question3Codeforsubmission.m       # Main analysis (multi-taper)
├── Question3_StandardFFT_Code_FIXED.m # Appendix (standard FFT)
├── M1_ep_v8.mat                       # REQUIRED: M1 protocol data
└── chronux/                           # Or in MATLAB path (main code only)
    ├── spectral_analysis/
    └── ...
```

### Essential Files in Same Directory

**1. Question3Codeforsubmission.m** (main script)
   - Primary analysis using multi-taper method
   - Submit this code and its results

**2. Question3_StandardFFT_Code_FIXED.m** (appendix)
   - Alternative implementation using standard FFT
   - For comparison purposes only
   - Demonstrates effect of spectral estimation method

**3. M1_ep_v8.mat** (REQUIRED)
   - M1 protocol EEG data, unipolar reference
   - Subject: 013AR
   - Must be in the **same directory** as scripts

### Files Created During Execution

**Main Code Output:**
```
your_working_directory/
├── Question3Codeforsubmission.m
├── M1_ep_v8.mat
└── Question 3 Plots/                  # Created automatically
    ├── Q3_all_metrics_comparison.png  # All 3 metrics together
    ├── Q3_all_metrics_comparison.fig
    ├── Q3a_Coherence.png              # Individual metric plots
    ├── Q3a_Coherence.fig
    ├── Q3b_WPLI.png
    ├── Q3b_WPLI.fig
    ├── Q3c_PPC.png
    ├── Q3c_PPC.fig
    └── Q3_results.mat                 # All results saved
```

**Appendix Code Output:**
```
Question_3_Plots/                       # Different directory name
├── Q3_all_metrics_comparison.png
├── Q3_all_metrics_comparison.fig
├── Q3a_Coherence.png
├── ... (same structure as main code)
└── Q3_results.mat
```

### Pre-Execution Checklist

Before running the scripts:

**Main Code:**
- [ ] `Question3Codeforsubmission.m` is in current directory
- [ ] `M1_ep_v8.mat` is in the **same directory**
- [ ] Chronux toolbox is in MATLAB path
- [ ] You have write permissions

**Appendix Code:**
- [ ] `Question3_StandardFFT_Code_FIXED.m` is in current directory
- [ ] `M1_ep_v8.mat` is in the **same directory**
- [ ] Chronux is NOT required (standard FFT only)
- [ ] You have write permissions

### Quick Setup Commands

```matlab
% Navigate to working directory
cd('/path/to/your/working/directory');

% Verify main script and data
assert(exist('Question3Codeforsubmission.m', 'file') == 2, 'Main script not found!');
assert(exist('M1_ep_v8.mat', 'file') == 2, 'M1 data file not found!');

% Add Chronux for main code
if ~exist('mtfftc', 'file')
    addpath(genpath('/path/to/chronux/'));
end

% Verify Chronux (main code only)
assert(exist('mtfftc', 'file') == 2, 'Chronux not found!');
assert(exist('dpss', 'file') == 2, 'DPSS function not found!');

fprintf('Setup complete! Ready to run Question3Codeforsubmission.m\n');

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
data.numTrials     % Number of trials
data.trial         % Cell array: 64 electrodes × time points per trial
```

### Expected Data Specifications
- **Protocol:** M1
- **Subject:** 013AR
- **Reference:** Unipolar
- **Sampling rate:** 1000 Hz
- **Number of electrodes:** 64 (must include PO3 and AF4)
- **Number of trials:** Typically 87
- **Time range:** Must include [0.25, 0.75] seconds

## Output

### Main Code Output Structure
```
Question 3 Plots/
├── Q3_all_metrics_comparison.png      # Unified plot (all 3 metrics)
├── Q3_all_metrics_comparison.fig
├── Q3a_Coherence.png                  # Individual plots
├── Q3a_Coherence.fig
├── Q3b_WPLI.png
├── Q3b_WPLI.fig
├── Q3c_PPC.png
├── Q3c_PPC.fig
└── Q3_results.mat                     # MATLAB workspace with all results
```

**Total output:** 4 plots (8 files: .png and .fig for each)

### Results MAT File Contents

The `Q3_results.mat` file contains:

```matlab
results.frequency      % Frequency vector (Hz)
results.coherence      % Coherence values
results.wpli          % WPLI values
results.ppc           % PPC values
results.S12           % Cross-spectrum (freq × trials)
results.S11           % PO3 auto-spectrum (freq × trials)
results.S22           % AF4 auto-spectrum (freq × trials)
results.numTrials     % Number of trials
results.electrodes    % {'PO3', 'AF4'}
results.parameters    % Chronux parameters (main code)
```

### Plot Elements

**Unified Comparison Plot:**
- All three metrics on same axes
- Blue solid line: Coherence
- Red dashed line: WPLI
- Green dash-dot line: PPC
- Legend with mean and range statistics
- Info box: trial count, frequency range, electrode pair

**Individual Plots:**
- Single metric per plot
- Optimized y-axis scaling
- Grid for readability
- Frequency range: 0-50 Hz

## Usage

### Running the Main Code

```matlab
% Navigate to directory
cd('/path/to/your/working/directory');

% Run main analysis (multi-taper)
Question3Codeforsubmission
```

### Running the Appendix Code

```matlab
% Navigate to directory
cd('/path/to/your/working/directory');

% Run appendix analysis (standard FFT)
Question3_StandardFFT_Code_FIXED
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
assert(exist('Question3Codeforsubmission.m', 'file') == 2, 'Main script not found!');
assert(exist('M1_ep_v8.mat', 'file') == 2, 'Data file not found!');

% Verify Chronux
assert(exist('mtfftc', 'file') == 2, 'Chronux not found!');

fprintf('Running main analysis (multi-taper)...\n\n');

% Run main analysis
Question3Codeforsubmission

fprintf('\n\nMain analysis complete!\n');

% Optional: Run appendix code
fprintf('\nRunning appendix analysis (standard FFT)...\n\n');
Question3_StandardFFT_Code_FIXED

fprintf('\n\nBoth analyses complete!\n');
```

### Expected Runtime
- **Main code:** ~5-10 seconds
- **Appendix code:** ~3-5 seconds (faster, no multi-taper)
- Both codes run quickly (simple spectral computations)

## Algorithm Details

### Main Code: Multi-Taper Spectral Analysis

**Parameters:**
```matlab
TW = 2              % Time-bandwidth product
K = 3               % Number of tapers (2*TW - 1 = 3)
W = 4 Hz            % Frequency smoothing: ±4 Hz
Frequency range: 0-50 Hz
Data length: ~500 samples (0.5s at 1000 Hz)
```

**Multi-Taper Method:**
1. Generate DPSS tapers (discrete prolate spheroidal sequences)
2. Apply each taper to data
3. Compute FFT for each tapered signal
4. Average across tapers to reduce variance

**Cross-Spectrum Computation:**
```matlab
J_PO3 = mtfftc(dataPO3, tapers, nfft, Fs)  % freq × tapers × trials
J_AF4 = mtfftc(dataAF4, tapers, nfft, Fs)

S12 = mean(conj(J_PO3) .* J_AF4, 2)  % Average over tapers
S11 = mean(conj(J_PO3) .* J_PO3, 2)  % PO3 power
S22 = mean(conj(J_AF4) .* J_AF4, 2)  % AF4 power
```

### Connectivity Metric Formulas

**Coherence (Q3a):**
```
C(f) = |E[S₁₂(f)]| / sqrt(E[S₁₁(f)] * E[S₂₂(f)])

where E[] = mean over trials
```

**WPLI (Q3b) - Lecture Slide 78:**
```
WPLI(f) = |E{imag(S₁₂(f))}| / E{|imag(S₁₂(f))|}

Numerator: |mean(imag(S12))|
Denominator: mean(|imag(S12)|)
```

**PPC (Q3c) - Lecture Slide 82 (Phase-Only):**
```
θⱼ = angle(S₁₂(f,j))  [phase of cross-spectrum, trial j]
phase_vectors = exp(i*θⱼ)  [unit vectors]

PPC(f) = (|Σⱼ exp(i*θⱼ)|² - N) / (N*(N-1))

This is the unbiased estimator of PLV²
```

## Code Structure

### Main Code
```
Question3Codeforsubmission.m
│
├── SETUP AND DATA LOADING
│   └── Load M1_ep_v8.mat
│
├── FIND TARGET ELECTRODES
│   └── Locate PO3 and AF4
│
├── EXTRACT STIMULUS PERIOD DATA
│   └── Time window: [0.25, 0.75] seconds
│
├── COMPUTE CROSS AND AUTO SPECTRA (MULTI-TAPER)
│   ├── Generate DPSS tapers
│   ├── Compute multi-taper FFT
│   └── Average over tapers
│
├── COMPUTE CROSS-SPECTRUM AND AUTO-SPECTRA
│   └── S12, S11, S22
│
├── QUESTION 3(a): COHERENCE
│   └── Standard coherence formula
│
├── QUESTION 3(b): WPLI
│   └── Weighted Phase Lag Index (Slide 78)
│
├── QUESTION 3(c): PPC
│   └── Pairwise Phase Consistency (Slide 82, phase-only)
│
├── PLOT ALL METRICS
│   ├── Unified comparison plot
│   └── Individual plots
│
├── SAVE RESULTS
│   └── Q3_results.mat
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

3. **"Output directory creation failed"**
   - Check write permissions
   - Try running MATLAB as administrator (Windows)

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

4. **Very different results between main and appendix code**
   - Expected! Different spectral methods produce different results
   - Multi-taper: smoother, lower variance
   - Standard FFT: higher resolution, higher variance

5. **NaN or Inf values in metrics**
   - Check for zero denominators
   - Verify data quality (no all-zero trials)
   - Check electrode connectivity

### Data Verification

```matlab
% Verify M1 data structure
load('M1_ep_v8.mat', 'data');

fprintf('Sampling rate: %d Hz\n', data.fsample);
fprintf('Number of trials: %d\n', data.numTrials);
fprintf('Number of electrodes: %d\n', length(data.label));
fprintf('Time range: %.2f to %.2f s\n', data.timeVals(1), data.timeVals(end));

% Check if stimulus window is present
stimIdx = find(data.timeVals >= 0.25 & data.timeVals <= 0.75);
fprintf('Stimulus window samples: %d\n', length(stimIdx));

if length(stimIdx) == 0
    error('Stimulus window [0.25, 0.75]s not found in data!');
end

% Verify electrodes exist
po3_exists = any(strcmp(data.label, 'PO3'));
af4_exists = any(strcmp(data.label, 'AF4'));

fprintf('PO3 found: %d\n', po3_exists);
fprintf('AF4 found: %d\n', af4_exists);

if ~po3_exists || ~af4_exists
    error('Required electrodes (PO3 or AF4) not found!');
end
```

## Interpretation Guide

### Expected Patterns

**Coherence:**
- Typically shows peaks at specific frequencies
- Higher values indicate stronger phase locking
- Sensitive to trial count (bias increases with more trials)
- Range: 0 (no coherence) to 1 (perfect coherence)

**WPLI:**
- Generally lower than coherence
- Less sensitive to volume conduction
- Uses only imaginary part of cross-spectrum
- Zero-lag connections → WPLI ≈ 0
- Strong phase lag → higher WPLI

**PPC:**
- Unbiased estimator of squared PLV
- Corrects for trial count bias
- Generally similar pattern to coherence but lower values
- More conservative measure of phase consistency

### Comparing Metrics

**Coherence vs WPLI:**
- Coherence usually higher than WPLI
- Large difference suggests volume conduction artifacts
- WPLI removes zero-lag synchrony

**Coherence vs PPC:**
- PPC is unbiased version of squared coherence
- PPC ≈ Coherence² (approximately, when bias-corrected)
- PPC removes amplitude effects (phase-only)

### Frequency Bands of Interest

**Delta (0-4 Hz):** Low frequency synchrony  
**Theta (4-8 Hz):** Memory, navigation  
**Alpha (8-12 Hz):** Resting state, attention  
**Beta (12-30 Hz):** Motor control, cognition  
**Gamma (30-50 Hz):** Local processing, binding  

### Multi-Taper vs Standard FFT

**Multi-Taper (Main Code):**
- ✓ Smoother spectra (±4 Hz smoothing)
- ✓ Lower spectral variance
- ✓ More reliable estimates
- ✗ Lower frequency resolution
- ✗ Computationally more expensive

**Standard FFT (Appendix):**
- ✓ Higher frequency resolution
- ✓ Faster computation
- ✓ Simpler implementation
- ✗ Higher spectral variance
- ✗ Noisier estimates

## Appendix Code Differences

### Key Changes from Main Code

The `Question3_StandardFFT_Code_FIXED.m` script is an alternative implementation that uses **standard FFT** instead of multi-taper method. This is provided for comparison and to demonstrate the effect of spectral estimation method on connectivity metrics.

**Primary Differences:**

| Aspect | Main Code | Appendix Code |
|--------|-----------|---------------|
| **Spectral Method** | Multi-taper (Chronux) | Standard FFT (MATLAB) |
| **Function Used** | `mtfftc()` | `fft()` |
| **Tapers** | 3 tapers (TW=2, K=3) | No tapers (single FFT) |
| **Frequency Smoothing** | ±4 Hz (W=4) | No smoothing |
| **Spectral Variance** | Lower (averaged over tapers) | Higher (single estimate) |
| **Frequency Resolution** | Lower (~1.95 Hz) | Higher (~1.95 Hz) |
| **Dependencies** | Requires Chronux | Only MATLAB built-in |
| **Output Directory** | `Question 3 Plots/` | `Question_3_Plots/` |
| **Computation Time** | ~5-10 seconds | ~3-5 seconds |

**Code Changes:**

1. **Spectral Computation (Lines 92-136 in appendix):**
   ```matlab
   % Appendix: Standard FFT
   FFT_PO3 = fft(dataPO3, nfft);
   FFT_AF4 = fft(dataAF4, nfft);
   
   % Main: Multi-taper FFT
   J_PO3 = mtfftc(dataPO3, tapers, nfft, Fs);
   J_AF4 = mtfftc(dataAF4, tapers, nfft, Fs);
   ```

2. **Cross-Spectrum (Lines 148-151 in appendix):**
   ```matlab
   % Appendix: Direct FFT cross-product
   S12 = conj(FFT_PO3) .* FFT_AF4;
   
   % Main: Average over tapers first
   S12 = mean(conj(J_PO3) .* J_AF4, 2);
   ```

3. **No Taper Parameters:**
   - Appendix code doesn't use `params.tapers`, `TW`, or `K`
   - No DPSS taper generation

4. **Additional Metadata:**
   - Appendix saves `results.method = 'Standard FFT'`
   - Plot titles include "Standard FFT"

**When to Use Each:**

**Use Main Code (Multi-Taper):**
- For final results and submission
- When spectral smoothing is desired
- For more robust estimates
- Standard in neuroscience literature

**Use Appendix Code (Standard FFT):**
- For comparison purposes
- When Chronux is not available
- For faster prototyping
- To understand effect of spectral method

**Expected Differences in Results:**
- Standard FFT will show **noisier** spectra
- Coherence values may be **higher** with standard FFT (less smoothing)
- WPLI and PPC patterns similar but with more fluctuations
- Main trends should be consistent across both methods

## Key Citations

### Connectivity Metrics
1. **Coherence:** Bendat & Piersol (2010) "Random Data: Analysis and Measurement Procedures"
2. **WPLI:** Vinck et al. (2011) "An improved index of phase-synchronization for electrophysiological data in the presence of volume-conduction, noise and sample-size bias" *NeuroImage* 55:1548-1565
3. **PPC:** Vinck et al. (2010) "The pairwise phase consistency: A bias-free measure of rhythmic neuronal synchronization" *NeuroImage* 51:112-122

### Spectral Methods
1. **Multi-taper:** Thomson (1982) "Spectrum estimation and harmonic analysis" *IEEE Proceedings* 70:1055-1096
2. **Chronux:** Mitra & Bokil (2008) "Observed Brain Dynamics" Oxford University Press

### Lecture References
- **Slide 78:** WPLI formula
- **Slide 82:** PPC formula (phase-only, unbiased estimator)

## Formulas Summary

All formulas implemented exactly as shown in lecture slides:

**Coherence:**
```
C(f) = |E[S₁₂(f)]| / sqrt(E[S₁₁(f)] * E[S₂₂(f)])
```

**WPLI (Slide 78):**
```
WPLI(f) = |E{imag(S₁₂(f))}| / E{|imag(S₁₂(f))|}
```

**PPC (Slide 82, Phase-Only):**
```
PPC(f) = (|Σⱼ₌₁ᴺ exp(i*θⱼ(f))|² - N) / (N*(N-1))
where θⱼ(f) = angle(S₁₂(f,j))
```

## Version History

- **v1.0** (2026-04-13): Initial implementation
  - Multi-taper spectral analysis (main code)
  - Standard FFT alternative (appendix code)
  - All three connectivity metrics
  - Formulas match lecture slides exactly
  - Comprehensive plotting and results saving

## License

Academic use only. Part of NSP2026 coursework submission.

## Contact

For questions about this analysis:
- Author: Kirubananth S
- Course: NSP2026 - Neural Signal Processing
- Assignment: Assignment 2, Question 3
- Institution: IISc Bangalore

## Related Files

- **Question 1:** Phase coherence analysis (rose plots)
- **Question 2:** Average re-referencing effects
- **Question 4:** Uses Q3_results.mat for further analysis
