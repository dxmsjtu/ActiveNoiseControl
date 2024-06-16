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
%	正弦波＋ガウス性ホワイトノイズ 生成ソースコード
% ----------------------------------------
%	作成者： 杉浦陽介
%	作成日： 2019.9.25
%

clear;
close all;


%% 設定変数 (任意に設定)
%-------------------------------------
% wavの設定
Time_length		= 5.0;				%	wavの長さ(秒)
Sampling_freq	= 16000;			%	サンプリング周波数

% 正弦波ノイズの設定
Sin_freq		= 700*(1:10);		%	正弦波の周波数(配列)
Sin_phase		= 2*pi*rand(1,10);	%	正弦波の位相(配列)
Sin_amp			= 0.8.^(1:10);		%	正弦波の振幅(配列)

% ガウス性ホワイトノイズの設定
White_amp		= 0.5;				%	ガウス性ホワイトノイズの振幅
%-------------------------------------

%% ノイズ生成
Sample			= round(Time_length * Sampling_freq);	%	サンプル数

% 複数正弦波ノイズ
Sinusoids		= zeros(Sample,1);
for i=1:Sample
	Sinusoids(i) = sum(Sin_amp .* sin( 2*pi * i * Sin_freq./Sampling_freq + Sin_phase ));	% 複数正弦波ノイズ
end

% ホワイトノイズ
White			= White_amp * randn(Sample,1);

% 足し合わせたノイズ
Noise			= White + Sinusoids;

% ノイズの振幅の正規化
Normalized_Pow	= 0.3;				% 正規化パラメータ
Noise			= Normalized_Pow * Noise./ max(abs(Noise));


% wavへの書き出し
audiowrite('artificial_harmonic.wav',Noise,Sampling_freq);


