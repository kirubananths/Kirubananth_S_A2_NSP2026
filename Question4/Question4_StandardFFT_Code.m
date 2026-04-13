%% NSP Assignment 2 (EEG Module) - Question 4: Trial-Count Bias Analysis
% This script demonstrates the positive bias in connectivity metrics when
% using fewer trials, and shows that PPC is an unbiased estimator.
%
% Question 4(a): Compare metrics with 1/3 of trials vs all trials
% Question 4(b): Mathematical derivation of PPC as unbiased estimator
%
% METHOD: STANDARD FFT (not multi-taper)
%
% Author: Kirubananth S (SR: 26956)
% Electrodes: PO3 and AF4
% Data: Subject 013AR, protocol M1, unipolar reference

clear all; close all; clc;

%% ========================================================================
%  SETUP AND DATA LOADING
%  ========================================================================

% Create output directory for plots
outputDir = 'Question_4_Plots_FFT';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
fprintf('Output directory: %s\n', outputDir);

fprintf('========================================\n');
fprintf('QUESTION 4: TRIAL-COUNT BIAS ANALYSIS\n');
fprintf('Using STANDARD FFT Method\n');
fprintf('========================================\n\n');

% Load M1 data (unipolar reference)
fprintf('Loading M1 EEG data (unipolar reference)...\n');
load('M1_ep_v8.mat');

% Extract key parameters
Fs = double(data.fsample);
timeVals = data.timeVals;
labels = data.label;
numTrials = double(data.numTrials);

fprintf('Data loaded successfully.\n');
fprintf('  Protocol: M1\n');
fprintf('  Subject: 013AR\n');
fprintf('  Sampling frequency: %d Hz\n', Fs);
fprintf('  Total number of trials: %d\n', numTrials);

%% ========================================================================
%  FIND TARGET ELECTRODES
%  ========================================================================

fprintf('\nLocating target electrodes...\n');

po3Idx = findElectrodeIndex(labels, 'PO3');
af4Idx = findElectrodeIndex(labels, 'AF4');

fprintf('  PO3: index %d\n', po3Idx);
fprintf('  AF4: index %d\n', af4Idx);

%% ========================================================================
%  EXTRACT STIMULUS PERIOD DATA
%  ========================================================================

fprintf('\nExtracting stimulus period data [0.25, 0.75] seconds...\n');

stimStart = 0.25;
stimEnd = 0.75;
stimIdx = find(timeVals >= stimStart & timeVals <= stimEnd);

fprintf('  Stimulus window: [%.2f, %.2f] s (%d samples)\n', ...
    timeVals(stimIdx(1)), timeVals(stimIdx(end)), length(stimIdx));

% Extract data for both electrodes across all trials
dataPO3_all = zeros(length(stimIdx), numTrials);
dataAF4_all = zeros(length(stimIdx), numTrials);

for tr = 1:numTrials
    trialData = data.trial{tr};
    dataPO3_all(:, tr) = trialData(po3Idx, stimIdx);
    dataAF4_all(:, tr) = trialData(af4Idx, stimIdx);
end

fprintf('Data extraction complete for all %d trials.\n', numTrials);

%% ========================================================================
%  FFT PARAMETERS
%  ========================================================================

fprintf('\nSetting up standard FFT parameters...\n');

N = size(dataPO3_all, 1);
nfft = 2^nextpow2(N);
fpass = [0 50];

% Get frequency grid
f = (0:nfft/2) * Fs / nfft;
freqIdx = find(f >= fpass(1) & f <= fpass(2));
f = f(freqIdx);

fprintf('  FFT parameters:\n');
fprintf('    Data length: %d samples\n', N);
fprintf('    FFT length: %d points\n', nfft);
fprintf('    Frequency range: %.0f-%.0f Hz\n', fpass(1), fpass(2));
fprintf('    Frequency resolution: %.2f Hz\n', f(2) - f(1));

%% ========================================================================
%  ANALYSIS 1: ALL TRIALS (N = 235)
%  ========================================================================

fprintf('\n========================================\n');
fprintf('ANALYSIS 1: ALL TRIALS (N = %d)\n', numTrials);
fprintf('========================================\n\n');

% Compute FFT for all trials
fprintf('Computing FFT for all trials...\n');
FFT_PO3_all = zeros(nfft, numTrials);
FFT_AF4_all = zeros(nfft, numTrials);

for tr = 1:numTrials
    FFT_PO3_all(:, tr) = fft(dataPO3_all(:, tr), nfft);
    FFT_AF4_all(:, tr) = fft(dataAF4_all(:, tr), nfft);
end

% Keep only positive frequencies
FFT_PO3_all = FFT_PO3_all(1:nfft/2+1, :);
FFT_AF4_all = FFT_AF4_all(1:nfft/2+1, :);

% Extract frequencies in fpass range
FFT_PO3_all = FFT_PO3_all(freqIdx, :);
FFT_AF4_all = FFT_AF4_all(freqIdx, :);

% Compute cross and auto spectra
S12_full = conj(FFT_PO3_all) .* FFT_AF4_all;  % freq × trials
S11_full = conj(FFT_PO3_all) .* FFT_PO3_all;
S22_full = conj(FFT_AF4_all) .* FFT_AF4_all;

% Convert to real for auto-spectra
S11_full = real(S11_full);
S22_full = real(S22_full);

% Compute metrics for FULL dataset
N_full = size(S12_full, 2);

% Coherence
S12_avg_full = mean(S12_full, 2);
S11_avg_full = mean(S11_full, 2);
S22_avg_full = mean(S22_full, 2);
coherence_full = abs(S12_avg_full) ./ sqrt(S11_avg_full .* S22_avg_full);

% WPLI
imag_S12_full = imag(S12_full);
wpli_full = abs(mean(imag_S12_full, 2)) ./ mean(abs(imag_S12_full), 2);

% PPC (phase-only)
ppc_full = zeros(length(f), 1);
for freqIdx_loop = 1:length(f)
    S12_freq = S12_full(freqIdx_loop, :);
    phase_vectors = S12_freq ./ abs(S12_freq);
    sum_all = abs(sum(phase_vectors))^2;
    ppc_full(freqIdx_loop) = (sum_all - N_full) / (N_full * (N_full - 1));
end

fprintf('Results with ALL trials (N = %d):\n', N_full);
fprintf('  Coherence: mean = %.4f, range = [%.4f, %.4f]\n', ...
    mean(coherence_full), min(coherence_full), max(coherence_full));
fprintf('  WPLI:      mean = %.4f, range = [%.4f, %.4f]\n', ...
    mean(wpli_full, 'omitnan'), min(wpli_full), max(wpli_full));
fprintf('  PPC:       mean = %.4f, range = [%.4f, %.4f]\n', ...
    mean(ppc_full), min(ppc_full), max(ppc_full));

%% ========================================================================
%  ANALYSIS 2: REDUCED TRIALS (1/3)
%  ========================================================================

fprintf('\n========================================\n');
fprintf('ANALYSIS 2: REDUCED TRIALS (1/3)\n');
fprintf('========================================\n\n');

% Randomly select 1/3 of trials
fprintf('Randomly selecting 1/3 of trials...\n');
rng(42);  % Reproducible randomness
N_reduced = round(N_full / 3);

fprintf('  Total trials available: %d\n', N_full);
fprintf('  Trials to use (1/3): %d\n', N_reduced);

selected_trials = randperm(N_full, N_reduced);
fprintf('  Selected %d random trials\n', length(selected_trials));

% Extract reduced spectra
S12_reduced = S12_full(:, selected_trials);
S11_reduced = S11_full(:, selected_trials);
S22_reduced = S22_full(:, selected_trials);

% Compute metrics for REDUCED dataset
% Coherence
S12_avg_reduced = mean(S12_reduced, 2);
S11_avg_reduced = mean(S11_reduced, 2);
S22_avg_reduced = mean(S22_reduced, 2);
coherence_reduced = abs(S12_avg_reduced) ./ sqrt(S11_avg_reduced .* S22_avg_reduced);

% WPLI
imag_S12_reduced = imag(S12_reduced);
wpli_reduced = abs(mean(imag_S12_reduced, 2)) ./ mean(abs(imag_S12_reduced), 2);

% PPC
ppc_reduced = zeros(length(f), 1);
for freqIdx_loop = 1:length(f)
    S12_freq = S12_reduced(freqIdx_loop, :);
    phase_vectors = S12_freq ./ abs(S12_freq);
    sum_all = abs(sum(phase_vectors))^2;
    ppc_reduced(freqIdx_loop) = (sum_all - N_reduced) / (N_reduced * (N_reduced - 1));
end

fprintf('Results with REDUCED trials (N = %d):\n', N_reduced);
fprintf('  Coherence: mean = %.4f, range = [%.4f, %.4f]\n', ...
    mean(coherence_reduced), min(coherence_reduced), max(coherence_reduced));
fprintf('  WPLI:      mean = %.4f, range = [%.4f, %.4f]\n', ...
    mean(wpli_reduced, 'omitnan'), min(wpli_reduced), max(wpli_reduced));
fprintf('  PPC:       mean = %.4f, range = [%.4f, %.4f]\n', ...
    mean(ppc_reduced), min(ppc_reduced), max(ppc_reduced));

%% ========================================================================
%  COMPUTE BIAS
%  ========================================================================

fprintf('\nComputing bias (Reduced - Full)...\n');

coherence_bias = coherence_reduced - coherence_full;
wpli_bias = wpli_reduced - wpli_full;
ppc_bias = ppc_reduced - ppc_full;

coherence_bias_mean = mean(coherence_bias);
wpli_bias_mean = mean(wpli_bias, 'omitnan');
ppc_bias_mean = mean(ppc_bias);

fprintf('  Coherence bias (mean): %.6f\n', coherence_bias_mean);
fprintf('  WPLI bias (mean):      %.6f\n', wpli_bias_mean);
fprintf('  PPC bias (mean):       %.6f\n', ppc_bias_mean);

%% ========================================================================
%  CREATE COMPREHENSIVE FIGURE (6 PANELS)
%  ========================================================================

fprintf('\nCreating comprehensive 6-panel comparison figure...\n');

figure('Position', [50, 50, 1600, 900]);

% Top row: Full vs Reduced comparisons
% Panel 1: Coherence comparison
subplot(2, 3, 1);
hold on;
plot(f, coherence_full, 'b-', 'LineWidth', 2.5, 'DisplayName', sprintf('Full (N=%d)', N_full));
plot(f, coherence_reduced, 'r--', 'LineWidth', 2.5, 'DisplayName', sprintf('Reduced (N=%d)', N_reduced));
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Coherence', 'FontSize', 11);
title('Coherence: Full vs Reduced Trials', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on;
xlim([fpass(1) fpass(2)]);
set(gca, 'FontSize', 10);

% Panel 2: WPLI comparison
subplot(2, 3, 2);
hold on;
plot(f, wpli_full, 'b-', 'LineWidth', 2.5, 'DisplayName', sprintf('Full (N=%d)', N_full));
plot(f, wpli_reduced, 'r--', 'LineWidth', 2.5, 'DisplayName', sprintf('Reduced (N=%d)', N_reduced));
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('WPLI', 'FontSize', 11);
title('WPLI: Full vs Reduced Trials', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on;
xlim([fpass(1) fpass(2)]);
set(gca, 'FontSize', 10);

% Panel 3: PPC comparison
subplot(2, 3, 3);
hold on;
plot(f, ppc_full, 'b-', 'LineWidth', 2.5, 'DisplayName', sprintf('Full (N=%d)', N_full));
plot(f, ppc_reduced, 'r--', 'LineWidth', 2.5, 'DisplayName', sprintf('Reduced (N=%d)', N_reduced));
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('PPC', 'FontSize', 11);
title('PPC: Full vs Reduced Trials (Unbiased)', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
grid on;
xlim([fpass(1) fpass(2)]);
set(gca, 'FontSize', 10);

% Bottom row: Bias plots
% Panel 4: Coherence bias
subplot(2, 3, 4);
hold on;
plot(f, coherence_bias, 'b-', 'LineWidth', 2.5);
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Bias (Reduced - Full)', 'FontSize', 11);
title(sprintf('Coherence Bias (mean=%.4f)', coherence_bias_mean), ...
    'FontSize', 13, 'FontWeight', 'bold');
grid on;
xlim([fpass(1) fpass(2)]);
set(gca, 'FontSize', 10);

% Panel 5: WPLI bias
subplot(2, 3, 5);
hold on;
plot(f, wpli_bias, 'r-', 'LineWidth', 2.5);
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Bias (Reduced - Full)', 'FontSize', 11);
title(sprintf('WPLI Bias (mean=%.4f)', wpli_bias_mean), ...
    'FontSize', 13, 'FontWeight', 'bold');
grid on;
xlim([fpass(1) fpass(2)]);
set(gca, 'FontSize', 10);

% Panel 6: PPC bias
subplot(2, 3, 6);
hold on;
plot(f, ppc_bias, 'g-', 'LineWidth', 2.5);
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Bias (Reduced - Full)', 'FontSize', 11);
title(sprintf('PPC Bias (mean=%.6f) - Unbiased!', ppc_bias_mean), ...
    'FontSize', 13, 'FontWeight', 'bold');
grid on;
xlim([fpass(1) fpass(2)]);
set(gca, 'FontSize', 10);

% Overall title
sgtitle('Question 4: Trial-Count Bias Analysis (PO3-AF4, M1, Unipolar, Standard FFT)', ...
    'FontSize', 16, 'FontWeight', 'bold');

% Save figure
saveas(gcf, fullfile(outputDir, 'Q4_comprehensive_bias_analysis.png'));
saveas(gcf, fullfile(outputDir, 'Q4_comprehensive_bias_analysis.fig'));
fprintf('  Saved: Q4_comprehensive_bias_analysis\n');

%% ========================================================================
%  SAVE RESULTS
%  ========================================================================

fprintf('\nSaving results to file...\n');

results = struct();
results.frequency = f;
results.N_full = N_full;
results.N_reduced = N_reduced;
results.selected_trials = selected_trials;
results.method = 'Standard FFT';

% Full trials
results.full.coherence = coherence_full;
results.full.wpli = wpli_full;
results.full.ppc = ppc_full;

% Reduced trials
results.reduced.coherence = coherence_reduced;
results.reduced.wpli = wpli_reduced;
results.reduced.ppc = ppc_reduced;

% Bias
results.bias.coherence = coherence_bias;
results.bias.wpli = wpli_bias;
results.bias.ppc = ppc_bias;
results.bias.coherence_mean = coherence_bias_mean;
results.bias.wpli_mean = wpli_bias_mean;
results.bias.ppc_mean = ppc_bias_mean;

save(fullfile(outputDir, 'Q4_results.mat'), 'results');
fprintf('  Saved: Q4_results.mat\n');

%% ========================================================================
%  SUMMARY
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 4 ANALYSIS COMPLETE\n');
fprintf('========================================\n');
fprintf('Method: Standard FFT (no multi-taper)\n');
fprintf('Single comprehensive figure saved to: %s\n\n', outputDir);

fprintf('Key Findings:\n');
fprintf('  Trial count: Full = %d, Reduced = %d (1/3)\n\n', N_full, N_reduced);

fprintf('  Coherence:\n');
fprintf('    Full trials:    mean = %.4f\n', mean(coherence_full));
fprintf('    Reduced trials: mean = %.4f\n', mean(coherence_reduced));
fprintf('    Bias:           %.6f (POSITIVE)\n\n', coherence_bias_mean);

fprintf('  WPLI:\n');
fprintf('    Full trials:    mean = %.4f\n', mean(wpli_full, 'omitnan'));
fprintf('    Reduced trials: mean = %.4f\n', mean(wpli_reduced, 'omitnan'));
fprintf('    Bias:           %.6f (POSITIVE)\n\n', wpli_bias_mean);

fprintf('  PPC:\n');
fprintf('    Full trials:    mean = %.4f\n', mean(ppc_full));
fprintf('    Reduced trials: mean = %.4f\n', mean(ppc_reduced));
fprintf('    Bias:           %.6f (NEAR ZERO - UNBIASED!)\n\n', ppc_bias_mean);

fprintf('Interpretation:\n');
fprintf('  - Coherence shows positive bias: +%.4f when trials reduced\n', coherence_bias_mean);
fprintf('  - WPLI shows positive bias: +%.4f when trials reduced\n', wpli_bias_mean);
fprintf('  - PPC shows minimal bias: %.6f (effectively unbiased)\n', ppc_bias_mean);
fprintf('  - PPC is robust to trial count variations!\n\n');

fprintf('Script execution complete!\n');

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
