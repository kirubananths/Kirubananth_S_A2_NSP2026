%% NSP Assignment 2 (EEG Module) - Question 3: Connectivity Metrics from Spectra
% This script computes Coherence, WPLI, and PPC directly from cross and auto spectra
% WITHOUT using FieldTrip's connectivity functions
% Author - Kirubananth S
% Electrodes: PO3 and AF4
% Data: Subject 013AR, protocol M1, unipolar reference
%
% FORMULAS MATCH LECTURE SLIDES:
% - Coherence: Standard magnitude coherency
% - WPLI: Slide 78 - |E{imag(S12)}| / E{|imag(S12)|}
% - PPC: Slide 82 - Phase-only pairwise consistency


clear all; close all; clc;

%% ========================================================================
%  SETUP AND DATA LOADING
%  ========================================================================

% Create output directory for plots
outputDir = 'Question 3 Plots';
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

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
fprintf('  Number of trials: %d\n', numTrials);
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
%  EXTRACT STIMULUS PERIOD DATA
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
dataPO3 = zeros(length(stimIdx), numTrials);
dataAF4 = zeros(length(stimIdx), numTrials);

for tr = 1:numTrials
    trialData = data.trial{tr};  % 64 electrodes × time points
    dataPO3(:, tr) = trialData(po3Idx, stimIdx);
    dataAF4(:, tr) = trialData(af4Idx, stimIdx);
end

fprintf('Data extraction complete.\n');

%% ========================================================================
%  COMPUTE CROSS AND AUTO SPECTRA USING MULTI-TAPER METHOD
%  ========================================================================

fprintf('\nComputing cross and auto spectra using multi-taper method...\n');

% Multi-taper parameters (matching displayConnectivity.m)
% For T=0.5s, W=4Hz => TW=2, use 3 tapers (2*TW-1 = 3)
TW = 2;  % Time-bandwidth product
K = 3;   % Number of tapers
W = 4;   % Frequency smoothing bandwidth (Hz)

params.tapers = [TW K];
params.Fs = Fs;
params.fpass = [0 50];  % 0-50 Hz as in displayConnectivity.m
params.pad = 0;
params.err = 0;
params.trialave = 0;  % Keep trials separate

fprintf('  Multi-taper parameters:\n');
fprintf('    Time-bandwidth product (TW): %d\n', TW);
fprintf('    Number of tapers (K): %d\n', K);
fprintf('    Frequency smoothing (W): ±%d Hz\n', W);
fprintf('    Frequency range: %.0f-%.0f Hz\n', params.fpass(1), params.fpass(2));

% Compute tapers
N = size(dataPO3, 1);
tapers = dpss(N, params.tapers(1), params.tapers(2));
tapers = tapers * sqrt(params.Fs);

% Compute FFT for both electrodes
nfft = max(2^(nextpow2(N) + params.pad), N);
fprintf('  Computing multi-taper FFT...\n');
fprintf('    Data length: %d samples\n', N);
fprintf('    FFT length: %d points\n', nfft);

J_PO3 = mtfftc(dataPO3, tapers, nfft, params.Fs);  % freq × tapers × trials
J_AF4 = mtfftc(dataAF4, tapers, nfft, params.Fs);

% Get frequency grid
if mod(nfft, 2) == 0
    f = (0:nfft/2) * params.Fs / nfft;
else
    f = (0:(nfft-1)/2) * params.Fs / nfft;
end

% Extract frequencies in fpass range
freqIdx = find(f >= params.fpass(1) & f <= params.fpass(2));
f = f(freqIdx);
J_PO3 = J_PO3(freqIdx, :, :);
J_AF4 = J_AF4(freqIdx, :, :);

fprintf('  Frequency resolution: %.2f Hz\n', f(2) - f(1));
fprintf('  Number of frequency points: %d\n', length(f));

%% ========================================================================
%  COMPUTE CROSS-SPECTRUM AND AUTO-SPECTRA
%  ========================================================================

fprintf('\nComputing cross-spectrum and auto-spectra...\n');

% Cross-spectrum: S12 = E[J1 * conj(J2)] averaged over tapers
% Auto-spectra: S11 = E[J1 * conj(J1)], S22 = E[J2 * conj(J2)]

% Average over tapers first
S12 = squeeze(mean(conj(J_PO3) .* J_AF4, 2));  % freq × trials
S11 = squeeze(mean(conj(J_PO3) .* J_PO3, 2));  % freq × trials (PO3 power)
S22 = squeeze(mean(conj(J_AF4) .* J_AF4, 2));  % freq × trials (AF4 power)

fprintf('  Cross-spectrum (S12) computed: %d frequencies × %d trials\n', size(S12, 1), size(S12, 2));
fprintf('  Auto-spectrum PO3 (S11) computed\n');
fprintf('  Auto-spectrum AF4 (S22) computed\n');

%% ========================================================================
%  QUESTION 3(a): COMPUTE COHERENCE
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 3(a): Computing COHERENCE\n');
fprintf('========================================\n');

% Coherence: C = |E[S12]| / sqrt(E[S11] * E[S22])
% where E[] is expectation over trials

S12_avg = mean(S12, 2);  % Average cross-spectrum over trials
S11_avg = mean(S11, 2);  % Average PO3 power over trials
S22_avg = mean(S22, 2);  % Average AF4 power over trials

% Compute coherence
coherence = abs(S12_avg) ./ sqrt(S11_avg .* S22_avg);

fprintf('Coherence computed successfully.\n');
fprintf('  Range: [%.4f, %.4f]\n', min(coherence), max(coherence));
fprintf('  Mean: %.4f\n', mean(coherence));

%% ========================================================================
%  QUESTION 3(b): COMPUTE WPLI (Weighted Phase Lag Index)
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 3(b): Computing WPLI\n');
fprintf('========================================\n');

% WPLI formula from lecture slide 78:
% WPLI = |E{imag(S12)}| / E{|imag(S12)|}
% where E{} is expectation over trials

imag_S12 = imag(S12);  % Imaginary part of cross-spectrum (freq × trials)

% Compute WPLI
numerator = abs(mean(imag_S12, 2));  % |E[imag(S12)]|
denominator = mean(abs(imag_S12), 2);  % E[|imag(S12)|]

wpli = numerator ./ denominator;

fprintf('WPLI computed successfully.\n');
fprintf('  Range: [%.4f, %.4f]\n', min(wpli), max(wpli));
fprintf('  Mean: %.4f\n', mean(wpli));

%% ========================================================================
%  QUESTION 3(c): COMPUTE PPC (Pairwise Phase Consistency)
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 3(c): Computing PPC\n');
fprintf('========================================\n');

% PPC formula from lecture slide 82 (PHASE-ONLY):
% PPC = (2/(N(N-1))) * Σ Σ cos(θ_j - θ_k)
%     = (2/(N(N-1))) * Σ Σ Re{exp(i*θ_j) * conj(exp(i*θ_k))}
%     = (|Σ exp(i*θ_j)|² - N) / (N*(N-1))
%
% where θ_j = angle(S12_j) is the PHASE ONLY (unit vectors)
%
% This is an unbiased estimator of squared PLV (Phase Locking Value)

N_trials = size(S12, 2);
ppc = zeros(length(f), 1);

fprintf('Computing PPC for %d frequencies and %d trials...\n', length(f), N_trials);
fprintf('  Using PHASE-ONLY formula from lecture slide 82\n');

for freqIdx_loop = 1:length(f)
    % Extract cross-spectrum for this frequency across all trials
    S12_freq = S12(freqIdx_loop, :);  % 1 × trials
    
    % CRITICAL: Extract PHASE ONLY - unit vectors (lecture slide 82)
    % phase_vectors = exp(i*angle(S12)) = S12/|S12|
    phase_vectors = S12_freq ./ abs(S12_freq);
    
    % PPC formula from lecture slide 82:
    % PPC = (|sum of unit vectors|² - N) / (N*(N-1))
    sum_all = abs(sum(phase_vectors))^2;  % |Σ exp(i*θ_j)|²
    sum_diag = N_trials;  % Each |exp(i*θ)|² = 1
    
    ppc(freqIdx_loop) = (sum_all - sum_diag) / (N_trials * (N_trials - 1));
end

fprintf('PPC computed successfully.\n');
fprintf('  Range: [%.4f, %.4f]\n', min(ppc), max(ppc));
fprintf('  Mean: %.4f\n', mean(ppc));

%% ========================================================================
%  PLOT ALL THREE METRICS ON SAME FIGURE
%  ========================================================================

fprintf('\nCreating unified comparison plot...\n');

figure('Position', [100, 100, 1000, 700]);

% Plot all three metrics on same axes
hold on;
h1 = plot(f, coherence, 'b-', 'LineWidth', 2.5);
h2 = plot(f, wpli, 'r--', 'LineWidth', 2.5);
h3 = plot(f, ppc, 'g-.', 'LineWidth', 2.5);
hold off;

% Labels and title
xlabel('Frequency (Hz)', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Connectivity Metric Value', 'FontSize', 14, 'FontWeight', 'bold');
title('Question 3: All Connectivity Metrics - PO3 vs AF4 (M1, Unipolar)', ...
    'FontSize', 16, 'FontWeight', 'bold');

% Legend
legend([h1, h2, h3], ...
    sprintf('Coherence (mean=%.3f, range=[%.3f, %.3f])', ...
        mean(coherence), min(coherence), max(coherence)), ...
    sprintf('WPLI (mean=%.3f, range=[%.3f, %.3f])', ...
        mean(wpli), min(wpli), max(wpli)), ...
    sprintf('PPC (mean=%.3f, range=[%.3f, %.3f])', ...
        mean(ppc), min(ppc), max(ppc)), ...
    'Location', 'best', 'FontSize', 11);

% Set appropriate axis limits to show all data
xlim([params.fpass(1) params.fpass(2)]);

% Calculate appropriate y-axis limits with margin
all_values = [coherence; wpli; ppc];
y_min = min(all_values);
y_max = max(all_values);
y_range = y_max - y_min;
y_margin = 0.1 * y_range;  % 10% margin
ylim([max(0, y_min - y_margin), y_max + y_margin]);

% Grid
grid on;
set(gca, 'FontSize', 12);

% Add text box with summary statistics
stats_text = sprintf(['Number of trials: %d\n' ...
                      'Frequency range: %.0f-%.0f Hz\n' ...
                      'Electrode pair: PO3-AF4'], ...
                     N_trials, f(1), f(end));
annotation('textbox', [0.15, 0.75, 0.3, 0.15], ...
    'String', stats_text, ...
    'FontSize', 10, ...
    'BackgroundColor', 'white', ...
    'EdgeColor', 'black', ...
    'FitBoxToText', 'on');

% Save figure
saveas(gcf, fullfile(outputDir, 'Q3_all_metrics_comparison.png'));
saveas(gcf, fullfile(outputDir, 'Q3_all_metrics_comparison.fig'));
fprintf('  Saved: Q3_all_metrics_comparison\n');

%% ========================================================================
%  PLOT EACH METRIC INDIVIDUALLY WITH APPROPRIATE SCALING
%  ========================================================================

% Individual plot for Coherence
figure('Position', [100, 100, 800, 600]);
plot(f, coherence, 'b-', 'LineWidth', 2.5);
xlabel('Frequency (Hz)', 'FontSize', 14);
ylabel('Coherence', 'FontSize', 14);
title('Coherence: PO3-AF4 (M1, Unipolar)', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
% Appropriate scaling for coherence
y_min_coh = min(coherence);
y_max_coh = max(coherence);
y_range_coh = y_max_coh - y_min_coh;
ylim([max(0, y_min_coh - 0.05*y_range_coh), min(1, y_max_coh + 0.05*y_range_coh)]);
set(gca, 'FontSize', 12);
saveas(gcf, fullfile(outputDir, 'Q3a_Coherence.png'));
saveas(gcf, fullfile(outputDir, 'Q3a_Coherence.fig'));
fprintf('  Saved: Q3a_Coherence\n');

% Individual plot for WPLI
figure('Position', [100, 100, 800, 600]);
plot(f, wpli, 'r-', 'LineWidth', 2.5);
xlabel('Frequency (Hz)', 'FontSize', 14);
ylabel('WPLI', 'FontSize', 14);
title('WPLI: PO3-AF4 (M1, Unipolar)', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
% Appropriate scaling for WPLI
y_min_wpli = min(wpli);
y_max_wpli = max(wpli);
y_range_wpli = y_max_wpli - y_min_wpli;
ylim([max(0, y_min_wpli - 0.05*y_range_wpli), min(1, y_max_wpli + 0.05*y_range_wpli)]);
set(gca, 'FontSize', 12);
saveas(gcf, fullfile(outputDir, 'Q3b_WPLI.png'));
saveas(gcf, fullfile(outputDir, 'Q3b_WPLI.fig'));
fprintf('  Saved: Q3b_WPLI\n');

% Individual plot for PPC
figure('Position', [100, 100, 800, 600]);
plot(f, ppc, 'g-', 'LineWidth', 2.5);
xlabel('Frequency (Hz)', 'FontSize', 14);
ylabel('PPC', 'FontSize', 14);
title('PPC: PO3-AF4 (M1, Unipolar)', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
xlim([params.fpass(1) params.fpass(2)]);
% Appropriate scaling for PPC
y_min_ppc = min(ppc);
y_max_ppc = max(ppc);
y_range_ppc = y_max_ppc - y_min_ppc;
ylim([max(0, y_min_ppc - 0.05*y_range_ppc), y_max_ppc + 0.05*y_range_ppc]);
set(gca, 'FontSize', 12);
saveas(gcf, fullfile(outputDir, 'Q3c_PPC.png'));
saveas(gcf, fullfile(outputDir, 'Q3c_PPC.fig'));
fprintf('  Saved: Q3c_PPC\n');

%% ========================================================================
%  SAVE RESULTS TO MAT FILE
%  ========================================================================

fprintf('\nSaving results to file...\n');

% Save all results
results = struct();
results.frequency = f;
results.coherence = coherence;
results.wpli = wpli;
results.ppc = ppc;
results.S12 = S12;  % Save cross-spectrum for Q4
results.S11 = S11;  % Save auto-spectrum for Q4
results.S22 = S22;  % Save auto-spectrum for Q4
results.numTrials = N_trials;
results.electrodes = {'PO3', 'AF4'};
results.parameters = params;

save(fullfile(outputDir, 'Q3_results.mat'), 'results');
fprintf('  Saved: Q3_results.mat\n');

%% ========================================================================
%  SUMMARY
%  ========================================================================

fprintf('\n========================================\n');
fprintf('QUESTION 3 ANALYSIS COMPLETE\n');
fprintf('========================================\n');
fprintf('All plots saved to: %s\n', outputDir);
fprintf('  Q3a: Coherence plot\n');
fprintf('  Q3b: WPLI plot\n');
fprintf('  Q3c: PPC plot\n');
fprintf('  Comparison: All metrics together\n');
fprintf('Total plots: 4 (each in .png and .fig format)\n');

fprintf('\nKey Results Summary:\n');
fprintf('  Electrode pair: PO3 - AF4\n');
fprintf('  Number of trials: %d\n', N_trials);
fprintf('  Frequency range: %.0f - %.0f Hz\n', f(1), f(end));
fprintf('  Coherence: mean=%.4f, range=[%.4f, %.4f]\n', ...
    mean(coherence), min(coherence), max(coherence));
fprintf('  WPLI:      mean=%.4f, range=[%.4f, %.4f]\n', ...
    mean(wpli), min(wpli), max(wpli));
fprintf('  PPC:       mean=%.4f, range=[%.4f, %.4f]\n', ...
    mean(ppc), min(ppc), max(ppc));

fprintf('\nMetric Interpretations:\n');
fprintf('  Coherence: Measures magnitude of phase consistency (biased by trial count)\n');
fprintf('  WPLI: Weighted Phase Lag Index (reduces volume conduction effects)\n');
fprintf('  PPC: Pairwise Phase Consistency (unbiased estimator of squared PLV)\n');

fprintf('\nFormulas Used (matching lecture slides):\n');
fprintf('  Coherence: |E[S12]| / sqrt(E[S11] * E[S22])\n');
fprintf('  WPLI (Slide 78): |E{imag(S12)}| / E{|imag(S12)|}\n');
fprintf('  PPC (Slide 82): (|Σ exp(i*θ_j)|² - N) / (N*(N-1)) [phase-only]\n');

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
