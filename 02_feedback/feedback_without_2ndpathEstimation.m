%
%    Active Noise Control (Feedback Type)
%    * Without estimation of secondary path (assumed known)
%    ----------------------------------------
%    Author: Yosuke Sugiura
%    Created: 2019.5.13
%

clear;
close all;


%% Configuration Variables (Set Arbitrarily)
%-------------------------------------
% Distance between Speaker and Microphone (cm)
Dist_1st    = 10;                % Distance of the primary path (cm)
Dist_2nd    = 3;                 % Distance of the secondary path (cm)

% Order of the adaptive filter
N_1st       = 600;               % Order of noise control filter W(z) 200
N_2nd       = 400;               % Order of secondary path model C_h(z) 150

% Settings for the adaptive filter
mu          = 0.2;               % Step size for updating the noise control filter
g_p         = 0.9;               % Averaging parameter for NLMS
%-------------------------------------

%% Obtaining Noise
[s,fs]      = audioread('../00_data/harmonics.wav');    % Noise signal
len         = length(s);

%% Obtaining Impulse Response (Do not modify)
Imp_2nd     = csvread('../00_data/impulse2.dat');    % Impulse response of the secondary path

% Create impulse response of the secondary path (Speaker 1)
smpl        = max([1, floor(Dist_2nd* 0.01/340.29 * fs)]); % Amount of delay
if smpl <= 200
    Imp_2nd     = Imp_2nd(200-smpl:end)';
else
    Imp_2nd     = [zeros(smpl-200,1);Imp_2nd]';
end
L_2nd = length(Imp_2nd);

%% Array Initialization
% -- Filter --
% w           = rand(1,N_1st);                            % Coefficients of the noise control filter
w           = zeros(1,N_1st);
ch          = Imp_2nd(1:N_2nd);                         % Coefficients of the secondary path model (known)
% -- Buffer --
y_buf       = zeros(max(L_2nd,N_2nd),1);                % Buffer for the secondary path
d_h_buf     = zeros(max(N_1st,N_2nd),1);                % Buffer for restored noise
r_buf       = zeros(1, N_1st);                          % Buffer for filtered restored noise
% -- Results --
in          = zeros(len,1);                             % Signal at error microphone (error signal)
out         = zeros(len,1);                             % Result (error signal)
% -- For Calculation --
out_2nd     = 0;


%% Noise Control Simulation
tic;

for loop=1:len-N_1st

    % -- Reference Signal --
    x           = s(loop);                      % Reference signal
    
    % -- Noise Passed Through Primary Path --
    % # In feedback type, there is no need to estimate the primary path.
    d           = x;
    
    % -- Control Signal --
    y_h         = w * d_h_buf(1:N_1st);
    
    % -- Control Signal Passed Through Secondary Path --
    y_buf       = [y_h; y_buf(1:end-1)];        % Control signal buffer
    out_2nd     = Imp_2nd * y_buf(1:L_2nd);     % Control signal passed through secondary path

    % -- Error Signal --
    e           = d + out_2nd;
    
    % -- Pseudo Control Sound Convolved with Secondary Path Model --
    y_pseudo    = ch * y_buf(1:N_2nd);
    
    % -- Restored Noise --
    d_h         = e - y_pseudo;
    d_h_buf     = [d_h; d_h_buf(1:end-1)];      % Buffer
    
    % -- Filtered Restored Noise --
    r           = ch * d_h_buf(1:N_2nd);
    r_buf       = [r, r_buf(1:end-1)];          % Buffer
    
    % -- Filtered-X NLMS Algorithm --
    w           = w - mu * e .* r_buf ./(mean(r_buf.^2)+0.1);  % Update

    in(loop)    = d;
    out(loop)   = e;
    
end

%% Waveform Graph

% Plot the figure
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
% Figure settings
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');

%% Save WAV
audiowrite('input.wav',in,fs);
audiowrite('output.wav',out,fs);
