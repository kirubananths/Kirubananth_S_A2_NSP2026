# Question 1: EEG Phase Coherence Analysis

## Overview

This MATLAB script performs comprehensive phase coherence analysis on EEG data for NS303 Assignment 2 (Neural Signal Processing). It analyzes phase relationships between electrodes in subject 13AR, protocol EO1, using multi-taper spectral methods.

**Author:** Kirubananth S  
**File:** `Question1_Composite.m`

## Features

The script addresses three analysis components:

### Question 1(a): Specific Electrode Pair Analysis
- Computes phase differences at 30 Hz for three electrode pairs:
  - Oz - P4
  - Oz - C3
  - Oz - AF4
- Generates rose plots showing phase difference distributions
- Calculates circular mean phase and mean resultant length

### Question 1(b): Angular Distance Grouping
- Groups electrodes by angular distance from seed electrode (Oz)
- Creates 6 angular bins (0-30°, 30-60°, 60-90°, 90-120°, 120-150°, 150-180°)
- Computes pooled phase differences at 30 Hz for each group
- Visualizes phase coherence patterns as a function of spatial separation

### Question 1(c): Multi-Seed Frequency Pooling
- Uses 4 seed electrodes: Oz, O1, O2, POz
- Pools phase differences across:
  - All 4 seed electrodes
  - All electrodes in each angular group
  - Frequency range: 8-12 Hz (1 Hz steps)
- Provides robust phase coherence estimates through triple pooling

## Requirements

### MATLAB Version
- MATLAB R2016b or later (tested with R2023b)

### Toolboxes
1. **Chronux Toolbox** (required)
   - Download from: http://chronux.org/
   - Functions used:
     - `mtfftc` - Multi-taper FFT
     - `dpss` - Discrete prolate spheroidal sequences (tapers)

2. **MATLAB Signal Processing Toolbox** (standard)

### Custom Functions
The script requires the following custom function to be in the MATLAB path:
- `getElectrodeGroupsConn.m` - Groups electrodes by angular distance from seed

## Input Data

**Required File:** `EO1_ep_v8.mat`

This file must contain a `data` structure with the following fields:

```matlab
data.fsample       % Sampling frequency (Hz)
data.timeVals      % Time vector
data.label         % Cell array of electrode labels
data.numTrials     % Number of trials
data.trial         % Cell array of trial data (64 × 2500 per trial)
data.elec.chanpos  % Electrode Cartesian positions (64 × 3)
data.elec.label    % Electrode labels
```

### Expected Data Specifications
- **Sampling rate:** 1000 Hz
- **Number of electrodes:** 64
- **Number of trials:** 87
- **Time range:** -1.5 to 1.0 seconds (relative to stimulus onset)
- **Electrode positions:** 3D Cartesian coordinates

## Directory Setup

### Required Directory Structure

For the script to run flawlessly, organize your files as follows:

```
your_working_directory/
├── Question1_Composite.m           # Main analysis script
├── EO1_ep_v8.mat                   # Required input data file
├── getElectrodeGroupsConn.m        # Required custom function
└── chronux/                        # Chronux toolbox (or in MATLAB path)
    ├── spectral_analysis/
    ├── ...
```

### Essential Files in Same Directory

**1. Question1_Composite.m** (this script)
   - The main analysis script

**2. EO1_ep_v8.mat** (REQUIRED)
   - EEG data file for subject 13AR, protocol EO1
   - Must contain the `data` structure with all required fields
   - Place in the **same directory** as the script

**3. getElectrodeGroupsConn.m** (REQUIRED)
   - Custom function for grouping electrodes by angular distance
   - Must be in the same directory OR in your MATLAB path
   - Function signature: `[electrodeGroupList, groupNameList, binnedCenters, montageChanlocs] = getElectrodeGroupsConn(groupingMethod, seedIdx, chanlocsFile)`

### Files Created During Execution

The script will automatically create:

```
your_working_directory/
├── Question1_Composite.m
├── EO1_ep_v8.mat
├── getElectrodeGroupsConn.m
├── temp_chanlocs.mat              # Created temporarily, auto-deleted
└── Question 1 Plots/              # Created automatically
    ├── 1a_composite.png
    ├── 1a_composite.fig
    ├── 1b_composite.png
    ├── 1b_composite.fig
    ├── 1c_composite.png
    └── 1c_composite.fig
```

### Chronux Toolbox Setup

**Option 1: Add to MATLAB Path (Recommended)**
```matlab
addpath(genpath('/path/to/chronux/'));
savepath;  % Save for future sessions
```

**Option 2: Place in Same Directory**
- Copy the entire Chronux folder to your working directory
- Not recommended (clutters workspace)

### Pre-Execution Checklist

Before running the script, verify:

- [ ] `Question1_Composite.m` is in your current MATLAB directory
- [ ] `EO1_ep_v8.mat` is in the **same directory**
- [ ] `getElectrodeGroupsConn.m` is accessible (same directory or in path)
- [ ] Chronux toolbox is in MATLAB path
- [ ] You have write permissions for the directory (to create output folder)

### Quick Setup Commands

```matlab
% Navigate to your working directory
cd('/path/to/your/working/directory');

% Verify required files exist
assert(exist('Question1_Composite.m', 'file') == 2, 'Script not found!');
assert(exist('EO1_ep_v8.mat', 'file') == 2, 'Data file not found!');
assert(exist('getElectrodeGroupsConn.m', 'file') == 2, 'Custom function not found!');

% Add Chronux to path if not already there
if ~exist('mtfftc', 'file')
    addpath(genpath('/path/to/chronux/'));
end

% Verify Chronux is loaded
assert(exist('mtfftc', 'file') == 2, 'Chronux not found!');
assert(exist('dpss', 'file') == 2, 'DPSS function not found!');

% All checks passed - ready to run
fprintf('Setup complete! Ready to run Question1_Composite.m\n');
```

## Output

### Directory Structure After Execution
```
your_working_directory/
├── Question1_Composite.m
├── EO1_ep_v8.mat
├── getElectrodeGroupsConn.m
└── Question 1 Plots/              # Auto-created output directory
    ├── 1a_composite.png           # Q1(a): 3 electrode pairs (1×3 layout)
    ├── 1a_composite.fig
    ├── 1b_composite.png           # Q1(b): 6 angular groups (2×3 layout)
    ├── 1b_composite.fig
    ├── 1c_composite.png           # Q1(c): 6 multi-seed groups (2×3 layout)
    └── 1c_composite.fig
```

### Rose Plot Elements
Each rose plot includes:
1. **Histogram:** 36 bins showing phase difference distribution
2. **Red vector:** Mean phase direction and strength (mean resultant length)
3. **Statistics box:** 
   - Mean Phase (radians and degrees)
   - Mean Resultant Length (phase locking strength, 0-1)

## Usage

### Standard Execution (Files in Same Directory)

If you've followed the directory setup above:

```matlab
% Navigate to your working directory
cd('/path/to/your/working/directory');

% Run the script
Question1_Composite
```

### Alternative: Files in Different Locations

If your data or functions are elsewhere:

```matlab
% Add paths to required files
addpath('/path/to/data/');              % Directory containing EO1_ep_v8.mat
addpath('/path/to/custom/functions/');  % Directory containing getElectrodeGroupsConn.m
addpath(genpath('/path/to/chronux/'));  % Chronux toolbox

% Navigate to script directory
cd('/path/to/script/directory/');

% Run the script
Question1_Composite
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

% Verify all required files
requiredFiles = {'Question1_Composite.m', 'EO1_ep_v8.mat', 'getElectrodeGroupsConn.m'};
for i = 1:length(requiredFiles)
    if exist(requiredFiles{i}, 'file') ~= 2
        error('Required file not found: %s', requiredFiles{i});
    end
end

fprintf('All required files found. Starting analysis...\n\n');

% Run the analysis
Question1_Composite
```

### Expected Runtime
- **Total execution time:** ~5-10 minutes (depending on system)
- Data loading: <5 seconds
- Q1(a): ~1 minute
- Q1(b): ~2-3 minutes
- Q1(c): ~3-5 minutes (most computationally intensive)

## Algorithm Details

### Multi-Taper Spectral Analysis

**Parameters:**
```matlab
params.tapers = [3 5];      % Time-bandwidth product = 3, K = 5 tapers
params.Fs = 1000;           % Sampling frequency (Hz)
params.fpass = [0 100];     % Frequency range (Hz)
params.pad = 0;             % No padding
```

### Phase Difference Computation

1. **Extract baseline-corrected signals:**
   - Baseline window: [-1, 0] seconds
   - Signal window: [0, 1] seconds
   - Baseline correction: subtract mean of baseline period

2. **Compute multi-taper FFT:**
   - Generate DPSS tapers
   - Apply tapers to signal
   - Compute FFT for each taper

3. **Extract phase:**
   - Average complex spectrum across tapers
   - Extract phase using `angle()` function

4. **Calculate phase difference:**
   ```
   Δφ = φ₁ - φ₂
   ```

### Circular Statistics

**Mean Phase (Circular Mean):**
```
z = mean(exp(i·Δφ))
μ = angle(z)
```

**Mean Resultant Length (Phase Locking Value):**
```
R = |z|
```
- R = 0: No phase locking
- R = 1: Perfect phase locking

## Code Structure

```
Question1_Composite.m
│
├── SETUP AND DATA LOADING
│   ├── Load EEG data
│   └── Extract parameters
│
├── EXTRACT 1-SECOND BASELINE-CORRECTED DATA
│   ├── Define time windows
│   └── Baseline correction
│
├── SETUP CHRONUX PARAMETERS
│
├── QUESTION 1(a): Specific electrode pairs
│   ├── Compute phase differences
│   └── Create composite figure
│
├── QUESTION 1(b): Angular distance grouping
│   ├── Convert coordinates to spherical
│   ├── Group electrodes
│   ├── Compute pooled phase differences
│   └── Create composite figure
│
├── QUESTION 1(c): Multi-seed frequency pooling
│   ├── Define seed electrodes
│   ├── Triple pooling (seeds × groups × frequencies)
│   └── Create composite figure
│
└── LOCAL HELPER FUNCTIONS
    ├── findElectrodeIndex()
    ├── computePhaseAtFrequency()
    ├── computePhaseDifference()
    └── createCompositeFigure()
```

## Troubleshooting

### Directory and File Issues

1. **"Unable to open file 'EO1_ep_v8.mat'"**
   ```matlab
   % Check if file exists in current directory
   ls EO1_ep_v8.mat
   
   % If not, find where it is
   pwd  % Show current directory
   
   % Either move the file or navigate to it
   cd('/path/to/data/directory/');
   ```

2. **"Output directory creation failed"**
   - Check write permissions in current directory
   - On Unix/Mac: `!ls -la` to check permissions
   - Try running MATLAB as administrator (Windows) or with sudo (not recommended)

3. **"temp_chanlocs.mat not deleted"**
   - Script should auto-delete this file
   - If it persists, manually delete: `delete('temp_chanlocs.mat')`

### Common Issues

1. **"Chronux toolbox not found"**
   ```matlab
   addpath(genpath('/path/to/chronux/'));
   ```

2. **"getElectrodeGroupsConn not found"**
   - Ensure the custom function is in your MATLAB path
   - Check that `temp_chanlocs.mat` is being created properly

3. **"Electrode not found" error**
   - Verify electrode labels in your data match expected names
   - Check `data.label` field

4. **Memory issues with large datasets**
   - Reduce number of trials
   - Use `clear` between sections
   - Close figures after saving

### Performance Optimization

- Pre-allocate arrays where possible
- Use vectorized operations
- Consider `parfor` for trial loops (requires Parallel Computing Toolbox)

## Interpretation Guide

### Phase Difference Patterns
- **Narrow distribution:** Strong phase locking (high R)
- **Uniform distribution:** Weak/no phase locking (low R)
- **Bimodal distribution:** Two preferred phase relationships

### Angular Distance Effects (Q1b)
- **Near groups (0-30°):** Often show stronger phase locking
- **Far groups (150-180°):** May show weaker coherence
- Pattern depends on neural communication pathways

### Frequency Pooling (Q1c)
- Alpha band (8-12 Hz) pooling reduces noise
- Multiple seeds increase robustness
- Larger sample size improves statistical power

## Citations

### Methods References
1. Chronux toolbox: Mitra & Bokil (2008) "Observed Brain Dynamics"
2. Multi-taper methods: Thomson (1982) "Spectrum estimation and harmonic analysis"
3. Circular statistics: Fisher (1993) "Statistical Analysis of Circular Data"

## Version History

- **v1.0** (2026-04-13): Initial composite figure version
  - Combined individual plots into composite layouts
  - Maintained identical appearance to single plots
  - Added comprehensive documentation

## License

Academic use only. Part of NSP2026 coursework submission.

## Contact

For questions about this analysis:
- Author: Kirubananth S
- Course: NSP2026 - Neural Signal Processing
- Institution: IISc Bangalore
