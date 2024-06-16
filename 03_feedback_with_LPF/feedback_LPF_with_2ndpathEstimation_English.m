%
%  Active Noise Control + LPC (Feedback Type)
% * Estimation of the second path included (considered unknown)
% ----------------------------------------
% Created by: Yosuke Sugiura
% Created on: 2022.7.18
%

clear;
close all;


%% Setting variables (set as desired)
%-------------------------------------
% Distance between speaker and microphone (cm)
Dist_2nd = 3;                % Distance of the second path (cm)

% Order of adaptive filter
N_1st = 500;                % Order of noise control filter W(z)
N_2nd = 150;                % Order of second path model C_h(z)
N_LPF = 100;                % Order of linear predictor

% Settings for adaptive filter
mu = 1.5;                   % Update step size for noise control filter
mu_h = 0.001;               % Update step size for second path model
mu_lpf = 1.5;               % Update step size for linear predictor
L_preEst = 10000;           % Length of initial samples used for pre-estimation
%-------------------------------------

%% Obtain noise
[s, fs] = audioread('../00_data/harmonics.wav');   % Noise signal
len = length(s);

%% Obtain impulse response (do not modify)
Imp_2nd = csvread('../00_data/impulse2.dat');    % Impulse response of the second path

% Create impulse response of the second path (Speaker 1)
smpl = max([1, floor(Dist_2nd * 0.1 / 340.29 * fs)]); % Delay
if smpl <= 200
    Imp_2nd = Imp_2nd(200-smpl:end)';
else
    Imp_2nd = [zeros(smpl-200, 1); Imp_2nd]';
end
L_2nd = length(Imp_2nd);

%% Initialize arrays
% -- Filter --
w = zeros(1, N_1st);                 % Noise control filter coefficients
ch = zeros(1, N_2nd);                % Second path model coefficients (unknown)
h = zeros(1, N_LPF);                 % Linear predictor coefficients
% -- Buffer --
y_buf = zeros(max(L_2nd, N_2nd), 1);   % Second path buffer
d_h_buf = zeros(max(N_1st, N_2nd), 1); % Reconstructed noise buffer
r_buf = zeros(N_1st, 1);             % Filtered reconstructed noise buffer
e_buf1 = zeros(N_LPF, 1);            % Linear predictor buffer
e_buf2 = zeros(N_LPF, 1);            % Linear predictor buffer
e_buf3 = zeros(N_LPF, 1);            % Linear predictor buffer
% -- Results --
in = zeros(len, 1);                  % Error microphone signal (error signal)
out = zeros(len, 1);                 % Result (error signal)
pred = zeros(len, 1);                % Linear predictor output (error signal)
error = zeros(len, 1);               % Error
% -- Calculation --
out_2nd = 0;

%% Noise control simulation
tic;

% == Pre-estimation ==
for loop = 1:L_preEst-1
    
    % -- White noise --
    yh = randn(1);                 % White noise
    y_buf = [yh; y_buf(1:end-1)];  % White noise buffer (FILO)
    
    % -- White noise passed through the second path --
    eh = Imp_2nd * y_buf(1:L_2nd);
    
    % -- Filtered white noise --
    rh = ch * y_buf(1:N_2nd);
    
    % -- Error --
    er = rh - eh;
    
    % -- NLMS algorithm --
    ch = ch - mu_h * er .* y_buf(1:N_2nd)' ./ mean(y_buf(1:N_2nd).^2);  % Update
    
end

for loop = 1:len-N_1st

    % -- Reference signal --
    x = s(loop);                   % Reference signal
    
    % -- Noise passed through the first path --
    % #No need to estimate the first path in the feedback type.
    d = x;
    
    % -- Control signal --
    y = w * d_h_buf(1:N_1st);       % y = Σw(i)d^(n-i)
    
    % -- Control signal passed through the second path --
    y_buf = [y; y_buf(1:end-1)];    % Control signal buffer
    y_h = Imp_2nd * y_buf(1:L_2nd);  % Control signal passed through the second path
    
    % -- Error signal (input signal to the error microphone) --
    e = d + y_h;                   % e(n) = d(n) + y^(n)
    
    % -- Error signal passed through the linear predictor
    e_h = h * e_buf1;               % e^(n) = Σh(i)e(n-i-1)
    
    % -- Control signal passed through the second path model + linear predictor --
    y_t = ch * y_buf(1:N_2nd);      % Convolve second path model (ch) with y(n)
    y_d = h * e_buf2;               % y'(n) : Output of second path model passed through LPF
    e_buf2 = [y_t; e_buf2(1:end-1)]; % Buffer
    
    % -- Reconstructed noise --
    %d_h = e_h - y_d;               % d^(n) : e^(n) - y'(n)
    d_h = e_h - y_t;
    d_h_buf = [d_h; d_h_buf(1:end-1)]; % Buffer
    
    % -- Filtered reconstructed noise + linear predictor --
    r = ch * d_h_buf(1:N_2nd);      % Convolve second path model (ch) with d^(n)
    %r_h = h * e_buf3;               % r^(n) : Output of second path model passed through LPF
    %e_buf3 = [r; e_buf3(1:end-1)];   % Buffer
    
    % -- Filtered-X NLMS algorithm --
    w = w - mu * e .* r_buf' ./(sum(r_buf.^2) + 1);  % Update
    r_buf = [r; r_buf(1:end-1)];  % Buffer (Filtered-X NLMS)
    %w = w - mu * e_h .* r_buf' ./(sum(r_buf.^2) + 1);  % Update
    %r_buf = [r; r_buf(1:end-1)];   % Buffer
    
    % -- LPF update --
    h = h - mu_lpf * (e_h - e) .* e_buf1' ./(sum(e_buf1.^2) + 1);  % Update
    e_buf1 = [e; e_buf1(1:end-1)];  % Buffer
    
    in(loop) = d;
    out(loop) = e;
    pred(loop) = y_t;
    %error(loop) = e_h - e;
end

toc;

%% Plot waveforms
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('time [s]');
ylabel('Amplitude');
legend('Output (without ANC)', 'Output (with ANC)');

%% Plot spectrogram
S = 2048;
N = 8192;
figure(2);
[X_in, f, t] = stft_(in, S, N, S/16, fs);
P_in = 20*log10(abs(X_in) + 10^(-8))';
imagesc(t, f, P_in(1:N/2, :))
caxis([-100 50])
colormap hot
axis xy
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogram of Input Noise');

figure(3);
[X_out, f, t] = stft_(out, S, N, S/16, fs);
P_out = 20*log10(abs(X_out) + 10^(-8))';
imagesc(t, f, P_out(1:N/2, :))
caxis([-100 50])
colormap hot
axis xy
xlabel('Time [s]');
ylabel('Frequency [Hz]');
title('Spectrogram of Output Cancelled Noise');

%% Plot spectra
% Calculate average spectrum after convergence (after control)
L = 300;
P_in_ave = 20*log10(mean(abs(X_in(end-L:end, :)), 1) + 10^(-8));   % Average spectrum of the last L frames
P_out_ave = 20*log10(mean(abs(X_out(end-L:end, :)), 1) + 10^(-8)); % Average spectrum of the last L frames

[X_pred, f, t] = stft_(pred, S, N, S/16, fs);
P_pred_ave = 20*log10(mean(abs(X_pred(end-L:end, :)), 1) + 10^(-8));

figure(4);
plot(f, P_in_ave(1:N/2), 'LineWidth', 1.5, 'Color', 'r'); hold on;
