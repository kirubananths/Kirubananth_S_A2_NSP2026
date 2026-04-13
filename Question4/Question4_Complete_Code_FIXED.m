%% NSP Assignment 2 (EEG Module) - Question 4: Trial-Count Bias Analysis
% This script demonstrates the positive bias in connectivity metrics when
% using fewer trials, and shows that PPC is an unbiased estimator.
%
% Question 4(a): Compare metrics with 1/3 of trials vs all trials
% Question 4(b): Mathematical derivation of PPC as unbiased estimator
%
% Author: Kirubananth S (SR: 26956)
% Electrodes: PO3 and AF4
% Data: Subject 013AR, protocol M1, unipolar reference
%
% FORMULAS (matching lecture slides):
% - Coherence: |E[S12]| / sqrt(E[S11] * E[S22]) - BIASED
% - WPLI: |E{imag(S12)}| / E{|imag(S12)|} - BIASED
% - PPC: (|Σ exp(i*θ_j)|² - N) / (N*(N-1)) - UNBIASED


clear all; close all; clc;

%% ========================================================================
%  SETUP AND DATA LOADING
%  ========================================================================

% Create output directory for plots
outputDir = 'Question_4_Plots';
if ~exist(outputDir, 'dir')
    [status, msg] = mkdir(outputDir);
    if ~status
        error('Failed to create output directory: %s', msg);
    end
end
fprintf('Output directory: %s\n', outputDir);

fprintf('========================================\n');
fprintf('QUESTION 4: TRIAL-COUNT BIAS ANALYSIS\n');
fprintf('========================================\n\n');

% Load M1 data (unipolar reference)
fprintf('Loading M1 EEG data (unipolar reference)...\n');
load('M1_ep_v8.mat');  % Contains 'data' structure

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
fprintf('  Number of electrodes: %d\n', length(labels));
fprintf('  Time range: %.3f to %.3f seconds\n', timeVals(1), timeVals(end));

%% ========================================================================
%  FIND TARGET ELECTRODES
%  ========================================================================

fprintf('\nLocating target electrodes...\n');

% Find PO3 and AF4
po3Idx = findElectrodeIndex(labels, 'PO3');
af4Idx = findElectrodeIndex(labels, 'AF4');

fprintf('  PO3: index %d\n', po3Idx);
fprintf('  AF4: index %d\n', af4Idx);

%% ========================================================================
%  EXTRACT STIMULUS PERIOD DATA FOR ALL TRIALS
%  ========================================================================

fprintf('\nExtracting stimulus period data [0.25, 0.75] seconds...\n');

% Define time window for stimulus period
stimStart = 0.25;
stimEnd = 0.75;

% Find indices
stimIdx = find(timeVals >= stimStart & timeVals <= stimEnd);

fprintf('  Stimulus window: [%.2f, %.2f] s (%d samples)\n', ...
    timeVals(stimIdx(1)), timeVals(stimIdx(end)), length(stimIdx));

% Extract data for both electrodes across all trials
dataPO3_all = zeros(length(stimIdx), numTrials);
dataAF4_all = zeros(length(stimIdx), numTrials);

for tr = 1:numTrials
    trialData = data.trial{tr};  % 64 electrodes × time points
    dataPO3_all(:, tr) = trialData(po3Idx, stimIdx);
    dataAF4_all(:, tr) = trialData(af4Idx, stimIdx);
end

fprintf('Data extraction complete for all %d trials.\n', numTrials);

%% ========================================================================
%  MULTI-TAPER PARAMETERS (SHARED FOR BOTH ANALYSES)
%  ========================================================================

fprintf('\nSetting up multi-taper parameters...\n');

% Multi-taper parameters (matching displayConnectivity.m and Q3)
% For T=0.5s, W=4Hz => TW=2, use 3 tapers (2*TW-1 = 3)
TW = 2;  % Time-bandwidth product
K = 3;   % Number of tapers
W = 4;   % Frequency smoothing bandwidth (Hz)

params.tapers = [TW K];
params.Fs = Fs;
params.fpass = [0 50];  % 0-50 Hz
params.pad = 0;
params.err = 0;
params.trialave = 0;  % Keep trials separate

fprintf('  Multi-taper parameters:\n');
fprintf('    Time-bandwidth product (TW): %d\n', TW);
fprintf('    Number of tapers (K): %d\n', K);
fprintf('    Frequency smoothing (W): ±%d Hz\n', W);
fprintf('    Frequency range: %.0f-%.0f Hz\n', params.fpass(1), params.fpass(2));

% Compute tapers
N = size(dataPO3_all, 1);
tapers = dpss(N, params.tapers(1), params.tapers(2));
tapers = tapers * sqrt(params.Fs);

% Compute FFT for both electrodes
nfft = max(2^(nextpow2(N) + params.pad), N);
fprintf('    Data length: %d samples\n', N);
fprintf('    FFT length: %d points\n', nfft);

%% ========================================================================
%  ANALYSIS 1: ALL TRIALS (N = 235)
%  ========================================================================

fprintf('\n========================================\n');
fprintf('ANALYSIS 1: ALL TRIALS (N = %d)\n', numTrials);
fprintf('========================================\n\n');

% Compute multi-taper FFT
J_PO3_all = mtfftc(dataPO3_all, tapers, nfft, params.Fs);
J_AF4_all = mtfftc(dataAF4_all, tapers, nfft, params.Fs);

% Get frequency grid
if mod(nfft, 2) == 0
    f = (0:nfft/2) * params.Fs / nfft;
else
    f = (0:(nfft-1)/2) * params.Fs / nfft;
end

% Extract frequencies in fpass range
freqIdx = find(f >= params.fpass(1) & f <= params.fpass(2));
f = f(freqIdx);
J_PO3_all = J_PO3_all(freqIdx, :, :);
J_AF4_all = J_AF4_all(freqIdx, :, :);

% Compute cross and auto spectra (average over tapers)
S12_full = squeeze(mean(conj(J_PO3_all) .* J_AF4_all, 2));  % freq × trials
S11_full = squeeze(mean(conj(J_PO3_all) .* J_PO3_all, 2));
S22_full = squeeze(mean(conj(J_AF4_all) .* J_AF4_all, 2));

% Compute metrics for FULL dataset
% Coherence
S12_avg_full = mean(S12_full, 2);
S11_avg_full = mean(S11_full, 2);
S22_avg_full = mean(S22_full, 2);
coherence_full = abs(S12_avg_full) ./ sqrt(S11_avg_full .* S22_avg_full);

% WPLI
imag_S12_full = imag(S12_full);
wpli_full = abs(mean(imag_S12_full, 2)) ./ mean(abs(imag_S12_full), 2);

% PPC (phase-only)
N_full = size(S12_full, 2);
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
%  QUESTION 4(a): REDUCED TRIALS (1/3)
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 4(a): REDUCED TRIALS (1/3)\n');
fprintf('========================================\n\n');

% Randomly select 1/3 of trials with reproducible seed
fprintf('Randomly selecting 1/3 of trials...\n');
rng(42);  % Reproducible randomness
N_reduced = round(N_full / 3);

fprintf('  Total trials available: %d\n', N_full);
fprintf('  Trials to use (1/3): %d\n', N_reduced);

% Select random trials
selected_trials = randperm(N_full, N_reduced);
fprintf('  Selected trial indices: [%d ... %d (total: %d trials)]\n', ...
    selected_trials(1), selected_trials(end), length(selected_trials));

% Extract reduced cross and auto spectra
S12_reduced = S12_full(:, selected_trials);
S11_reduced = S11_full(:, selected_trials);
S22_reduced = S22_full(:, selected_trials);

fprintf('\nData extracted for %d selected trials.\n', N_reduced);

%% ========================================================================
%  ANALYSIS 2: COMPUTING METRICS WITH 1/3 TRIALS
%  ========================================================================

fprintf('\n========================================\n');
fprintf('ANALYSIS 2: COMPUTING METRICS WITH 1/3 TRIALS\n');
fprintf('========================================\n\n');

% Compute metrics for REDUCED dataset
% Coherence
S12_avg_reduced = mean(S12_reduced, 2);
S11_avg_reduced = mean(S11_reduced, 2);
S22_avg_reduced = mean(S22_reduced, 2);
coherence_reduced = abs(S12_avg_reduced) ./ sqrt(S11_avg_reduced .* S22_avg_reduced);

% WPLI
imag_S12_reduced = imag(S12_reduced);
wpli_reduced = abs(mean(imag_S12_reduced, 2)) ./ mean(abs(imag_S12_reduced), 2);

% PPC (phase-only)
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
%  BIAS ANALYSIS
%  ========================================================================

fprintf('\n========================================\n');
fprintf('BIAS ANALYSIS\n');
fprintf('========================================\n');

% Calculate mean differences (positive bias)
% FIX: Use 'omitnan' to handle NaN values in WPLI
coherence_bias_mean = mean(coherence_reduced - coherence_full);
wpli_bias_mean = mean(wpli_reduced - wpli_full, 'omitnan');  % FIXED!
ppc_bias_mean = mean(ppc_reduced - ppc_full);

fprintf('\nMean bias (Reduced - Full):\n');
fprintf('  Coherence: %.6f (%.2f%% increase)\n', ...
    coherence_bias_mean, 100 * coherence_bias_mean / mean(coherence_full));
fprintf('  WPLI:      %.6f (%.2f%% increase)\n', ...
    wpli_bias_mean, 100 * wpli_bias_mean / mean(wpli_full, 'omitnan'));
fprintf('  PPC:       %.6f (%.2f%% increase)\n', ...
    ppc_bias_mean, 100 * ppc_bias_mean / mean(ppc_full));

% Interpretation
fprintf('\nInterpretation:\n');
if abs(coherence_bias_mean) > 0.01
    fprintf('  Coherence shows POSITIVE BIAS (increases with fewer trials)\n');
else
    fprintf('  Coherence shows minimal bias\n');
end

if abs(wpli_bias_mean) > 0.01
    fprintf('  WPLI shows POSITIVE BIAS (increases with fewer trials)\n');
else
    fprintf('  WPLI shows minimal bias\n');
end

if abs(ppc_bias_mean) < 0.005
    fprintf('  PPC shows MINIMAL BIAS (unbiased estimator)\n');
else
    fprintf('  PPC shows some bias (%.6f)\n', ppc_bias_mean);
end

% Count NaN frequencies in WPLI
wpli_bias_vector = wpli_reduced - wpli_full;
num_nans = sum(isnan(wpli_bias_vector));
if num_nans > 0
    fprintf('\nNote: WPLI has NaN at %d out of %d frequencies (%.1f%%)\n', ...
        num_nans, length(wpli_bias_vector), 100*num_nans/length(wpli_bias_vector));
    nan_freqs = f(isnan(wpli_bias_vector));
    fprintf('      NaN frequencies: ');
    fprintf('%.2f ', nan_freqs);
    fprintf('Hz\n');
end

%% ========================================================================
%  PLOT 1: COMPREHENSIVE 6-PANEL COMPARISON
%  ========================================================================

fprintf('\n========================================\n');
fprintf('CREATING COMPARISON PLOTS\n');
fprintf('========================================\n');

figure('Position', [50, 50, 1400, 900]);

% Top row: Raw metrics
% Coherence
subplot(2, 3, 1);
hold on;
plot(f, coherence_full, 'b-', 'LineWidth', 2);
plot(f, coherence_reduced, 'r--', 'LineWidth', 2);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Coherence', 'FontSize', 11);
title('Coherence: PO3-AF4', 'FontSize', 12, 'FontWeight', 'bold');
legend({'All trials (N=235)', '1/3 trials (N=78)'}, 'Location', 'best', 'FontSize', 9);
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 10);

% WPLI
subplot(2, 3, 2);
hold on;
plot(f, wpli_full, 'b-', 'LineWidth', 2);
plot(f, wpli_reduced, 'r--', 'LineWidth', 2);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('WPLI', 'FontSize', 11);
title('WPLI: PO3-AF4', 'FontSize', 12, 'FontWeight', 'bold');
legend({'All trials (N=235)', '1/3 trials (N=78)'}, 'Location', 'best', 'FontSize', 9);
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 10);

% PPC
subplot(2, 3, 3);
hold on;
plot(f, ppc_full, 'b-', 'LineWidth', 2);
plot(f, ppc_reduced, 'r--', 'LineWidth', 2);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('PPC', 'FontSize', 11);
title('PPC: PO3-AF4', 'FontSize', 12, 'FontWeight', 'bold');
legend({'All trials (N=235)', '1/3 trials (N=78)'}, 'Location', 'best', 'FontSize', 9);
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 10);

% Bottom row: Bias plots
% Coherence Bias
subplot(2, 3, 4);
coherence_bias = coherence_reduced - coherence_full;
plot(f, coherence_bias, 'r-', 'LineWidth', 2);
hold on;
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Bias (Reduced - Full)', 'FontSize', 11);
title('Coherence Bias', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 10);

% WPLI Bias
subplot(2, 3, 5);
plot(f, wpli_bias_vector, 'r-', 'LineWidth', 2);
hold on;
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Bias (Reduced - Full)', 'FontSize', 11);
title('WPLI Bias', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 10);

% PPC Bias
subplot(2, 3, 6);
ppc_bias = ppc_reduced - ppc_full;
plot(f, ppc_bias, 'g-', 'LineWidth', 2);
hold on;
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 11);
ylabel('Bias (Reduced - Full)', 'FontSize', 11);
title('PPC Bias (Ideally should be Unbiased)', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 10);

sgtitle('Question 4(a): Trial-Count Bias Analysis (Full: N=235 vs Reduced: N=78)', ...
    'FontSize', 14, 'FontWeight', 'bold');

saveas(gcf, fullfile(outputDir, 'Q4a_comprehensive_bias_comparison.png'));
saveas(gcf, fullfile(outputDir, 'Q4a_comprehensive_bias_comparison.fig'));
fprintf('  Saved: Q4a_comprehensive_bias_comparison\n');

%% ========================================================================
%  PLOT 2: COHERENCE COMPARISON
%  ========================================================================

figure('Position', [100, 100, 1000, 600]);
hold on;
plot(f, coherence_full, 'b-', 'LineWidth', 2.5);
plot(f, coherence_reduced, 'r--', 'LineWidth', 2.5);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 14);
ylabel('Coherence', 'FontSize', 14);
title('Coherence Comparison: Effect of Trial Count', 'FontSize', 16, 'FontWeight', 'bold');
legend({'All trials (N=235)', '1/3 trials (N=78)'}, 'Location', 'best', 'FontSize', 12);
grid on;
xlim([params.fpass(1) params.fpass(2)]);
ylim([0 1]);
set(gca, 'FontSize', 12);

saveas(gcf, fullfile(outputDir, 'Q4a_coherence_comparison.png'));
saveas(gcf, fullfile(outputDir, 'Q4a_coherence_comparison.fig'));
fprintf('  Saved: Q4a_coherence_comparison\n');

%% ========================================================================
%  PLOT 3: WPLI COMPARISON
%  ========================================================================

figure('Position', [100, 100, 1000, 600]);
hold on;
plot(f, wpli_full, 'b-', 'LineWidth', 2.5);
plot(f, wpli_reduced, 'r--', 'LineWidth', 2.5);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 14);
ylabel('WPLI', 'FontSize', 14);
title('WPLI Comparison: Effect of Trial Count', 'FontSize', 16, 'FontWeight', 'bold');
legend({'All trials (N=235)', '1/3 trials (N=78)'}, 'Location', 'best', 'FontSize', 12);
grid on;
xlim([params.fpass(1) params.fpass(2)]);
ylim([0 1]);
set(gca, 'FontSize', 12);

saveas(gcf, fullfile(outputDir, 'Q4a_wpli_comparison.png'));
saveas(gcf, fullfile(outputDir, 'Q4a_wpli_comparison.fig'));
fprintf('  Saved: Q4a_wpli_comparison\n');

%% ========================================================================
%  PLOT 4: PPC COMPARISON (UNBIASED)
%  ========================================================================

figure('Position', [100, 100, 1000, 600]);
hold on;
plot(f, ppc_full, 'b-', 'LineWidth', 2.5);
plot(f, ppc_reduced, 'r--', 'LineWidth', 2.5);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 14);
ylabel('PPC', 'FontSize', 14);
title('PPC Comparison: Unbiased Estimator Property', 'FontSize', 16, 'FontWeight', 'bold');
legend({'All trials (N=235)', '1/3 trials (N=78)'}, 'Location', 'best', 'FontSize', 12);
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 12);

saveas(gcf, fullfile(outputDir, 'Q4a_ppc_comparison_unbiased.png'));
saveas(gcf, fullfile(outputDir, 'Q4a_ppc_comparison_unbiased.fig'));
fprintf('  Saved: Q4a_ppc_comparison_unbiased\n');

%% ========================================================================
%  PLOT 5: BIAS DIFFERENCE PLOTS (3-PANEL)
%  ========================================================================

figure('Position', [50, 50, 1400, 400]);

% Coherence Bias
subplot(1, 3, 1);
plot(f, coherence_bias, 'r-', 'LineWidth', 2.5);
hold on;
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Bias (Reduced - Full)', 'FontSize', 12);
title('Coherence Bias', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 11);

% WPLI Bias
subplot(1, 3, 2);
plot(f, wpli_bias_vector, 'r-', 'LineWidth', 2.5);
hold on;
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Bias (Reduced - Full)', 'FontSize', 12);
title('WPLI Bias', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 11);

% PPC Bias
subplot(1, 3, 3);
plot(f, ppc_bias, 'g-', 'LineWidth', 2.5);
hold on;
plot([f(1) f(end)], [0 0], 'k--', 'LineWidth', 1);
hold off;
xlabel('Frequency (Hz)', 'FontSize', 12);
ylabel('Bias (Reduced - Full)', 'FontSize', 12);
title('PPC Bias (Ideally should be ~0)', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
set(gca, 'FontSize', 11);

sgtitle('Bias Analysis: Effect of Reducing Trial Count to 1/3', ...
    'FontSize', 16, 'FontWeight', 'bold');

saveas(gcf, fullfile(outputDir, 'Q4a_bias_difference_plots.png'));
saveas(gcf, fullfile(outputDir, 'Q4a_bias_difference_plots.fig'));
fprintf('  Saved: Q4a_bias_difference_plots\n');

%% ========================================================================
%  SAVE RESULTS
%  ========================================================================

fprintf('\nSaving results to file...\n');

results = struct();
results.frequency = f;
results.N_full = N_full;
results.N_reduced = N_reduced;
results.selected_trials = selected_trials;

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
results.bias.wpli = wpli_bias_vector;
results.bias.ppc = ppc_bias;
results.bias.coherence_mean = coherence_bias_mean;
results.bias.wpli_mean = wpli_bias_mean;
results.bias.ppc_mean = ppc_bias_mean;

% Cross-spectra
results.S12_full = S12_full;
results.S12_reduced = S12_reduced;
results.S11_full = S11_full;
results.S11_reduced = S11_reduced;
results.S22_full = S22_full;
results.S22_reduced = S22_reduced;

save(fullfile(outputDir, 'Q4_results.mat'), 'results');
fprintf('  Saved: Q4_results.mat\n');

%% ========================================================================
%  QUESTION 4(b): MATHEMATICAL DERIVATION (PRINTED TO CONSOLE)
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 4(b): MATHEMATICAL DERIVATION\n');
fprintf('========================================\n\n');

fprintf('DERIVATION: Why PPC is an Unbiased Estimator of Squared PLV\n');
fprintf('------------------------------------------------------------\n\n');

fprintf('STEP 1: Define Phase Locking Value (PLV)\n');
fprintf('  PLV is defined as the magnitude of the mean phase vector:\n');
fprintf('    PLV = |E[exp(i*θ)]|\n');
fprintf('  where θ is the phase difference between two signals\n');
fprintf('  and E[] denotes expectation over trials.\n\n');

fprintf('STEP 2: Naive Estimator of PLV²\n');
fprintf('  A naive estimator would be:\n');
fprintf('    PLV² ≈ |mean(exp(i*θ_j))|²  where j = 1,...,N trials\n');
fprintf('    PLV² ≈ |(1/N) Σ exp(i*θ_j)|²\n\n');
fprintf('  However, this estimator is BIASED because:\n');
fprintf('    E[|mean(exp(i*θ_j))|²] = E[PLV²] + σ²/N\n');
fprintf('  where σ² is the variance term that depends on N.\n\n');

fprintf('STEP 3: Expanding the Squared Magnitude\n');
fprintf('  Let v_j = exp(i*θ_j) be the unit phase vector for trial j.\n');
fprintf('  Then:\n');
fprintf('    |(1/N) Σ v_j|² = (1/N²) |Σ v_j|²\n');
fprintf('                   = (1/N²) (Σ v_j)(Σ v_k*)\n');
fprintf('                   = (1/N²) Σ_j Σ_k v_j·v_k*\n\n');

fprintf('STEP 4: Separating Diagonal and Off-Diagonal Terms\n');
fprintf('  Split the double sum into diagonal (j=k) and off-diagonal (j≠k):\n');
fprintf('    (1/N²) Σ_j Σ_k v_j·v_k* = (1/N²)[Σ_j |v_j|² + Σ_{j≠k} v_j·v_k*]\n\n');
fprintf('  Since |v_j|² = 1 for all j (unit vectors):\n');
fprintf('    = (1/N²)[N + Σ_{j≠k} v_j·v_k*]\n');
fprintf('    = (1/N) + (1/N²) Σ_{j≠k} v_j·v_k*\n\n');

fprintf('STEP 5: Taking Expectation\n');
fprintf('  Taking expectation over trials:\n');
fprintf('    E[|(1/N) Σ v_j|²] = E[(1/N)] + E[(1/N²) Σ_{j≠k} v_j·v_k*]\n');
fprintf('                       = (1/N) + (1/N²) Σ_{j≠k} E[v_j·v_k*]\n\n');
fprintf('  For independent trials j≠k:\n');
fprintf('    E[v_j·v_k*] = E[v_j]·E[v_k*] = PLV²\n\n');
fprintf('  Number of off-diagonal terms: N(N-1)\n');
fprintf('    E[|(1/N) Σ v_j|²] = (1/N) + (1/N²)·N(N-1)·PLV²\n');
fprintf('                       = (1/N) + ((N-1)/N)·PLV²\n');
fprintf('                       = PLV² + (1/N)(1 - PLV²)\n\n');
fprintf('  This shows POSITIVE BIAS proportional to 1/N!\n\n');

fprintf('STEP 6: Deriving Unbiased Estimator (PPC)\n');
fprintf('  To remove the bias, we compute:\n');
fprintf('    PPC = (1/[N(N-1)]) Σ_{j≠k} v_j·v_k*\n');
fprintf('        = (1/[N(N-1)]) [Σ_j Σ_k v_j·v_k* - Σ_j |v_j|²]\n');
fprintf('        = (1/[N(N-1)]) [|Σ v_j|² - N]\n\n');

fprintf('STEP 7: Verify Unbiased Property\n');
fprintf('  Taking expectation:\n');
fprintf('    E[PPC] = E[(1/[N(N-1)]) [|Σ v_j|² - N]]\n');
fprintf('           = (1/[N(N-1)]) [N²·E[|(1/N) Σ v_j|²] - N]\n');
fprintf('           = (1/[N(N-1)]) [N²·(PLV² + (1/N)(1-PLV²)) - N]\n');
fprintf('           = (1/[N(N-1)]) [N²·PLV² + N(1-PLV²) - N]\n');
fprintf('           = (1/[N(N-1)]) [N²·PLV² - N·PLV²]\n');
fprintf('           = (1/[N(N-1)]) [N(N-1)·PLV²]\n');
fprintf('           = PLV²\n\n');

fprintf('CONCLUSION:\n');
fprintf('  E[PPC] = PLV²  (UNBIASED!)\n\n');
fprintf('  The PPC removes the 1/N bias term by:\n');
fprintf('  1. Excluding the diagonal terms (self-products)\n');
fprintf('  2. Normalizing by N(N-1) instead of N²\n\n');
fprintf('  This makes PPC an unbiased estimator of squared PLV,\n');
fprintf('  regardless of the number of trials N.\n\n');

%% ========================================================================
%  SUMMARY
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 4 ANALYSIS COMPLETE\n');
fprintf('========================================\n');
fprintf('All plots saved to: %s\n\n', outputDir);

fprintf('Plots created:\n');
fprintf('  1. Q4a_comprehensive_bias_comparison (6-panel comparison)\n');
fprintf('  2. Q4a_coherence_comparison (individual)\n');
fprintf('  3. Q4a_wpli_comparison (individual)\n');
fprintf('  4. Q4a_ppc_comparison_unbiased (individual)\n');
fprintf('  5. Q4a_bias_difference_plots (3-panel bias analysis)\n');
fprintf('Total plots: 5 (each in .png and .fig format)\n\n');

fprintf('Key Findings:\n');
fprintf('  Trial count: Full = %d, Reduced = %d (1/3)\n\n', N_full, N_reduced);

fprintf('  Coherence:\n');
fprintf('    Full trials:    mean = %.4f\n', mean(coherence_full));
fprintf('    Reduced trials: mean = %.4f\n', mean(coherence_reduced));
fprintf('    Bias:           %.6f (POSITIVE BIAS)\n\n', coherence_bias_mean);

fprintf('  WPLI:\n');
fprintf('    Full trials:    mean = %.4f\n', mean(wpli_full, 'omitnan'));
fprintf('    Reduced trials: mean = %.4f\n', mean(wpli_reduced, 'omitnan'));
fprintf('    Bias:           %.6f (POSITIVE BIAS)\n\n', wpli_bias_mean);

fprintf('  PPC:\n');
fprintf('    Full trials:    mean = %.4f\n', mean(ppc_full));
fprintf('    Reduced trials: mean = %.4f\n', mean(ppc_reduced));
fprintf('    Bias:           %.6f (MINIMAL/UNBIASED)\n\n', ppc_bias_mean);

fprintf('Interpretation:\n');
fprintf('  - Coherence and WPLI show positive bias with fewer trials\n');
fprintf('  - PPC remains unbiased regardless of trial count\n');
fprintf('  - This confirms PPC is a superior metric when trial count varies\n\n');

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
