%% NSP Assignment 2 (EEG Module) - Question 1: Phase Coherence Analysis
% This script analyzes phase coherence in EEG data from subject 13AR, protocol EO1
% Parts: 1(a), 1(b), 1(c)
%


clear all; close all; clc;

%% ========================================================================
%  SETUP AND DATA LOADING
%  ========================================================================

% Create output directory for plots
outputDir = 'Question 1 Plots';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Load data
fprintf('Loading EEG data...\n');
load('EO1_ep_v8.mat');  % Contains 'data' structure

% Extract key parameters
Fs = double(data.fsample);  % Sampling frequency (1000 Hz)
timeVals = data.timeVals;   % Time vector
labels = data.label;        % Electrode labels
numTrials = double(data.numTrials);  % Number of trials (87)

% Extract electrode positions
elec_info = data.elec;
chanpos = elec_info.chanpos;  % Electrode positions
elec_labels = elec_info.label;

fprintf('Data loaded successfully.\n');
fprintf('  Sampling frequency: %d Hz\n', Fs);
fprintf('  Number of trials: %d\n', numTrials);
fprintf('  Number of electrodes: %d\n', length(labels));
fprintf('  Time range: %.3f to %.3f seconds\n', timeVals(1), timeVals(end));

%% ========================================================================
%  EXTRACT 1-SECOND BASELINE-CORRECTED DATA
%  ========================================================================

fprintf('\nExtracting 1-second signals with baseline [-1, 0]...\n');

% Define time windows
baselineStart = -1;
baselineEnd = 0;
signalStart = 0;
signalEnd = 1;

% Find indices
baselineIdx = find(timeVals >= baselineStart & timeVals <= baselineEnd);
signalIdx = find(timeVals >= signalStart & timeVals <= signalEnd);

fprintf('  Baseline window: [%.3f, %.3f] s (%d samples)\n', ...
    timeVals(baselineIdx(1)), timeVals(baselineIdx(end)), length(baselineIdx));
fprintf('  Signal window: [%.3f, %.3f] s (%d samples)\n', ...
    timeVals(signalIdx(1)), timeVals(signalIdx(end)), length(signalIdx));

% Extract and baseline-correct data
allData = cell(1, numTrials);
for tr = 1:numTrials
    trialData = data.trial{tr};  % 64 electrodes × 2500 time points
    
    % Baseline correction: subtract mean of baseline period
    baselineData = trialData(:, baselineIdx);
    baselineMean = mean(baselineData, 2);  % Mean across time for each electrode
    
    % Extract 1-second signal and baseline correct
    signalData = trialData(:, signalIdx);
    allData{tr} = signalData - repmat(baselineMean, 1, length(signalIdx));
end

fprintf('Data extraction and baseline correction complete.\n');

%% ========================================================================
%  SETUP CHRONUX PARAMETERS
%  ========================================================================

% Chronux parameters for multi-taper analysis
params.tapers = [3 5];  % [TW K] = [3 5] means time-bandwidth product = 3, 5 tapers
params.Fs = Fs;
params.fpass = [0 100];  % Frequency range of interest
params.pad = 0;  % Padding factor
params.err = 0;  % No error bars
params.trialave = 0;  % Don't average across trials initially

fprintf('\nChronux parameters configured:\n');
fprintf('  Tapers: [TW K] = [%d %d]\n', params.tapers(1), params.tapers(2));
fprintf('  Sampling frequency: %d Hz\n', params.Fs);

%% ========================================================================
%  QUESTION 1(a): Phase difference rose plots for specific electrode pairs
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 1(a)\n');
fprintf('========================================\n');

% Define electrode pairs
electrodePairs = {'Oz', 'P4'; 'Oz', 'C3'; 'Oz', 'AF4'};
targetFreq_1a = 30;  % Hz

fprintf('Computing phase differences at %.0f Hz for electrode pairs:\n', targetFreq_1a);

% Find electrode indices
ozIdx = findElectrodeIndex(labels, 'Oz');
p4Idx = findElectrodeIndex(labels, 'P4');
c3Idx = findElectrodeIndex(labels, 'C3');
af4Idx = findElectrodeIndex(labels, 'AF4');

fprintf('  Electrode indices: Oz=%d, P4=%d, C3=%d, AF4=%d\n', ozIdx, p4Idx, c3Idx, af4Idx);

% Process each electrode pair
for pairIdx = 1:size(electrodePairs, 1)
    elec1Name = electrodePairs{pairIdx, 1};
    elec2Name = electrodePairs{pairIdx, 2};
    
    fprintf('\nProcessing pair: %s - %s\n', elec1Name, elec2Name);
    
    % Find indices
    elec1Idx = findElectrodeIndex(labels, elec1Name);
    elec2Idx = findElectrodeIndex(labels, elec2Name);
    
    % Extract data for both electrodes across all trials
    data1 = zeros(length(signalIdx), numTrials);
    data2 = zeros(length(signalIdx), numTrials);
    
    for tr = 1:numTrials
        data1(:, tr) = allData{tr}(elec1Idx, :);
        data2(:, tr) = allData{tr}(elec2Idx, :);
    end
    
    % Compute phase differences
    phaseDiffs = computePhaseDifference(data1, data2, targetFreq_1a, params);
    
    % Plot rose plot
    titleStr = sprintf('Phase Difference: %s - %s at %.0f Hz', elec1Name, elec2Name, targetFreq_1a);
    savePrefix = sprintf('1a_%s_%s_%.0fHz', elec1Name, elec2Name, targetFreq_1a);
    
    plotRosePlotWithAvg(phaseDiffs, titleStr, savePrefix, outputDir);
end

fprintf('\nQuestion 1(a) complete.\n');

%% ========================================================================
%  QUESTION 1(b): Electrode groups based on angular distance from Oz
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 1(b)\n');
fprintf('========================================\n');

% Create chanlocs structure compatible with getElectrodeGroupsConn
fprintf('Creating chanlocs structure from electrode positions...\n');

% Convert Cartesian to spherical coordinates
chanlocs = struct();
for i = 1:length(elec_labels)
    chanlocs(i).labels = elec_labels{i};
    
    % Get Cartesian coordinates
    x = chanpos(i, 1);
    y = chanpos(i, 2);
    z = chanpos(i, 3);
    
    % Convert to spherical (radius, theta, phi)
    r = sqrt(x^2 + y^2 + z^2);
    theta = atan2(y, x);  % Azimuth
    phi = asin(z / r);     % Elevation
    
    % Store in degrees
    chanlocs(i).sph_theta = rad2deg(theta);
    chanlocs(i).sph_phi = rad2deg(phi);
    chanlocs(i).sph_radius = r;
end

% Save chanlocs to a temporary file for getElectrodeGroupsConn
save('temp_chanlocs.mat', 'chanlocs');

% Use getElectrodeGroupsConn to group electrodes
seedElectrode = 'Oz';
seedIdx = findElectrodeIndex(labels, seedElectrode);

fprintf('Grouping electrodes by angular distance from seed: %s (index %d)\n', seedElectrode, seedIdx);

% Call getElectrodeGroupsConn
[electrodeGroupList, groupNameList, binnedCenters, montageChanlocs] = ...
    getElectrodeGroupsConn('rel', seedIdx, 'temp_chanlocs');

fprintf('Electrode groups created:\n');
for g = 1:length(groupNameList)
    fprintf('  Group %d: %s - %d electrodes\n', g, groupNameList{g}, length(electrodeGroupList{1,g}));
end

% Compute phase differences for each group
fprintf('\nComputing phase differences for each group at %.0f Hz...\n', targetFreq_1a);

allGroupPhaseDiffs = cell(1, 6);

for groupIdx = 1:6
    fprintf('  Processing group %d/%d: %s\n', groupIdx, 6, groupNameList{groupIdx});
    
    % Get electrodes in this group
    groupElectrodes = electrodeGroupList{1, groupIdx};
    
    % Pool phase differences across all electrodes in group
    groupPhaseDiffs = [];
    
    % Loop over each electrode in the group
    for i = 1:length(groupElectrodes)
        elecIdx = groupElectrodes(i);
        
        % Extract data for seed (Oz) and current electrode
        dataSeed = zeros(length(signalIdx), numTrials);
        dataElec = zeros(length(signalIdx), numTrials);
        
        for tr = 1:numTrials
            dataSeed(:, tr) = allData{tr}(seedIdx, :);
            dataElec(:, tr) = allData{tr}(elecIdx, :);
        end
        
        % Compute phase differences
        phaseDiffs = computePhaseDifference(dataSeed, dataElec, targetFreq_1a, params);
        
        % Add to pool
        groupPhaseDiffs = [groupPhaseDiffs, phaseDiffs];
    end
    
    % Store for this group
    allGroupPhaseDiffs{groupIdx} = groupPhaseDiffs;
    
    % Plot rose plot for this group
    titleStr = sprintf('Group %d: %s\n%s at %.0f Hz', ...
        groupIdx, groupNameList{groupIdx}, seedElectrode, targetFreq_1a);
    savePrefix = sprintf('1b_Group%d', groupIdx);  % Simple naming without special chars
    
    plotRosePlotWithAvg(groupPhaseDiffs, titleStr, savePrefix, outputDir);
end

fprintf('\nQuestion 1(b) complete.\n');

%% ========================================================================
%  QUESTION 1(c): Multi-seed with frequency pooling
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 1(c)\n');
fprintf('========================================\n');

% Define seed electrodes (occipital cluster)
seedElectrodes = {'Oz', 'POz', 'O1', 'O2'};
freqRange = [20, 32];  % Hz
freqStep = 1;  % Hz

fprintf('Using %d seed electrodes: %s\n', length(seedElectrodes), strjoin(seedElectrodes, ', '));
fprintf('Frequency range: %.0f - %.0f Hz (step: %.0f Hz)\n', freqRange(1), freqRange(2), freqStep);

% Get indices for all seed electrodes
seedIndices = zeros(1, length(seedElectrodes));
for i = 1:length(seedElectrodes)
    seedIndices(i) = findElectrodeIndex(labels, seedElectrodes{i});
end

fprintf('Seed electrode indices: %s\n', mat2str(seedIndices));

% Get electrode groups for each seed
% We'll use Oz as the reference for grouping since it's the primary seed
[electrodeGroupList_multi, groupNameList_multi, ~, ~] = ...
    getElectrodeGroupsConn('rel', seedIndices(1), 'temp_chanlocs');

% Compute phase differences with triple pooling
fprintf('\nComputing phase differences with triple pooling...\n');
fprintf('  Pooling across:\n');
fprintf('    - 4 seed electrodes\n');
fprintf('    - All electrodes in each group\n');
fprintf('    - Frequency range %.0f-%.0f Hz\n', freqRange(1), freqRange(2));

allGroupPhaseDiffs_multi = cell(1, 6);

for groupIdx = 1:6
    fprintf('  Processing group %d/%d: %s\n', groupIdx, 6, groupNameList_multi{groupIdx});
    
    % Get electrodes in this group
    groupElectrodes = electrodeGroupList_multi{1, groupIdx};
    
    % Pool phase differences
    groupPhaseDiffs_multi = [];
    
    % Loop over each seed electrode
    for seedIdx_multi = seedIndices
        % Loop over each electrode in the group
        for i = 1:length(groupElectrodes)
            elecIdx = groupElectrodes(i);
            
            % Loop over frequency range
            for freq = freqRange(1):freqStep:freqRange(2)
                % Extract data
                dataSeed = zeros(length(signalIdx), numTrials);
                dataElec = zeros(length(signalIdx), numTrials);
                
                for tr = 1:numTrials
                    dataSeed(:, tr) = allData{tr}(seedIdx_multi, :);
                    dataElec(:, tr) = allData{tr}(elecIdx, :);
                end
                
                % Compute phase differences at this frequency
                phaseDiffs = computePhaseDifference(dataSeed, dataElec, freq, params);
                
                % Add to pool
                groupPhaseDiffs_multi = [groupPhaseDiffs_multi, phaseDiffs];
            end
        end
    end
    
    % Store for this group
    allGroupPhaseDiffs_multi{groupIdx} = groupPhaseDiffs_multi;
    
    % Plot rose plot for this group
    titleStr = sprintf('Group %d: %s\nSeeds: %s, Freq: %.0f-%.0f Hz', ...
        groupIdx, groupNameList_multi{groupIdx}, ...
        strjoin(seedElectrodes, ', '), freqRange(1), freqRange(2));
    savePrefix = sprintf('1c_Group%d', groupIdx);  % Simple naming without special chars
    
    plotRosePlotWithAvg(groupPhaseDiffs_multi, titleStr, savePrefix, outputDir);
end

fprintf('\nQuestion 1(c) complete.\n');

%% ========================================================================
%  SUMMARY AND CLEANUP
%  ========================================================================

fprintf('\n========================================\n');
fprintf('ANALYSIS COMPLETE\n');
fprintf('========================================\n');
fprintf('All plots saved to: %s\n', outputDir);
fprintf('  Question 1(a): 3 plots (Oz-P4, Oz-C3, Oz-AF4)\n');
fprintf('  Question 1(b): 6 plots (6 electrode groups)\n');
fprintf('  Question 1(c): 6 plots (6 groups with multi-seed and freq pooling)\n');
fprintf('Total plots: 15 (each in .png and .fig format)\n');

% Clean up temporary file
if exist('temp_chanlocs.mat', 'file')
    delete('temp_chanlocs.mat');
end

fprintf('\nScript execution complete!\n');

%% ========================================================================
%  LOCAL HELPER FUNCTIONS
%  ========================================================================

function idx = findElectrodeIndex(labels, elecName)
    % Find electrode index by name
    idx = 0;
    for i = 1:length(labels)
        if strcmp(labels{i}, elecName)
            idx = i;
            return;
        end
    end
    if idx == 0
        error('Electrode %s not found!', elecName);
    end
end

function phases = computePhaseAtFrequency(data, targetFreq, params)
    % Compute phase of signal at target frequency using mtfftc
    % Input:
    %   data: samples × trials matrix
    %   targetFreq: frequency in Hz
    %   params: Chronux parameters
    % Output:
    %   phases: phase values (radians) for each trial
    
    % Compute tapers
    N = size(data, 1);
    tapers = dpss(N, params.tapers(1), params.tapers(2));
    tapers = tapers * sqrt(params.Fs);  % Normalize
    
    % Compute multi-taper FFT
    nfft = max(2^(nextpow2(N) + params.pad), N);
    J = mtfftc(data, tapers, nfft, params.Fs);
    
    % Get frequency grid
    if mod(nfft, 2) == 0
        f = (0:nfft/2) * params.Fs / nfft;
    else
        f = (0:(nfft-1)/2) * params.Fs / nfft;
    end
    
    % Find index closest to target frequency
    [~, freqIdx] = min(abs(f - targetFreq));
    
    % Extract complex spectrum at target frequency
    % J is of size: frequency × tapers × trials
    J_targetFreq = squeeze(J(freqIdx, :, :));  % tapers × trials
    
    % Average across tapers
    J_avg = mean(J_targetFreq, 1);  % 1 × trials
    
    % Extract phase
    phases = angle(J_avg);  % Phase in radians
end

function phaseDiffs = computePhaseDifference(data1, data2, targetFreq, params)
    % Compute phase difference between two electrodes
    % Returns phase difference in radians
    
    phase1 = computePhaseAtFrequency(data1, targetFreq, params);
    phase2 = computePhaseAtFrequency(data2, targetFreq, params);
    
    phaseDiffs = phase1 - phase2;
end

function plotRosePlotWithAvg(phaseDiffs, titleStr, savePrefix, outputDir)
    % Create rose plot with average phase vector
    
    figure('Position', [100, 100, 800, 800]);
    
    % Create rose plot
    polarhistogram(phaseDiffs, 36, 'FaceColor', [0.3 0.6 0.9], 'FaceAlpha', 0.7);
    hold on;
    
    % Compute average phase vector (circular mean)
    % Using complex representation: mean of exp(i*theta)
    complexVec = exp(1i * phaseDiffs);
    meanComplexVec = mean(complexVec);
    
    % Extract magnitude and phase
    avgMagnitude = abs(meanComplexVec);
    avgPhase = angle(meanComplexVec);
    
    % Plot average vector as bold line
    % Get current axis limits to scale the arrow
    ax = gca;
    maxR = max(ax.RLim);
    
    % Plot average vector
    polarplot([0 avgPhase], [0 avgMagnitude * maxR * 0.8], ...
        'r-', 'LineWidth', 3);
    
    % Add title and labels
    title(titleStr, 'FontSize', 14, 'FontWeight', 'bold');
    
    % Add text with statistics
    dim = [0.15 0.15 0.3 0.1];
    str = sprintf('Mean Phase: %.2f rad (%.1f°)\nMean Resultant Length: %.3f', ...
        avgPhase, rad2deg(avgPhase), avgMagnitude);
    annotation('textbox', dim, 'String', str, 'FitBoxToText', 'on', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 10);
    
    hold off;
    
    % Save figure
    saveas(gcf, fullfile(outputDir, [savePrefix '.png']));
    saveas(gcf, fullfile(outputDir, [savePrefix '.fig']));
    
    fprintf('  Saved: %s\n', savePrefix);
end
