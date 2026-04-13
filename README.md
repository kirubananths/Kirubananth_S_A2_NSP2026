# NS303 Assignment 2 - EEG Connectivity Analysis

**Author:** Kirubananth S  
**SR Number:** 26956  
**Course:** NSP2026 - Neural Signal Processing  
**Institution:** Indian Institute of Science (IISc), Bangalore  
  

---

## 📋 Assignment Overview

This repository contains the complete MATLAB implementation for NS303 Assignment 2 on EEG connectivity analysis. The assignment analyzes phase coherence, connectivity metrics, and trial-count bias using multi-taper spectral methods.

**Topics Covered:**
- Phase coherence analysis with rose plots
- Effects of average re-referencing on phase relationships
- Connectivity metrics (Coherence, WPLI, PPC) computed from spectra
- Trial-count bias analysis demonstrating PPC as an unbiased estimator

---

## 📁 Repository Structure

```
Kirubananth_S_A2_NSP2026/
│
├── README.md                           # This file - Main documentation
│
├── Question1/
│   ├── Question1_Composite.m           # Phase coherence analysis
│   ├── getElectrodeGroupsConn.m        # Electrode grouping function
│   └── README_Question1.md             # Detailed Q1 documentation
│
├── Question2/
│   ├── Question2_Complete.m            # Average re-referencing effects
│   ├── getElectrodeGroupsConn.m        # Electrode grouping function
│   └── README_Question2.md             # Detailed Q2 documentation
│
├── Question3/
│   ├── Question3Codeforsubmission.m    # Connectivity metrics (multi-taper) - MAIN
│   ├── Question3_StandardFFT_Code_FIXED.m  # Alternative (standard FFT) - APPENDIX
│   └── README_Question3.md             # Detailed Q3 documentation
│
└── Question4/
    ├── Question4_Complete_Code_FIXED.m     # Bias analysis (multi-taper) - MAIN
    ├── Question4_StandardFFT_Code.m        # Alternative (standard FFT) - APPENDIX
    └── README_Question4.md             # Detailed Q4 documentation
```

---

## 🎯 Questions Summary

### Question 1: Phase Coherence Analysis (Rose Plots)
**Data:** Subject 13AR, protocol EO1, unipolar reference  
**Electrodes:** Oz-P4, Oz-C3, Oz-AF4, and angular groups from Oz  
**Analysis:** Phase differences at 30 Hz and 8-12 Hz pooling  
**Output:** 3 composite rose plot figures (6 panels each)

### Question 2: Average Re-referencing Effects
**Data:** Subject 13AR, protocol EO1 (both unipolar and average-referenced)  
**Reference:** Shirhatti et al., 2016, Neural Computation  
**Analysis:** Compare phase coherence between referencing schemes  
**Output:** 15 comparison plots showing referencing effects

### Question 3: Connectivity Metrics from Spectra
**Data:** Subject 013AR, protocol M1, unipolar reference  
**Electrodes:** PO3 and AF4  
**Metrics:** Coherence, WPLI, PPC (computed WITHOUT FieldTrip functions)  
**Output:** 4 plots (individual metrics + comparison)

### Question 4: Trial-Count Bias Analysis
**Data:** Subject 013AR, protocol M1, unipolar reference  
**Analysis:** Compare full trials vs 1/3 trials  
**Finding:** PPC is unbiased; Coherence and WPLI show positive bias  
**Output:** 5 comprehensive bias analysis plots + mathematical derivation

---

## ⚙️ System Requirements

### MATLAB Version
- **MATLAB R2016b or later** (tested with R2023b)
- Earlier versions may work but are not tested

### Required Toolboxes
1. **Chronux Toolbox** (ESSENTIAL - Questions 1, 2, 3, 4)
   - Download: http://chronux.org/
   - Functions used: `mtfftc`, `dpss`
   
2. **MATLAB Signal Processing Toolbox** (Standard with MATLAB)
   - Usually pre-installed with MATLAB

### Optional (for Appendix codes only)
- Appendix codes use standard MATLAB `fft` function
- No Chronux required for appendix versions

---

## 📥 Data Files - CRITICAL SETUP INSTRUCTIONS

### Required Data Files

The assignment requires **THREE data files** that are **NOT included in this repository** due to their large size (>100MB each):

#### For Questions 1 & 2:
1. **`EO1_ep_v8.mat`** - Subject 13AR, protocol EO1, **unipolar reference** (found in ftData Folder)
2. **`EO1_ep_v8_Avgref.mat`** - Subject 13AR, protocol EO1, **average reference** (found in ftDataAvgRef Folder. Note: Rename the EO1 dataset to the name I have written in this setence.)

#### For Questions 3 & 4:
3. **`M1_ep_v8.mat`** - Subject 013AR, protocol M1, **unipolar reference** (found in ftData Folder)

### Where to Get Data Files

**Option 1: Course Resources (Recommended)**
- Data files are provided by NS303 course instructors
- Check your course Teams channel / Google Drive / Course website
- Contact course TAs if you cannot locate the files

**Option 2: Generate Using Provided Scripts (If available)**
- If you have `runSaveFTConnData.m` from `connectivityProjectCodes`
- Run this script to generate the data files from raw data

### Data File Specifications

All files are in **FieldTrip format** with this structure:
```matlab
data.fsample       % Sampling frequency (1000 Hz)
data.timeVals      % Time vector
data.label         % Cell array of 64 electrode labels
data.numTrials     % Number of trials (typically 87-235)
data.trial         % Cell array: {trial1, trial2, ...}
                   % Each trial: 64 electrodes × 2500 time points
data.elec.chanpos  % Electrode 3D positions (64 × 3)
data.elec.label    % Electrode labels
```

**File Sizes:**
- Each `.mat` file is approximately **150-250 MB**
- Total data: ~500-700 MB
- **This is why they're not in the repository!**

---

## 🗂️ Setting Up Your Working Directory - STEP BY STEP

### Step 1: Clone This Repository

```bash
# Using Git command line
git clone https://github.com/YourUsername/Kirubananth_S_A2_NSP2026.git
cd Kirubananth_S_A2_NSP2026
```

Or **download as ZIP** from GitHub and extract.

### Step 2: Download and Install Chronux

1. **Download Chronux:**
   - Visit: http://chronux.org/
   - Download the latest version
   - Extract to a location on your computer

2. **Add Chronux to MATLAB Path:**
   ```matlab
   % Open MATLAB
   addpath(genpath('/path/to/chronux_2_12/'));
   savepath;  % Save for future sessions
   
   % Verify installation
   which mtfftc  % Should show path to Chronux
   ```

### Step 3: Download Data Files

1. **Locate the data files** from your course resources
2. **Download all three .mat files:**
   - `EO1_ep_v8.mat`
   - `EO1_ep_v8_Avgref.mat`
   - `M1_ep_v8.mat`

### Step 4: Organize Your Working Directory

**CRITICAL:** Create this EXACT structure on your computer:

```
Your_MATLAB_Working_Directory/
│
├── Question1/
│   ├── Question1_Composite.m           # From GitHub
│   ├── getElectrodeGroupsConn.m        # From GitHub
│   ├── EO1_ep_v8.mat                   # YOU DOWNLOAD THIS
│   └── README_Question1.md             # From GitHub
│
├── Question2/
│   ├── Question2_Complete.m            # From GitHub
│   ├── getElectrodeGroupsConn.m        # From GitHub
│   ├── EO1_ep_v8.mat                   # YOU DOWNLOAD THIS
│   ├── EO1_ep_v8_Avgref.mat           # YOU DOWNLOAD THIS
│   └── README_Question2.md             # From GitHub
│
├── Question3/
│   ├── Question3Codeforsubmission.m    # From GitHub
│   ├── Question3_StandardFFT_Code_FIXED.m  # From GitHub
│   ├── M1_ep_v8.mat                    # YOU DOWNLOAD THIS
│   └── README_Question3.md             # From GitHub
│
└── Question4/
    ├── Question4_Complete_Code_FIXED.m # From GitHub
    ├── Question4_StandardFFT_Code.m    # From GitHub
    ├── M1_ep_v8.mat                    # YOU DOWNLOAD THIS
    └── README_Question4.md             # From GitHub
```

**Key Points:**
- Each question folder contains its own data files
- Data files are placed in the SAME folder as the code
- `getElectrodeGroupsConn.m` is needed for Q1 and Q2

### Step 5: Verify Setup

Run this verification script in MATLAB:

```matlab
% Verification Script - Run this before starting assignment
clear all; clc;

fprintf('===========================================\n');
fprintf('NS303 Assignment 2 - Setup Verification\n');
fprintf('===========================================\n\n');

% Check Chronux
fprintf('Checking Chronux Toolbox...\n');
if exist('mtfftc', 'file')
    fprintf('  ✓ Chronux found!\n');
else
    fprintf('  ✗ Chronux NOT found. Please add to path.\n');
    fprintf('    Run: addpath(genpath(''/path/to/chronux/''));\n');
end

if exist('dpss', 'file')
    fprintf('  ✓ DPSS (Signal Processing Toolbox) found!\n');
else
    fprintf('  ✗ DPSS NOT found. Install Signal Processing Toolbox.\n');
end

fprintf('\n');

% Check Question 1
fprintf('Checking Question 1 files...\n');
if exist('Question1/Question1_Composite.m', 'file')
    fprintf('  ✓ Question1_Composite.m found\n');
else
    fprintf('  ✗ Question1_Composite.m NOT found\n');
end

if exist('Question1/EO1_ep_v8.mat', 'file')
    fprintf('  ✓ EO1_ep_v8.mat found\n');
else
    fprintf('  ✗ EO1_ep_v8.mat NOT found - DOWNLOAD THIS FILE!\n');
end

if exist('Question1/getElectrodeGroupsConn.m', 'file')
    fprintf('  ✓ getElectrodeGroupsConn.m found\n');
else
    fprintf('  ✗ getElectrodeGroupsConn.m NOT found\n');
end

fprintf('\n');

% Check Question 2
fprintf('Checking Question 2 files...\n');
if exist('Question2/Question2_Complete.m', 'file')
    fprintf('  ✓ Question2_Complete.m found\n');
else
    fprintf('  ✗ Question2_Complete.m NOT found\n');
end

if exist('Question2/EO1_ep_v8.mat', 'file')
    fprintf('  ✓ EO1_ep_v8.mat found\n');
else
    fprintf('  ✗ EO1_ep_v8.mat NOT found - DOWNLOAD THIS FILE!\n');
end

if exist('Question2/EO1_ep_v8_Avgref.mat', 'file')
    fprintf('  ✓ EO1_ep_v8_Avgref.mat found\n');
else
    fprintf('  ✗ EO1_ep_v8_Avgref.mat NOT found - DOWNLOAD THIS FILE!\n');
end

fprintf('\n');

% Check Question 3
fprintf('Checking Question 3 files...\n');
if exist('Question3/Question3Codeforsubmission.m', 'file')
    fprintf('  ✓ Question3Codeforsubmission.m found\n');
else
    fprintf('  ✗ Question3Codeforsubmission.m NOT found\n');
end

if exist('Question3/M1_ep_v8.mat', 'file')
    fprintf('  ✓ M1_ep_v8.mat found\n');
else
    fprintf('  ✗ M1_ep_v8.mat NOT found - DOWNLOAD THIS FILE!\n');
end

fprintf('\n');

% Check Question 4
fprintf('Checking Question 4 files...\n');
if exist('Question4/Question4_Complete_Code_FIXED.m', 'file')
    fprintf('  ✓ Question4_Complete_Code_FIXED.m found\n');
else
    fprintf('  ✗ Question4_Complete_Code_FIXED.m NOT found\n');
end

if exist('Question4/M1_ep_v8.mat', 'file')
    fprintf('  ✓ M1_ep_v8.mat found\n');
else
    fprintf('  ✗ M1_ep_v8.mat NOT found - DOWNLOAD THIS FILE!\n');
end

fprintf('\n');
fprintf('===========================================\n');
fprintf('Verification Complete!\n');
fprintf('If all items show ✓, you are ready to run.\n');
fprintf('===========================================\n');
```

---

## 🚀 Running the Code

### Quick Start - Run All Questions

```matlab
% Run from repository root directory

% Question 1
cd Question1
Question1_Composite
cd ..

% Question 2
cd Question2
Question2_Complete
cd ..

% Question 3
cd Question3
Question3Codeforsubmission
cd ..

% Question 4
cd Question4
Question4_Complete_Code_FIXED
cd ..
```

### Individual Question Instructions

#### Question 1: Phase Coherence Analysis

```matlab
cd Question1
Question1_Composite
```

**Runtime:** ~5-10 minutes  
**Output:** `Question 1 Plots/` folder with 3 composite figures

#### Question 2: Average Re-referencing

```matlab
cd Question2
Question2_Complete
```

**Runtime:** ~10-15 minutes  
**Output:** `Question 2 Plots/` folder with 15 comparison plots

#### Question 3: Connectivity Metrics

```matlab
cd Question3
Question3Codeforsubmission  % Main code (multi-taper)

% Optional: Run appendix for comparison
Question3_StandardFFT_Code_FIXED  % Standard FFT version
```

**Runtime:** ~5-10 seconds (very fast!)  
**Output:** `Question 3 Plots/` folder with 4 plots

#### Question 4: Trial-Count Bias

```matlab
cd Question4
Question4_Complete_Code_FIXED  % Main code (multi-taper)

% Optional: Run appendix for comparison
Question4_StandardFFT_Code  % Standard FFT version
```

**Runtime:** ~10-15 seconds  
**Output:** `Question_4_Plots/` folder with 5 plots + console derivation

**Note:** Question 4(b) prints a mathematical derivation to the console during execution.

---

## 📊 Expected Outputs

### Question 1 Output
```
Question1/
└── Question 1 Plots/
    ├── 1a_composite.png        # 3 electrode pairs (Oz-P4, Oz-C3, Oz-AF4)
    ├── 1a_composite.fig
    ├── 1b_composite.png        # 6 angular groups from Oz
    ├── 1b_composite.fig
    ├── 1c_composite.png        # Multi-seed frequency pooling
    └── 1c_composite.fig
```

### Question 2 Output
```
Question2/
└── Question 2 Plots/
    ├── Q2a_Oz_P4_30Hz_comparison.png    # 3 electrode pair comparisons
    ├── Q2a_Oz_C3_30Hz_comparison.png
    ├── Q2a_Oz_AF4_30Hz_comparison.png
    ├── Q2b_Group1-6_comparison.png      # 6 group comparisons
    ├── Q2c_Group1-6_comparison.png      # 6 multi-seed comparisons
    └── ... (30 files total: .png and .fig)
```

### Question 3 Output
```
Question3/
└── Question 3 Plots/
    ├── Q3_all_metrics_comparison.png    # All 3 metrics together
    ├── Q3a_Coherence.png                # Individual metric plots
    ├── Q3b_WPLI.png
    ├── Q3c_PPC.png
    ├── Q3_results.mat                   # Saved results
    └── ... (.fig versions)
```

### Question 4 Output
```
Question4/
└── Question_4_Plots/
    ├── Q4a_comprehensive_bias_comparison.png  # 6-panel comparison
    ├── Q4a_coherence_comparison.png           # Individual comparisons
    ├── Q4a_wpli_comparison.png
    ├── Q4a_ppc_comparison_unbiased.png
    ├── Q4a_bias_difference_plots.png          # 3-panel bias plots
    ├── Q4_results.mat
    └── ... (.fig versions)
```

**Plus:** Console output showing mathematical derivation (Question 4b)

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Issue 1: "Chronux not found"
```matlab
% Solution:
addpath(genpath('/full/path/to/chronux/'));
savepath;

% Verify:
which mtfftc  % Should show path
```

#### Issue 2: "Unable to open file 'EO1_ep_v8.mat'"
```
Error: File not found in current directory

Solution:
1. Verify data file is in the same folder as the script
2. Check spelling: EO1_ep_v8.mat (exact case)
3. Use: ls *.mat  % to see what .mat files exist
```

#### Issue 3: "getElectrodeGroupsConn not found"
```matlab
% Solution: Add to path or copy to question folder
addpath('/path/to/custom/functions/');

% Or verify file is in same directory as script
ls getElectrodeGroupsConn.m
```

#### Issue 4: "Out of memory"
```
Solution:
1. Close other MATLAB figures: close all
2. Clear workspace: clear all
3. Reduce trial count for testing (edit code)
4. Increase MATLAB memory limit (preferences)
```

#### Issue 5: Different results from expected
```
Possible causes:
1. Wrong data file loaded
2. Different MATLAB/Chronux version
3. Random seed differences (Question 4)
4. Check console output for warnings
```

### Data File Verification

To verify you have the correct data files:

```matlab
% Load and check EO1 data
load('Question1/EO1_ep_v8.mat');
fprintf('EO1 Sampling rate: %d Hz\n', data.fsample);
fprintf('EO1 Number of trials: %d\n', data.numTrials);
fprintf('EO1 Number of electrodes: %d\n', length(data.label));

% Should show:
% EO1 Sampling rate: 1000 Hz
% EO1 Number of trials: 87
% EO1 Number of electrodes: 64

% Load and check M1 data
load('Question3/M1_ep_v8.mat');
fprintf('M1 Sampling rate: %d Hz\n', data.fsample);
fprintf('M1 Number of trials: %d\n', data.numTrials);

% Should show:
% M1 Sampling rate: 1000 Hz
% M1 Number of trials: 235
```

---

## 📖 Detailed Documentation

Each question folder contains a detailed README with:
- Algorithm explanations
- Parameter descriptions
- Input/output specifications
- Code structure
- Interpretation guides
- Troubleshooting specific to that question

**Read these for in-depth understanding:**
- `Question1/README_Question1.md`
- `Question2/README_Question2.md`
- `Question3/README_Question3.md`
- `Question4/README_Question4.md`

---

## 🔑 Key Findings Summary

### Question 1: Phase Coherence
- Phase coherence **decreases** with inter-electrode distance
- Strongest coherence in 0-30° group (near electrodes)
- Weakest coherence in 150-180° group (far electrodes)
- Multi-seed frequency pooling provides robust estimates

### Question 2: Average Re-referencing
- Average referencing shifts mean phase by ~**180°**
- **Reduces** phase coherence (Mean Resultant Length decreases)
- Creates more uniform (circular) phase distributions
- Effect is **stronger** at low frequencies with high baseline coherence

### Question 3: Connectivity Metrics
- **Coherence:** Standard magnitude coherency (range: 0-1)
- **WPLI:** Reduces volume conduction, uses imaginary part
- **PPC:** Phase-only, unbiased estimator of PLV²
- All three can be computed directly from cross/auto spectra

### Question 4: Trial-Count Bias
- **Coherence:** Shows **positive bias** with fewer trials (+0.02 to +0.05)
- **WPLI:** Shows **positive bias** with fewer trials (+0.01 to +0.03)
- **PPC:** Shows **minimal bias** (±0.001) - **UNBIASED!**
- Mathematical proof demonstrates E[PPC] = PLV² regardless of N

---

## 📚 Key References

### Methods
1. **Multi-taper methods:** Thomson (1982) "Spectrum estimation and harmonic analysis"
2. **Chronux:** Mitra & Bokil (2008) "Observed Brain Dynamics"
3. **Average re-referencing:** Shirhatti et al. (2016) "Effect of Reference Scheme on Power and Phase" *Neural Computation*
4. **PPC (unbiased):** Vinck et al. (2010) "The pairwise phase consistency" *NeuroImage*
5. **WPLI:** Vinck et al. (2011) "An improved index of phase-synchronization" *NeuroImage*

### Assignment Reference
- NS303 Assignment 2 - EEG Module
- Due: April 12, 2026
- Course Instructor: [Instructor Name]
- Institution: Indian Institute of Science, Bangalore

---

## ⚠️ Important Notes

### What's Included in This Repository
✅ All MATLAB code files (.m)  
✅ README documentation  
✅ Helper functions (getElectrodeGroupsConn.m)  
✅ .gitignore (prevents data/plot upload)  

### What's NOT Included (You Must Download)
❌ Data files (.mat) - too large for GitHub  
❌ Chronux toolbox - download separately  
❌ Plot outputs - generated when you run code  

### Before Running
- [ ] Chronux installed and in MATLAB path
- [ ] All 3 data files downloaded
- [ ] Data files placed in correct question folders
- [ ] Verification script passed all checks

### Expected Total Runtime
- Question 1: ~5-10 minutes
- Question 2: ~10-15 minutes
- Question 3: ~10 seconds
- Question 4: ~15 seconds
- **Total: ~15-25 minutes** for all questions

---

## 📞 Support

### If You Encounter Issues:

1. **Check this README** - Most issues are addressed here
2. **Read question-specific READMEs** - Detailed troubleshooting per question
3. **Verify setup** - Run verification script above
4. **Check file locations** - Data must be in same folder as code
5. **Contact course TAs** - For data file access issues

### Common Questions


**Q: Can I run without Chronux?**  
A: No, Chronux is required for main codes. Appendix codes use standard FFT.

**Q: Why are data files not in the repository?**  
A: GitHub has a 100MB file limit. Data files are 150-250MB each.

**Q: Do I need to run appendix codes?**  
A: No, appendix codes are optional comparisons using standard FFT.

**Q: How long does the full assignment take to run?**  
A: Approximately 15-25 minutes total for all 4 questions.

---

## 📜 License

**Academic Use Only**  
This code is part of NSP2026 coursework submission.  
Not for commercial use or redistribution.

---

## ✉️ Contact

**Student:** Kirubananth S  
**SR Number:** 26956  
**Email:** kirubananths@iisc.ac.in , kirubananths1@gmail.com  
**Institution:** Indian Institute of Science (IISc), Bangalore  
**Course:** NSP2026 - Neural Signal Processing  
**Academic Year:** 2025-2026  

---

## 🙏 Acknowledgments

- NSP2026 Course Instructors and TAs
- Chronux development team (Mitra & Bokil)
- Original authors of connectivity methods (Vinck et al., Shirhatti et al.)

---

**Last Updated:** April 2026  
**Repository:** https://github.com/kirubananths/Kirubananth_S_A2_NSP2026
