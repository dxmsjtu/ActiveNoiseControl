clear all; close all;
%% Setting Variables (Set Arbitrarily)
%-------------------------------------
% Distance between speaker and microphone (cm)
Dist_2nd	= 3;				% Distance of the secondary path (cm)
% Order of adaptive filters
N_1st		= 200;				% Order of noise control filter W(z)
N_2nd		= 150;				% Order of secondary path model C_h(z)

% Settings for adaptive filters
mu			= 0.1;				% Step size for updating the noise control filter
mu_h		= 0.001;			% Step size for updating the secondary path model
g_p			= 0.9;				% Averaging parameter for NLMS
L_preEst	= 10000;			% Initial sample length for pre-estimation
%-------------------------------------

%% Obtain Noise
[s,fs]		= audioread('../00_data/harmonics.wav');	% Noise signal
len			= length(s);

%% Obtain Impulse Response (Do not modify)
Imp_2nd		= csvread('../00_data/impulse2.dat');	% Impulse response of the secondary path
% Create impulse response of the secondary path (speaker 1)
smpl		= max([1, floor(Dist_2nd * 0.01 / 340.29 * fs)]); % Delay amount
if smpl <= 200
	Imp_2nd		= Imp_2nd(200-smpl:end)';
else
	Imp_2nd		= [zeros(smpl-200,1); Imp_2nd]';
end
L_2nd = length(Imp_2nd);
%% Initialize Arrays
% -- Filter --
w			= rand(1,N_1st);							% Coefficients of the noise control filter
ch			= zeros(1,N_2nd);							% Coefficients of the secondary path model (unknown)
% -- Buffer --
y_buf		= zeros(max(L_2nd,N_2nd),1);				% Buffer for the secondary path
d_h_buf		= zeros(max(N_1st,N_2nd),1);				% Buffer for restored noise
r_buf		= zeros(1, N_1st);							% Buffer for filtered restored noise
% -- Results --
in			= zeros(len,1);								% Error signal at the error microphone
out			= zeros(len,1);								% Results (error signal)
% -- Calculation --
out_2nd		= 0;
%% Noise Control Simulation
tic;
% == Pre-estimation ==
for loop=1:L_preEst-1	
	% -- White noise --
	yh			= randn(1);						% White noise
	y_buf		= [yh; y_buf(1:end-1)];			% White noise buffer (FILO)	
	% -- White noise passing through the secondary path --
	eh			= Imp_2nd * y_buf(1:L_2nd);	
	% -- Filtered white noise --
	rh			= ch * y_buf(1:N_2nd);		
	% -- Error --
	er			= rh - eh;	
	% -- NLMS Algorithm --
	ch		= ch - mu_h * er .* y_buf(1:N_2nd)' ./mean(y_buf(1:N_2nd).^2);	% Update	
end

for loop=1:len-N_1st
	% -- Reference signal --
	x			= s(loop);						% Reference signal	
	% -- Noise passing through the primary path --
	% # No need to estimate the primary path in the feedback type.
	d			= x;	
	% -- Control signal --
	y_h			= w * d_h_buf(1:N_1st);	
	% -- Control signal passing through the secondary path --
	y_buf		= [y_h; y_buf(1:end-1)];		% Control signal buffer
	out_2nd		= Imp_2nd * y_buf(1:L_2nd);		% Control signal passing through the secondary path

	% -- Error signal --
	e			= d + out_2nd;
	
	% -- Pseudo control sound obtained by convolving the control signal with the secondary path model --
	y_pseudo	= ch * y_buf(1:N_2nd);
	
	% -- Restored noise --
	d_h			= e - y_pseudo;
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% Buffer
	
	% -- Filtered restored noise --
	r			= ch * d_h_buf(1:N_2nd);
	r_buf		= [r, r_buf(1:end-1)];			% Buffer
	
	% -- Filtered-X NLMS Algorithm --
	w			= w - mu * e .* r_buf ./(mean(r_buf.^2)+0.1);	% Update
	in(loop)	= d;
    out(loop)	= e;	
end

toc;

%% Waveform Graph

% Plot the graph
figure(1);plot((1:len)./fs, in); hold on;plot((1:len)./fs, out); hold off;
% Configure the graph
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);xlabel('time [s]');ylabel('Amplitude');legend('Output (without ANC)','Output (with ANC)');
%% Save wav files
audiowrite('input.wav',in,fs);audiowrite('output.wav',out,fs);
OldFile =0;
%
%	能動騒音制御 (フォードバック型)
%	* ２次経路の推定あり(未知とする)
% ----------------------------------------
%	作成者： 杉浦陽介
%	作成日： 2019.5.13
%
if OldFile ==1
    %
% 能动噪声控制（反馈型）
% * 带有次级路径估计（假定未知）
% ----------------------------------------
% 作者： 杉浦阳介
% 创建日期： 2019.5.13
%

clear;
close all;

%% 设定变量（任意设定）
%-------------------------------------
% 扬声器和麦克风之间的距离（厘米）
Dist_2nd = 3;  % 次级路径的距离（厘米）

% 自适应滤波器的阶数
N_1st = 200;  % 噪声控制滤波器 W(z) 的阶数
N_2nd = 150;  % 次级路径模型 C_h(z) 的阶数

% 自适应滤波器的设置
mu = 0.1;     % 更新步长 for 噪声控制滤波器
mu_h = 0.001; % 更新步长 for 次级路径模型
g_p = 0.9;    % 用于NLMS的平均参数
L_preEst = 10000;  % 用于预估计的初始样本长度
%-------------------------------------

%% 获取噪声
[s, fs] = audioread('../00_data/harmonics.wav');  % 噪声信号
len = length(s);

%% 获取脉冲响应（不要修改）
Imp_2nd = csvread('../00_data/impulse2.dat');  % 次级路径的脉冲响应

% 创建次级路径（扬声器1）的脉冲响应
smpl = max([1, floor(Dist_2nd * 0.01 / 340.29 * fs)]); % 延迟量
if smpl <= 200
    Imp_2nd = Imp_2nd(200-smpl:end)';
else
    Imp_2nd = [zeros(smpl-200, 1); Imp_2nd]';
end
L_2nd = length(Imp_2nd);

%% 初始化数组
% -- 滤波器 --
w = rand(1, N_1st);  % 噪声控制滤波器的系数
ch = zeros(1, N_2nd);  % 次级路径模型的系数（未知）
% -- 缓冲区 --
y_buf = zeros(max(L_2nd, N_2nd), 1);  % 次级路径缓冲区
d_h_buf = zeros(max(N_1st, N_2nd), 1);  % 还原噪声缓冲区
r_buf = zeros(1, N_1st);  % 滤波后的还原噪声缓冲区
% -- 结果 --
in = zeros(len, 1);  % 错误麦克风的误差信号
out = zeros(len, 1);  % 结果（误差信号）
% -- 计算用 --
out_2nd = 0;

%% 噪声控制仿真
tic;

% == 预估计 ==
for loop = 1:L_preEst-1
    
    % -- 白噪声 --
    yh = randn(1);  % 白噪声
    y_buf = [yh; y_buf(1:end-1)];  % 白噪声缓冲区（FILO）
    
    % -- 通过次级路径的白噪声 --
    eh = Imp_2nd * y_buf(1:L_2nd);
    
    % -- 滤波后的白噪声 --
    rh = ch * y_buf(1:N_2nd);  
    
    % -- 误差 --
    er = rh - eh;
    
    % -- NLMS算法 --
    ch = ch - mu_h * er .* y_buf(1:N_2nd)' ./ mean(y_buf(1:N_2nd).^2);  % 更新
    
end

for loop = 1:len-N_1st

    % -- 参考信号 --
    x = s(loop);  % 参考信号
    
    % -- 通过一次路径的噪声 --
    % # 反馈型不需要估计一次路径。
    d = x;
    
    % -- 控制信号 --
    y_h = w * d_h_buf(1:N_1st);
    
    % -- 通过次级路径的控制信号 --
    y_buf = [y_h; y_buf(1:end-1)];  % 控制信号缓冲区
    out_2nd = Imp_2nd * y_buf(1:L_2nd);  % 通过次级路径的控制信号

    % -- 误差信号 --
    e = d + out_2nd;
    
    % -- 通过次级路径模型卷积得到的控制信号（=伪控制声） --
    y_pseudo = ch * y_buf(1:N_2nd);
    
    % -- 还原噪声 --
    d_h = e - y_pseudo;
    d_h_buf = [d_h; d_h_buf(1:end-1)];  % 缓冲区
    
    % -- 滤波后的还原噪声 --
    r = ch * d_h_buf(1:N_2nd);
    r_buf = [r, r_buf(1:end-1)];  % 缓冲区
    
    % -- Filtered-X NLMS算法 --
    w = w - mu * e .* r_buf ./ (mean(r_buf.^2) + 0.1);  % 更新

    in(loop) = d;
    out(loop) = e;
    
end

toc;

%% 波形图

% 绘制图表
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
% 设置图表
title('误差麦克风获得的波形');
xlim([1, len/fs]);
xlabel('时间 [s]');
ylabel('振幅');
legend('输出（无ANC）','输出（有ANC）');

%% 保存wav文件
audiowrite('input.wav', in, fs);
audiowrite('output.wav', out, fs);



clear;
close all;
%% 設定変数 (任意に設定)
%-------------------------------------
% スピーカ・マイク間距離(cm)
Dist_2nd	= 3;				% 2次経路の距離(cm)

% 適応フィルタの次数
N_1st		= 200;				% 騒音制御フィルタ W(z) の次数
N_2nd		= 150;				% ２次経路モデル C_h(z) の次数

% 適応フィルタの設定
mu			= 0.1;				% 更新ステップサイズ for 騒音制御フィルタ
mu_h		= 0.001;			% 更新ステップサイズ for 2次経路モデル
g_p			= 0.9;				% NLMS用平均パラメータ
L_preEst	= 10000;			% 事前推定に用いる初期サンプル長
%-------------------------------------

%% 騒音の取得
[s,fs]		= audioread('../00_data/harmonics.wav');	% 騒音信号
len			= length(s);

%% インパルス応答の取得 (いじらないで)
Imp_2nd		= csvread('../00_data/impulse2.dat');	% ２次経路のインパルス応答

% ２次経路(スピーカ１)のインパルス応答を作成
smpl		= max( [1, floor(Dist_2nd* 0.01/340.29 * fs)] ); % 遅延量
if smpl <= 200
	Imp_2nd		= Imp_2nd(200-smpl:end)';
else
	Imp_2nd		= [zeros(smpl-200,1);Imp_2nd]';
end
L_2nd = length(Imp_2nd);

%% 配列初期化
% -- Filter --
w			= rand(1,N_1st);							% 騒音制御フィルタの係数
ch			= zeros(1,N_2nd);							% ２次経路モデルの係数 (未知)
% -- Buffer --
y_buf		= zeros(max(L_2nd,N_2nd),1);				% ２次経路バッファ
d_h_buf		= zeros(max(N_1st,N_2nd),1);				% 復元騒音バッファ
r_buf		= zeros(1, N_1st);							% フィルタード復元騒音バッファ
% -- 結果 --
in			= zeros(len,1);								% 誤差マイクでの (誤差信号)
out			= zeros(len,1);								% 結果 (誤差信号)
% -- 計算用 --
out_2nd		= 0;


%% 騒音制御シミュレーション
tic;

% == 事前推定 ==
for loop=1:L_preEst-1
	
	% -- 白色雑音 --
	yh			= randn(1);						% 白色雑音
	y_buf		= [yh; y_buf(1:end-1)];			% 白色雑音バッファ (FILO)
	
	% -- ２次経路を通過した白色雑音 --
	eh			= Imp_2nd * y_buf(1:L_2nd);
	
	% -- フィルタード白色雑音 --
	rh			= ch * y_buf(1:N_2nd);	
	
	% -- 誤差 --
	er			= rh - eh;
	
	% -- NLMSアルゴリズム --
	ch		= ch - mu_h * er .* y_buf(1:N_2nd)' ./mean(y_buf(1:N_2nd).^2);	% 更新
	
end

for loop=1:len-N_1st

	% -- 参照信号 --
	x			= s(loop);						% 参照信号
	
	% -- １次経路を通過した騒音 --
	% #フィードバック型では１次経路の推定を行う必要がない．
	d			= x;
	
	% -- 制御信号 --
	y_h			= w * d_h_buf(1:N_1st);
	
	% -- ２次経路を通過した制御信号 --
	y_buf		= [y_h; y_buf(1:end-1)];		% 制御信号バッファ
	out_2nd		= Imp_2nd * y_buf(1:L_2nd);		% ２次経路を通過した制御信号

	% -- 誤差信号 --
	e			= d + out_2nd;
	
	% -- ２次経路モデルを畳み込んだ制御信号(=疑似制御音) --
	y_pseudo	= ch * y_buf(1:N_2nd);
	
	% -- 復元騒音 --
	d_h			= e - y_pseudo;
	d_h_buf		= [d_h; d_h_buf(1:end-1)];		% バッファ
	
	% -- フィルタード復元騒音 --
	r			= ch * d_h_buf(1:N_2nd);
	r_buf		= [r, r_buf(1:end-1)];			% バッファ
	
	% -- Filtered-X NLMSアルゴリズム --
	w			= w - mu * e .* r_buf ./(mean(r_buf.^2)+0.1);	% 更新

	in(loop)	= d;
	out(loop)	= e;
	
end

toc;

%% 波形グラフ

% 図のプロット
figure(1);
plot((1:len)./fs, in); hold on;
plot((1:len)./fs, out); hold off;
% 図の設定
title('Waveform Obtained from Error Microphone');
xlim([1, len/fs]);
xlabel('time [s]');
ylabel('Amplitude');
legend('Output (without ANC)','Output (with ANC)');


%% wav保存
audiowrite('input.wav',in,fs);
audiowrite('output.wav',out,fs);
%
%	Active Noise Control (Feedback Type)
%	* With Estimation of the Secondary Path (Assumed Unknown)
% ----------------------------------------
%	Author: Yosuke Sugiura
%	Created: 2019.5.13
end

