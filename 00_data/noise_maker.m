%
%	Sine Wave + Gaussian White Noise Generation Source Code
% ----------------------------------------
%	Author: Yosuke Sugiura
%	Created: 2019.9.25
%

clear;
close all;

%% Setting Variables (Set Arbitrarily)
%-------------------------------------
% wav settings
Time_length		= 5.0;				%	Length of the wav file (seconds)
Sampling_freq	= 16000;			%	Sampling frequency

% Sine wave noise settings
Sin_freq		= 700*(1:10);		%	Frequencies of sine waves (array)
Sin_phase		= 2*pi*rand(1,10);	%	Phases of sine waves (array)
Sin_amp			= 0.8.^(1:10);		%	Amplitudes of sine waves (array)

% Gaussian white noise settings
White_amp		= 0.5;				%	Amplitude of Gaussian white noise
%-------------------------------------

%% Noise Generation
Sample			= round(Time_length * Sampling_freq);	%	Number of samples

% Multiple sine wave noise
Sinusoids		= zeros(Sample,1);
for i=1:Sample
	Sinusoids(i) = sum(Sin_amp .* sin( 2*pi * i * Sin_freq./Sampling_freq + Sin_phase ));	% Multiple sine wave noise
end

% White noise
White			= White_amp * randn(Sample,1);

% Combined noise
Noise			= White + Sinusoids;

% Normalize noise amplitude
Normalized_Pow	= 0.3;				% Normalization parameter
Noise			= Normalized_Pow * Noise./ max(abs(Noise));

% Write to wav file
audiowrite('artificial_harmonic.wav',Noise,Sampling_freq);



%
%	�����g�{�K�E�X���z���C�g�m�C�Y �����\�[�X�R�[�h
% ----------------------------------------
%	�쐬�ҁF ���Y�z��
%	�쐬���F 2019.9.25
%

clear;
close all;


%% �ݒ�ϐ� (�C�ӂɐݒ�)
%-------------------------------------
% wav�̐ݒ�
Time_length		= 5.0;				%	wav�̒���(�b)
Sampling_freq	= 16000;			%	�T���v�����O���g��

% �����g�m�C�Y�̐ݒ�
Sin_freq		= 700*(1:10);		%	�����g�̎��g��(�z��)
Sin_phase		= 2*pi*rand(1,10);	%	�����g�̈ʑ�(�z��)
Sin_amp			= 0.8.^(1:10);		%	�����g�̐U��(�z��)

% �K�E�X���z���C�g�m�C�Y�̐ݒ�
White_amp		= 0.5;				%	�K�E�X���z���C�g�m�C�Y�̐U��
%-------------------------------------

%% �m�C�Y����
Sample			= round(Time_length * Sampling_freq);	%	�T���v����

% ���������g�m�C�Y
Sinusoids		= zeros(Sample,1);
for i=1:Sample
	Sinusoids(i) = sum(Sin_amp .* sin( 2*pi * i * Sin_freq./Sampling_freq + Sin_phase ));	% ���������g�m�C�Y
end

% �z���C�g�m�C�Y
White			= White_amp * randn(Sample,1);

% �������킹���m�C�Y
Noise			= White + Sinusoids;

% �m�C�Y�̐U���̐��K��
Normalized_Pow	= 0.3;				% ���K���p�����[�^
Noise			= Normalized_Pow * Noise./ max(abs(Noise));


% wav�ւ̏����o��
audiowrite('artificial_harmonic.wav',Noise,Sampling_freq);


