%% NSP Assignment 2 (EEG Module) - Question 2: Average Re-referencing Analysis
% This script compares phase coherence between unipolar and average-referenced data
% Based on Shirhatti et al., 2016, Neural Computation
% Author - Kirubananth S


clear all; close all; clc;

%% ========================================================================
%  SETUP AND DATA LOADING
%  ========================================================================

% Create output directory for plots
outputDir = 'Question 2 Plots';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Load unipolar referenced data (from Question 1)
fprintf('Loading EEG data (unipolar reference)...\n');
load('EO1_ep_v8.mat');  % Contains unipolar data
dataUnipolar = data;  % Save unipolar data

% Extract key parameters from unipolar data
Fs = double(dataUnipolar.fsample);
timeVals = dataUnipolar.timeVals;
labels = dataUnipolar.label;
numTrials = double(dataUnipolar.numTrials);
elec_info = dataUnipolar.elec;
chanpos = elec_info.chanpos;
elec_labels = elec_info.label;

fprintf('Unipolar data loaded successfully.\n');
fprintf('  Sampling frequency: %d Hz\n', Fs);
fprintf('  Number of trials: %d\n', numTrials);
fprintf('  Number of electrodes: %d\n', length(labels));

%% ========================================================================
%  LOAD AVERAGE RE-REFERENCED DATA
%  ========================================================================

fprintf('\nLoading average re-referenced data...\n');
load('EO1_ep_v8_Avgref.mat');  % Contains average-referenced data
dataAvgRef = data;  % Save average-referenced data

% Verify parameters match
if double(dataAvgRef.fsample) ~= Fs
    error('Sampling frequencies do not match between files!');
end
if double(dataAvgRef.numTrials) ~= numTrials
    error('Number of trials do not match between files!');
end

fprintf('Average re-referenced data loaded successfully.\n');
fprintf('  Verified: Same number of trials (%d) and sampling rate (%d Hz)\n', numTrials, Fs);

%% ========================================================================
%  EXTRACT BASELINE-CORRECTED DATA FOR BOTH REFERENCES
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

% Extract and baseline-correct data for UNIPOLAR reference
allDataUnipolar = cell(1, numTrials);
for tr = 1:numTrials
    trialData = dataUnipolar.trial{tr};
    baselineData = trialData(:, baselineIdx);
    baselineMean = mean(baselineData, 2);
    signalData = trialData(:, signalIdx);
    allDataUnipolar{tr} = signalData - repmat(baselineMean, 1, length(signalIdx));
end

% Extract and baseline-correct data for AVERAGE REFERENCE
allDataAvgRef = cell(1, numTrials);
for tr = 1:numTrials
    trialData = dataAvgRef.trial{tr};
    baselineData = trialData(:, baselineIdx);
    baselineMean = mean(baselineData, 2);
    signalData = trialData(:, signalIdx);
    allDataAvgRef{tr} = signalData - repmat(baselineMean, 1, length(signalIdx));
end

fprintf('Data extraction and baseline correction complete.\n');

%% ========================================================================
%  CHRONUX PARAMETERS
%  ========================================================================

params.tapers = [3 5];
params.Fs = Fs;
params.fpass = [0 100];
params.pad = 0;
params.err = 0;
params.trialave = 0;

fprintf('\nChronux parameters configured:\n');
fprintf('  Tapers: [TW K] = [%d %d]\n', params.tapers(1), params.tapers(2));

%% ========================================================================
%  QUESTION 2(a): Compare Unipolar vs Average Reference for Electrode Pairs
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 2(a): Comparing Q1(a) results\n');
fprintf('========================================\n');

electrodePairs = {'Oz', 'P4'; 'Oz', 'C3'; 'Oz', 'AF4'};
targetFreq = 30;  % Hz

fprintf('Computing phase differences at %.0f Hz for electrode pairs:\n', targetFreq);

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
    
    % ===== UNIPOLAR REFERENCE =====
    data1_uni = zeros(length(signalIdx), numTrials);
    data2_uni = zeros(length(signalIdx), numTrials);
    for tr = 1:numTrials
        data1_uni(:, tr) = allDataUnipolar{tr}(elec1Idx, :);
        data2_uni(:, tr) = allDataUnipolar{tr}(elec2Idx, :);
    end
    phaseDiffs_uni = computePhaseDifference(data1_uni, data2_uni, targetFreq, params);
    
    % ===== AVERAGE REFERENCE =====
    data1_avg = zeros(length(signalIdx), numTrials);
    data2_avg = zeros(length(signalIdx), numTrials);
    for tr = 1:numTrials
        data1_avg(:, tr) = allDataAvgRef{tr}(elec1Idx, :);
        data2_avg(:, tr) = allDataAvgRef{tr}(elec2Idx, :);
    end
    phaseDiffs_avg = computePhaseDifference(data1_avg, data2_avg, targetFreq, params);
    
    % Create comparison plot
    titleStr = sprintf('%s - %s at %.0f Hz', elec1Name, elec2Name, targetFreq);
    savePrefix = sprintf('Q2a_%s_%s_%.0fHz_comparison', elec1Name, elec2Name, targetFreq);
    
    plotComparisonRosePlot(phaseDiffs_uni, phaseDiffs_avg, titleStr, savePrefix, outputDir);
end

fprintf('\nQuestion 2(a) complete.\n');

%% ========================================================================
%  QUESTION 2(b): Compare Electrode Groups
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 2(b): Comparing Q1(b) results\n');
fprintf('========================================\n');

% Create chanlocs structure
fprintf('Creating chanlocs structure...\n');
chanlocs = struct();
for i = 1:length(elec_labels)
    chanlocs(i).labels = elec_labels{i};
    x = chanpos(i, 1);
    y = chanpos(i, 2);
    z = chanpos(i, 3);
    r = sqrt(x^2 + y^2 + z^2);
    theta = atan2(y, x);
    phi = asin(z / r);
    chanlocs(i).sph_theta = rad2deg(theta);
    chanlocs(i).sph_phi = rad2deg(phi);
    chanlocs(i).sph_radius = r;
end
save('temp_chanlocs.mat', 'chanlocs');

% Get electrode groups
seedElectrode = 'Oz';
seedIdx = findElectrodeIndex(labels, seedElectrode);
fprintf('Grouping electrodes by angular distance from seed: %s\n', seedElectrode);

[electrodeGroupList, groupNameList, ~, ~] = ...
    getElectrodeGroupsConn('rel', seedIdx, 'temp_chanlocs');

fprintf('Electrode groups created: %d groups\n', length(groupNameList));

% Process each group
for groupIdx = 1:6
    fprintf('  Processing group %d/%d: %s\n', groupIdx, 6, groupNameList{groupIdx});
    
    groupElectrodes = electrodeGroupList{1, groupIdx};
    
    % ===== UNIPOLAR REFERENCE =====
    groupPhaseDiffs_uni = [];
    for i = 1:length(groupElectrodes)
        elecIdx = groupElectrodes(i);
        dataSeed = zeros(length(signalIdx), numTrials);
        dataElec = zeros(length(signalIdx), numTrials);
        for tr = 1:numTrials
            dataSeed(:, tr) = allDataUnipolar{tr}(seedIdx, :);
            dataElec(:, tr) = allDataUnipolar{tr}(elecIdx, :);
        end
        phaseDiffs = computePhaseDifference(dataSeed, dataElec, targetFreq, params);
        groupPhaseDiffs_uni = [groupPhaseDiffs_uni, phaseDiffs];
    end
    
    % ===== AVERAGE REFERENCE =====
    groupPhaseDiffs_avg = [];
    for i = 1:length(groupElectrodes)
        elecIdx = groupElectrodes(i);
        dataSeed = zeros(length(signalIdx), numTrials);
        dataElec = zeros(length(signalIdx), numTrials);
        for tr = 1:numTrials
            dataSeed(:, tr) = allDataAvgRef{tr}(seedIdx, :);
            dataElec(:, tr) = allDataAvgRef{tr}(elecIdx, :);
        end
        phaseDiffs = computePhaseDifference(dataSeed, dataElec, targetFreq, params);
        groupPhaseDiffs_avg = [groupPhaseDiffs_avg, phaseDiffs];
    end
    
    % Create comparison plot
    titleStr = sprintf('Group %d: %s at %.0f Hz', groupIdx, groupNameList{groupIdx}, targetFreq);
    savePrefix = sprintf('Q2b_Group%d_comparison', groupIdx);
    
    plotComparisonRosePlot(groupPhaseDiffs_uni, groupPhaseDiffs_avg, titleStr, savePrefix, outputDir);
end

fprintf('\nQuestion 2(b) complete.\n');

%% ========================================================================
%  QUESTION 2(c): Compare Multi-Seed with Frequency Pooling
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 2(c): Comparing Q1(c) results\n');
fprintf('========================================\n');

seedElectrodes = {'Oz', 'POz', 'O1', 'O2'};
freqRange = [20, 32];
freqStep = 1;

fprintf('Using %d seed electrodes: %s\n', length(seedElectrodes), strjoin(seedElectrodes, ', '));
fprintf('Frequency range: %.0f - %.0f Hz\n', freqRange(1), freqRange(2));

seedIndices = zeros(1, length(seedElectrodes));
for i = 1:length(seedElectrodes)
    seedIndices(i) = findElectrodeIndex(labels, seedElectrodes{i});
end

[electrodeGroupList_multi, groupNameList_multi, ~, ~] = ...
    getElectrodeGroupsConn('rel', seedIndices(1), 'temp_chanlocs');

% Process each group
for groupIdx = 1:6
    fprintf('  Processing group %d/%d: %s\n', groupIdx, 6, groupNameList_multi{groupIdx});
    
    groupElectrodes = electrodeGroupList_multi{1, groupIdx};
    
    % ===== UNIPOLAR REFERENCE =====
    groupPhaseDiffs_uni = [];
    for seedIdx_multi = seedIndices
        for i = 1:length(groupElectrodes)
            elecIdx = groupElectrodes(i);
            for freq = freqRange(1):freqStep:freqRange(2)
                dataSeed = zeros(length(signalIdx), numTrials);
                dataElec = zeros(length(signalIdx), numTrials);
                for tr = 1:numTrials
                    dataSeed(:, tr) = allDataUnipolar{tr}(seedIdx_multi, :);
                    dataElec(:, tr) = allDataUnipolar{tr}(elecIdx, :);
                end
                phaseDiffs = computePhaseDifference(dataSeed, dataElec, freq, params);
                groupPhaseDiffs_uni = [groupPhaseDiffs_uni, phaseDiffs];
            end
        end
    end
    
    % ===== AVERAGE REFERENCE =====
    groupPhaseDiffs_avg = [];
    for seedIdx_multi = seedIndices
        for i = 1:length(groupElectrodes)
            elecIdx = groupElectrodes(i);
            for freq = freqRange(1):freqStep:freqRange(2)
                dataSeed = zeros(length(signalIdx), numTrials);
                dataElec = zeros(length(signalIdx), numTrials);
                for tr = 1:numTrials
                    dataSeed(:, tr) = allDataAvgRef{tr}(seedIdx_multi, :);
                    dataElec(:, tr) = allDataAvgRef{tr}(elecIdx, :);
                end
                phaseDiffs = computePhaseDifference(dataSeed, dataElec, freq, params);
                groupPhaseDiffs_avg = [groupPhaseDiffs_avg, phaseDiffs];
            end
        end
    end
    
    % Create comparison plot
    titleStr = sprintf('Group %d: %s, Seeds: %s, Freq: %.0f-%.0f Hz', ...
        groupIdx, groupNameList_multi{groupIdx}, strjoin(seedElectrodes, ', '), freqRange(1), freqRange(2));
    savePrefix = sprintf('Q2c_Group%d_comparison', groupIdx);
    
    plotComparisonRosePlot(groupPhaseDiffs_uni, groupPhaseDiffs_avg, titleStr, savePrefix, outputDir);
end

fprintf('\nQuestion 2(c) complete.\n');

%% ========================================================================
%  SUMMARY
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 2 ANALYSIS COMPLETE\n');
fprintf('========================================\n');
fprintf('All comparison plots saved to: %s\n', outputDir);
fprintf('  Question 2(a): 3 comparison plots (Oz-P4, Oz-C3, Oz-AF4)\n');
fprintf('  Question 2(b): 6 comparison plots (6 electrode groups)\n');
fprintf('  Question 2(c): 6 comparison plots (multi-seed)\n');
fprintf('Total plots: 15 (each in .png and .fig format)\n');

% Clean up
if exist('temp_chanlocs.mat', 'file')
    delete('temp_chanlocs.mat');
end

fprintf('\nKey Findings (based on Shirhatti et al., 2016):\n');
fprintf('- Average referencing shifts mean phase difference from 0° to 180°\n');
fprintf('- Phase coherence decreases with average referencing\n');
fprintf('- Phase distributions become more circular (less coherent)\n');
fprintf('- Effect is stronger at low frequencies where coherence is high\n');

fprintf('\nScript execution complete!\n');

%% ========================================================================
%  LOCAL HELPER FUNCTIONS
%  ========================================================================

function idx = findElectrodeIndex(labels, elecName)
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
    N = size(data, 1);
    tapers = dpss(N, params.tapers(1), params.tapers(2));
    tapers = tapers * sqrt(params.Fs);
    
    nfft = max(2^(nextpow2(N) + params.pad), N);
    J = mtfftc(data, tapers, nfft, params.Fs);
    
    if mod(nfft, 2) == 0
        f = (0:nfft/2) * params.Fs / nfft;
    else
        f = (0:(nfft-1)/2) * params.Fs / nfft;
    end
    
    [~, freqIdx] = min(abs(f - targetFreq));
    J_targetFreq = squeeze(J(freqIdx, :, :));
    J_avg = mean(J_targetFreq, 1);
    phases = angle(J_avg);
end

function phaseDiffs = computePhaseDifference(data1, data2, targetFreq, params)
    phase1 = computePhaseAtFrequency(data1, targetFreq, params);
    phase2 = computePhaseAtFrequency(data2, targetFreq, params);
    phaseDiffs = phase1 - phase2;
end

function plotComparisonRosePlot(phaseDiffs_uni, phaseDiffs_avg, titleStr, savePrefix, outputDir)
    % Create side-by-side comparison rose plots
    
    figure('Position', [100, 100, 1600, 700]);
    
    % ===== LEFT PANEL: UNIPOLAR REFERENCE =====
    subplot(1, 2, 1);
    polarhistogram(phaseDiffs_uni, 36, 'FaceColor', [0.3 0.6 0.9], 'FaceAlpha', 0.7);
    hold on;
    
    % Compute and plot average vector
    complexVec_uni = exp(1i * phaseDiffs_uni);
    meanComplexVec_uni = mean(complexVec_uni);
    avgMagnitude_uni = abs(meanComplexVec_uni);
    avgPhase_uni = angle(meanComplexVec_uni);
    
    ax = gca;
    maxR = max(ax.RLim);
    polarplot([0 avgPhase_uni], [0 avgMagnitude_uni * maxR * 0.8], 'r-', 'LineWidth', 3);
    
    title('Unipolar Reference', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Add statistics text
    dim1 = [0.05 0.15 0.3 0.1];
    str1 = sprintf('Mean: %.2f rad (%.1f°)\nMRL: %.3f', ...
        avgPhase_uni, rad2deg(avgPhase_uni), avgMagnitude_uni);
    annotation('textbox', dim1, 'String', str1, 'FitBoxToText', 'on', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 9);
    
    hold off;
    
    % ===== RIGHT PANEL: AVERAGE REFERENCE =====
    subplot(1, 2, 2);
    polarhistogram(phaseDiffs_avg, 36, 'FaceColor', [0.9 0.4 0.4], 'FaceAlpha', 0.7);
    hold on;
    
    % Compute and plot average vector
    complexVec_avg = exp(1i * phaseDiffs_avg);
    meanComplexVec_avg = mean(complexVec_avg);
    avgMagnitude_avg = abs(meanComplexVec_avg);
    avgPhase_avg = angle(meanComplexVec_avg);
    
    ax = gca;
    maxR = max(ax.RLim);
    polarplot([0 avgPhase_avg], [0 avgMagnitude_avg * maxR * 0.8], 'r-', 'LineWidth', 3);
    
    title('Average Reference', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Add statistics text
    dim2 = [0.55 0.15 0.3 0.1];
    str2 = sprintf('Mean: %.2f rad (%.1f°)\nMRL: %.3f', ...
        avgPhase_avg, rad2deg(avgPhase_avg), avgMagnitude_avg);
    annotation('textbox', dim2, 'String', str2, 'FitBoxToText', 'on', ...
        'BackgroundColor', 'white', 'EdgeColor', 'black', 'FontSize', 9);
    
    hold off;
    
    % Add overall title
    sgtitle(titleStr, 'FontSize', 14, 'FontWeight', 'bold');
    
    % Add comparison text at the bottom
    phaseDiff_change = rad2deg(avgPhase_avg - avgPhase_uni);
    coherence_change = avgMagnitude_avg - avgMagnitude_uni;
    
    dim3 = [0.3 0.02 0.4 0.08];
    str3 = sprintf('Phase shift: %.1f° | Coherence change: %.3f', ...
        phaseDiff_change, coherence_change);
    annotation('textbox', dim3, 'String', str3, 'FitBoxToText', 'on', ...
        'BackgroundColor', [1 1 0.8], 'EdgeColor', 'black', ...
        'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    
    % Save figure
    saveas(gcf, fullfile(outputDir, [savePrefix '.png']));
    saveas(gcf, fullfile(outputDir, [savePrefix '.fig']));
    
    fprintf('  Saved: %s (Phase shift: %.1f°, MRL change: %.3f)\n', ...
        savePrefix, phaseDiff_change, coherence_change);
end
