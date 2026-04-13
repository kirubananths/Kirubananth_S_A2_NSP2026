# Question 2: EEG Average Re-referencing Analysis

## Overview

This MATLAB script analyzes the effects of average re-referencing on EEG phase coherence by comparing unipolar-referenced and average-referenced data. The analysis is based on the methods described in **Shirhatti et al., 2016, Neural Computation**.

**Author:** Kirubananth S  
**File:** `Question2_Complete.m`  
**Related:** NSP2026 Assignment 2 (Neural Signal Processing), EEG Module

## Scientific Background

### Average Referencing
Average referencing is a common preprocessing technique in EEG analysis where each electrode's signal is re-referenced to the average of all electrodes:

```
V_avg(i) = V_unipolar(i) - (1/N) * Σ V_unipolar(j)
```

### Key Predictions (Shirhatti et al., 2016)
1. **Phase shift:** Average referencing shifts mean phase difference from ~0° toward ~180°
2. **Reduced coherence:** Mean Resultant Length (MRL) decreases with average referencing
3. **Circular distribution:** Phase distributions become more uniform (less coherent)
4. **Frequency dependency:** Effect is stronger at low frequencies where coherence is naturally high

## Features

The script performs three comparative analyses:

### Question 2(a): Specific Electrode Pair Comparison
- Compares phase differences for three electrode pairs:
  - Oz - P4
  - Oz - C3
  - Oz - AF4
- Analysis frequency: 30 Hz
- Creates side-by-side comparison plots (unipolar vs average reference)

### Question 2(b): Angular Distance Group Comparison
- Groups electrodes by angular distance from Oz (6 groups: 0-30°, 30-60°, ..., 150-180°)
- Pools phase differences across all electrodes in each group
- Analysis frequency: 30 Hz
- Compares unipolar vs average reference for each group

### Question 2(c): Multi-Seed Frequency Pooling Comparison
- Uses 4 seed electrodes: Oz, POz, O1, O2
- Triple pooling: seeds × group electrodes × frequency range
- **Frequency range: 20-32 Hz** (beta/gamma transition)
- Compares unipolar vs average reference with extensive pooling

## Requirements

### MATLAB Version
- MATLAB R2016b or later (tested with R2023b)

### Toolboxes
1. **Chronux Toolbox** (required)
   - Download from: http://chronux.org/
   - Functions used:
     - `mtfftc` - Multi-taper FFT
     - `dpss` - Discrete prolate spheroidal sequences

2. **MATLAB Signal Processing Toolbox** (standard)

### Custom Functions
The script requires the following custom function in MATLAB path:
- `getElectrodeGroupsConn.m` - Groups electrodes by angular distance

## Directory Setup

### Required Directory Structure

For the script to run flawlessly:

```
your_working_directory/
├── Question2_Complete.m            # Main analysis script
├── EO1_ep_v8.mat                   # REQUIRED: Unipolar-referenced data
├── EO1_ep_v8_Avgref.mat            # REQUIRED: Average-referenced data
├── getElectrodeGroupsConn.m        # REQUIRED: Custom function
└── chronux/                        # Or in MATLAB path
    ├── spectral_analysis/
    └── ...
```

### Essential Files in Same Directory

**1. Question2_Complete.m** (this script)
   - The main analysis script

**2. EO1_ep_v8.mat** (REQUIRED)
   - **Unipolar-referenced** EEG data file
   - Contains `data` structure with unipolar reference
   - Must be in the **same directory** as the script

**3. EO1_ep_v8_Avgref.mat** (REQUIRED)
   - **Average-referenced** EEG data file
   - Contains `data` structure with average reference
   - Must be in the **same directory** as the script
   - **CRITICAL:** Must have same trials and sampling rate as unipolar file

**4. getElectrodeGroupsConn.m** (REQUIRED)
   - Custom function for electrode grouping
   - Same function used in Question 1
   - Must be in same directory OR in MATLAB path

### Files Created During Execution

```
your_working_directory/
├── Question2_Complete.m
├── EO1_ep_v8.mat
├── EO1_ep_v8_Avgref.mat
├── getElectrodeGroupsConn.m
├── temp_chanlocs.mat              # Created temporarily, auto-deleted
└── Question 2 Plots/              # Created automatically
    ├── Q2a_Oz_P4_30Hz_comparison.png
    ├── Q2a_Oz_P4_30Hz_comparison.fig
    ├── Q2a_Oz_C3_30Hz_comparison.png
    ├── Q2a_Oz_C3_30Hz_comparison.fig
    ├── Q2a_Oz_AF4_30Hz_comparison.png
    ├── Q2a_Oz_AF4_30Hz_comparison.fig
    ├── Q2b_Group1_comparison.png    # 6 group comparisons
    ├── Q2b_Group1_comparison.fig
    ├── ...
    ├── Q2c_Group1_comparison.png    # 6 multi-seed comparisons
    ├── Q2c_Group1_comparison.fig
    └── ...
```

### Pre-Execution Checklist

Before running the script, verify:

- [ ] `Question2_Complete.m` is in your current MATLAB directory
- [ ] `EO1_ep_v8.mat` (unipolar) is in the **same directory**
- [ ] `EO1_ep_v8_Avgref.mat` (average ref) is in the **same directory**
- [ ] Both data files have matching trials and sampling rates
- [ ] `getElectrodeGroupsConn.m` is accessible
- [ ] Chronux toolbox is in MATLAB path
- [ ] You have write permissions for creating output directory

### Quick Setup Commands

```matlab
% Navigate to your working directory
cd('/path/to/your/working/directory');

% Verify required files exist
assert(exist('Question2_Complete.m', 'file') == 2, 'Script not found!');
assert(exist('EO1_ep_v8.mat', 'file') == 2, 'Unipolar data not found!');
assert(exist('EO1_ep_v8_Avgref.mat', 'file') == 2, 'Average-ref data not found!');
assert(exist('getElectrodeGroupsConn.m', 'file') == 2, 'Custom function not found!');

% Add Chronux if needed
if ~exist('mtfftc', 'file')
    addpath(genpath('/path/to/chronux/'));
end

% Verify Chronux is loaded
assert(exist('mtfftc', 'file') == 2, 'Chronux not found!');
assert(exist('dpss', 'file') == 2, 'DPSS function not found!');

% Verify data compatibility (optional but recommended)
load('EO1_ep_v8.mat', 'data');
fs_uni = data.fsample;
trials_uni = data.numTrials;

load('EO1_ep_v8_Avgref.mat', 'data');
fs_avg = data.fsample;
trials_avg = data.numTrials;

assert(fs_uni == fs_avg, 'Sampling frequencies do not match!');
assert(trials_uni == trials_avg, 'Number of trials do not match!');

fprintf('Setup complete! Both data files compatible.\n');
fprintf('Ready to run Question2_Complete.m\n');
```

## Input Data

### Required Files

**File 1: EO1_ep_v8.mat (Unipolar Reference)**

Structure with fields:
```matlab
data.fsample       % Sampling frequency (Hz)
data.timeVals      % Time vector
data.label         % Cell array of electrode labels
data.numTrials     % Number of trials
data.trial         % Cell array: 64 electrodes × 2500 time points per trial
data.elec.chanpos  % Electrode positions (64 × 3)
data.elec.label    % Electrode labels
```

**File 2: EO1_ep_v8_Avgref.mat (Average Reference)**

Must contain identical `data` structure with:
- Same field names
- **Same number of trials** (87)
- **Same sampling frequency** (1000 Hz)
- Same electrode labels and positions
- Different signal values (average-referenced)

### Data Specifications
- **Sampling rate:** 1000 Hz
- **Number of electrodes:** 64
- **Number of trials:** 87
- **Time range:** -1.5 to 1.0 seconds
- **Reference scheme:** Unipolar vs Average

## Output

### Directory Structure After Execution
```
Question 2 Plots/
├── Q2a_Oz_P4_30Hz_comparison.png      # Q2(a): 3 electrode pair comparisons
├── Q2a_Oz_P4_30Hz_comparison.fig
├── Q2a_Oz_C3_30Hz_comparison.png
├── Q2a_Oz_C3_30Hz_comparison.fig
├── Q2a_Oz_AF4_30Hz_comparison.png
├── Q2a_Oz_AF4_30Hz_comparison.fig
├── Q2b_Group1_comparison.png          # Q2(b): 6 group comparisons
├── Q2b_Group1_comparison.fig
├── Q2b_Group2_comparison.png
├── ...
├── Q2b_Group6_comparison.fig
├── Q2c_Group1_comparison.png          # Q2(c): 6 multi-seed comparisons
├── Q2c_Group1_comparison.fig
├── ...
└── Q2c_Group6_comparison.fig
```

**Total output:** 15 comparison plots (30 files: .png and .fig for each)

### Comparison Plot Elements

Each comparison figure contains:

**Left Panel (Unipolar Reference):**
- Blue polar histogram (36 bins)
- Red mean vector (direction = mean phase, length = MRL)
- Statistics box: Mean phase and MRL

**Right Panel (Average Reference):**
- Red polar histogram (36 bins)
- Red mean vector
- Statistics box: Mean phase and MRL

**Bottom Panel:**
- **Phase shift:** Change in mean phase (degrees)
- **Coherence change:** Change in MRL (dimensionless)

## Usage

### Standard Execution

```matlab
% Navigate to working directory
cd('/path/to/your/working/directory');

% Run the script
Question2_Complete
```

### Alternative: Files in Different Locations

```matlab
% Add paths to required files
addpath('/path/to/unipolar/data/');     % Directory with EO1_ep_v8.mat
addpath('/path/to/avgref/data/');       % Directory with EO1_ep_v8_Avgref.mat
addpath('/path/to/custom/functions/');  % getElectrodeGroupsConn.m
addpath(genpath('/path/to/chronux/'));

% Navigate to script directory
cd('/path/to/script/directory/');

% Run the script
Question2_Complete
```

### Full Setup and Execution Example

```matlab
% Complete setup script
clear all; close all; clc;

% Set paths
workDir = '/Users/kirubananth/Documents/MATLAB/NS303/Assignment2/';
chronuxPath = '/Users/kirubananth/Documents/MATLAB/chronux/';

% Navigate to working directory
cd(workDir);

% Add Chronux to path
addpath(genpath(chronuxPath));

% Verify required files
requiredFiles = {
    'Question2_Complete.m', 
    'EO1_ep_v8.mat', 
    'EO1_ep_v8_Avgref.mat',
    'getElectrodeGroupsConn.m'
};

for i = 1:length(requiredFiles)
    if exist(requiredFiles{i}, 'file') ~= 2
        error('Required file not found: %s', requiredFiles{i});
    end
end

fprintf('All required files found.\n');

% Verify data compatibility
load('EO1_ep_v8.mat', 'data');
data_uni = data;
load('EO1_ep_v8_Avgref.mat', 'data');
data_avg = data;

assert(data_uni.fsample == data_avg.fsample, 'Sampling rates mismatch!');
assert(data_uni.numTrials == data_avg.numTrials, 'Trial counts mismatch!');

fprintf('Data files compatible. Starting analysis...\n\n');

% Run the analysis
Question2_Complete
```

### Expected Runtime
- **Total execution time:** ~10-15 minutes (depending on system)
- Data loading and verification: ~5 seconds
- Q2(a): ~2 minutes (3 pairs × 2 references)
- Q2(b): ~4-5 minutes (6 groups × 2 references)
- Q2(c): ~5-8 minutes (6 groups × 4 seeds × 13 frequencies × 2 references)

## Algorithm Details

### Data Processing Pipeline

**For each analysis:**

1. **Load both data files**
   - Unipolar-referenced data
   - Average-referenced data
   - Verify compatibility (same trials, sampling rate)

2. **Extract baseline-corrected signals**
   - Baseline: [-1, 0] seconds
   - Signal: [0, 1] seconds
   - Subtract baseline mean from signal

3. **Compute phase differences for BOTH references**
   - Multi-taper spectral analysis
   - Extract phase at target frequency
   - Calculate phase difference

4. **Create comparison visualization**
   - Side-by-side rose plots
   - Compute statistics for both
   - Calculate differences

### Multi-Taper Parameters

```matlab
params.tapers = [3 5];      % Time-bandwidth = 3, K = 5 tapers
params.Fs = 1000;           % Sampling frequency (Hz)
params.fpass = [0 100];     % Frequency range (Hz)
params.pad = 0;             % No padding
```

### Circular Statistics

**Mean Phase (Circular Mean):**
```
z = mean(exp(i·Δφ))
μ = angle(z)
```

**Mean Resultant Length (Phase Locking):**
```
MRL = |z|
```
- MRL = 0: No phase locking
- MRL = 1: Perfect phase locking

**Phase Shift (due to average referencing):**
```
Δμ = μ_avgref - μ_unipolar
```

**Coherence Change:**
```
ΔMRL = MRL_avgref - MRL_unipolar
```
- ΔMRL < 0: Coherence decreases (expected)
- ΔMRL > 0: Coherence increases (unexpected)

## Code Structure

```
Question2_Complete.m
│
├── SETUP AND DATA LOADING
│   ├── Load unipolar data
│   └── Load average-referenced data
│
├── EXTRACT BASELINE-CORRECTED DATA FOR BOTH REFERENCES
│   ├── Process unipolar data
│   └── Process average-ref data
│
├── CHRONUX PARAMETERS
│
├── QUESTION 2(a): Electrode pair comparison
│   ├── Compute for unipolar reference
│   ├── Compute for average reference
│   └── Create comparison plots (3 pairs)
│
├── QUESTION 2(b): Angular group comparison
│   ├── Group electrodes
│   ├── Compute for unipolar reference
│   ├── Compute for average reference
│   └── Create comparison plots (6 groups)
│
├── QUESTION 2(c): Multi-seed frequency pooling
│   ├── Define seeds and frequency range
│   ├── Triple pooling for unipolar
│   ├── Triple pooling for average ref
│   └── Create comparison plots (6 groups)
│
├── SUMMARY
│   └── Report expected findings
│
└── LOCAL HELPER FUNCTIONS
    ├── findElectrodeIndex()
    ├── computePhaseAtFrequency()
    ├── computePhaseDifference()
    └── plotComparisonRosePlot()
```

## Troubleshooting

### Directory and File Issues

1. **"Unable to open file 'EO1_ep_v8.mat'"**
   ```matlab
   % Check if file exists
   ls EO1_ep_v8.mat
   
   % Check current directory
   pwd
   
   % Navigate to correct location
   cd('/path/to/data/directory/');
   ```

2. **"Unable to open file 'EO1_ep_v8_Avgref.mat'"**
   ```matlab
   % Verify both files are in same directory
   dir('EO1_ep_v8*.mat')
   
   % You should see both files listed
   ```

3. **"Sampling frequencies do not match between files!"**
   - Both data files must have identical sampling rates
   - Regenerate average-referenced data from same source
   - Verify with: `load('file.mat'); disp(data.fsample);`

4. **"Number of trials do not match between files!"**
   - Both files must have same number of trials
   - Check with: `load('file.mat'); disp(data.numTrials);`
   - Ensure both were processed from same raw data

### Common Issues

1. **"Chronux toolbox not found"**
   ```matlab
   addpath(genpath('/path/to/chronux/'));
   ```

2. **"getElectrodeGroupsConn not found"**
   - Ensure function is in MATLAB path
   - Copy to working directory or use `addpath()`

3. **"Electrode not found" error**
   - Verify electrode labels match in both files
   - Check: `load('EO1_ep_v8.mat'); disp(data.label);`

4. **Memory issues**
   - Close unnecessary figures
   - Clear variables between sections
   - Reduce number of trials for testing

5. **Very slow execution**
   - Q2(c) is computationally intensive (4 seeds × groups × 13 frequencies × 2 refs)
   - Expected runtime: 5-8 minutes for Q2(c) alone
   - Consider reducing frequency range for testing

### Data Compatibility Check

```matlab
% Verify both files are compatible
load('EO1_ep_v8.mat', 'data');
uni_fs = data.fsample;
uni_trials = data.numTrials;
uni_labels = data.label;

load('EO1_ep_v8_Avgref.mat', 'data');
avg_fs = data.fsample;
avg_trials = data.numTrials;
avg_labels = data.label;

% Check compatibility
fprintf('Sampling Rate - Uni: %d, Avg: %d, Match: %d\n', uni_fs, avg_fs, uni_fs == avg_fs);
fprintf('Trials - Uni: %d, Avg: %d, Match: %d\n', uni_trials, avg_trials, uni_trials == avg_trials);
fprintf('Labels Match: %d\n', isequal(uni_labels, avg_labels));
```

## Interpretation Guide

### Expected Findings (Shirhatti et al., 2016)

**1. Phase Shift toward 180°**
- Unipolar: Mean phase ≈ 0° (or small value)
- Average ref: Mean phase ≈ 180° (or opposite direction)
- **Why:** Average referencing inverts the common signal component

**2. Decreased Phase Coherence**
- Unipolar: Higher MRL (stronger phase locking)
- Average ref: Lower MRL (weaker phase locking)
- ΔMRL < 0 (negative coherence change)
- **Why:** Average referencing removes common reference artifacts

**3. More Circular Distribution**
- Unipolar: Narrow, concentrated distribution
- Average ref: Broader, more uniform distribution
- **Why:** Reduced coherence spreads phase differences

**4. Frequency Dependency**
- **Low frequencies (alpha: 8-12 Hz):** Larger effect
- **High frequencies (beta/gamma: 20-32 Hz):** Smaller effect
- **Why:** Natural coherence is higher at low frequencies

### Reading Comparison Plots

**Phase Shift Interpretation:**
- |Δμ| ≈ 180°: Strong average referencing effect
- |Δμ| < 90°: Weak average referencing effect
- Sign depends on which electrode is reference

**Coherence Change Interpretation:**
- ΔMRL ≈ -0.3 to -0.5: Strong coherence reduction
- ΔMRL ≈ -0.1 to -0.2: Moderate coherence reduction
- ΔMRL ≈ 0: Minimal effect (may indicate artifact)

### Angular Distance Patterns (Q2b)

**Near electrodes (0-30°):**
- Higher baseline coherence (unipolar)
- Larger absolute coherence decrease
- May still show some coherence after averaging

**Far electrodes (150-180°):**
- Lower baseline coherence (unipolar)
- Smaller absolute coherence decrease
- May approach uniform distribution after averaging

### Frequency Range Comparison

**Q1(c) vs Q2(c) Frequency Difference:**
- Q1(c): 8-12 Hz (alpha band) - higher coherence
- Q2(c): 20-32 Hz (beta/gamma) - lower coherence
- **Effect:** Q2(c) may show weaker referencing effects

## Key Citations

### Primary Reference
**Shirhatti V, Borthakur A, Ray S (2016)** "Effect of Reference Scheme on Power and Phase of the Local Field Potential." *Neural Computation* 28(5):882-913.

Key findings from this paper:
- Average referencing shifts phase by ~180°
- Coherence decreases with average referencing
- Effect is frequency-dependent
- Low frequencies show stronger effects

### Methods References
1. Chronux toolbox: Mitra & Bokil (2008) "Observed Brain Dynamics"
2. Multi-taper methods: Thomson (1982) "Spectrum estimation and harmonic analysis"
3. Circular statistics: Fisher (1993) "Statistical Analysis of Circular Data"

## Differences from Question 1

| Aspect | Question 1 | Question 2 |
|--------|-----------|-----------|
| **Input files** | 1 (unipolar only) | 2 (unipolar + avgref) |
| **Analysis** | Single reference | Reference comparison |
| **Plots** | Single rose plot | Side-by-side comparison |
| **Q1c frequency** | 8-12 Hz (alpha) | 20-32 Hz (beta/gamma) |
| **Output count** | 3 composite figures | 15 comparison figures |
| **Runtime** | ~5-10 minutes | ~10-15 minutes |

## Version History

- **v1.0** (2026-04-13): Complete implementation
  - Side-by-side comparison plots
  - All three sub-questions (a, b, c)
  - Automated statistics reporting
  - Based on Shirhatti et al., 2016

## License

Academic use only. Part of NSP2026 coursework submission.

## Contact

For questions about this analysis:
- Author: Kirubananth S
- Course: NSP2026 - Neural Signal Processing
- Assignment: Assignment 2, Question 2
- Institution: IISc Bangalore

## Related Files

- **Question1_Composite.m** - Single reference analysis (prerequisite understanding)
- **EO1_ep_v8.mat** - Unipolar data (shared with Question 1)
- **EO1_ep_v8_Avgref.mat** - Average-referenced data (unique to Question 2)
