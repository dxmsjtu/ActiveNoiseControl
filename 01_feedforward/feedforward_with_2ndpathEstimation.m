% 能动噪声控制（前馈型）
% * 带有次级路径估计（系统辨识法）
% ----------------------------------------
% 作者： 杉浦阳介
% 创建日期： 2019.4.11
clear all; close all;

%% 设定变量（任意设定）
%-------------------------------------
% 扬声器和麦克风之间的距离（厘米）
Dist_1st = 10;  % 一次路径的距离（厘米）
Dist_2nd = 3;   % 次级路径的距离（厘米）

% 自适应滤波器的阶数
N_1st = 120;  % 噪声控制滤波器 W(z) 的阶数
N_2nd = 100;  % 次级路径模型 C_h(z) 的阶数

% 自适应滤波器的设置
mu = 0.02;    % 更新步长 for 噪声控制滤波器
mu_h = 0.01;  % 更新步长 for 次级路径模型
g_p = 0.9;    % 用于NLMS的平均参数
L_preEst = 10000;  % 用于预估计的初始样本长度
%-------------------------------------
%% 获取噪声
[s, fs] = audioread('../00_data/cleaner.wav');  % 噪声信号
len = length(s);

%% 获取脉冲响应（不要修改）
Imp_1st = csvread('../00_data/impulse1.dat');  % 一次路径的脉冲响应
Imp_2nd = csvread('../00_data/impulse2.dat');  % 次级路径的脉冲响应
% 创建一次路径的脉冲响应
smpl = max([1, floor(Dist_1st * 0.1 / 340.29 * fs)]);  % 延迟量
if smpl <= 200
    Imp_1st = Imp_1st(200-smpl:end)';
else
    Imp_1st = [zeros(smpl-200, 1); Imp_1st]';
end
L_1st = length(Imp_1st);
% 创建次级路径（扬声器1）的脉冲响应
smpl = max([1, floor(Dist_2nd * 0.01 / 340.29 * fs)]);  % 延迟量
if smpl <= 200
    Imp_2nd = Imp_2nd(200-smpl:end)';
else
    Imp_2nd = [zeros(smpl-200, 1); Imp_2nd]';
end
L_2nd = length(Imp_2nd);
%N_2nd = L_2nd;
%% 初始化数组
% -- 滤波器 --
w = rand(1, N_1st);  % 噪声控制滤波器的系数
ch = zeros(1, N_2nd);  % 次级路径模型的系数（已知）
% -- 缓冲区 --
x_buf = zeros(max([L_1st, N_1st, N_2nd]), 1);  % 参考信号缓冲区
xh_buf = zeros(max([L_2nd, N_2nd]), 1);      % 预估计用滤波后的白噪声缓冲区
y_buf = zeros(max(L_2nd, N_2nd), 1);         % 次级路径缓冲区
r_buf = zeros(1, N_1st);
% -- 结果 --
in = zeros(len, 1);   % 错误麦克风的误差信号
out = zeros(len, 1);  % 结果（误差信号）
% -- 计算用 --
p_in = 1; p_1st = 1;out_2nd = 0;
%% 噪声控制仿真
tic;
% == 预估计 ==
for loop = 1:L_preEst-1    
    % -- 白噪声 --
    xh = randn(1);  % 白噪声
    xh_buf = [xh; xh_buf(1:end-1)];  % 白噪声缓冲区（FILO）    
    % -- 通过次级路径的白噪声 --
    eh = Imp_2nd * xh_buf(1:L_2nd);    
    % -- 滤波后的白噪声 --
    rh = ch * xh_buf(1:N_2nd);      
    % -- 误差 --
    er = rh - eh;    
    % -- NLMS算法 --
    ch = ch - mu_h * er .* xh_buf(1:N_2nd)' ./ mean(xh_buf(1:N_2nd).^2);  % 更新    
end

% == 噪声控制 ==
for loop = 1:len    
    % -- 参考信号 --
    x = s(loop);  % 参考信号
    x_buf = [x; x_buf(1:end-1)];  % 参考信号缓冲区（FILO）    
    % -- 通过一次路径的噪声 --
    out_1st = Imp_1st * x_buf(1:L_1st);    
    % -- 控制信号 --
    out_filter = w * x_buf(1:N_1st);    
    % -- 通过次级路径的控制信号 --
    y_buf = [out_filter; y_buf(1:end-1)];  % 控制信号缓冲区
    out_2nd = Imp_2nd * y_buf(1:L_2nd);  % 通过次级路径的控制信号
    % -- 误差信号 --
    e = out_1st + out_2nd;    
    % -- 滤波后的参考信号 --
    r = ch * x_buf(1:N_2nd);  % 滤波后的参考信号
    r_buf = [r, r_buf(1:end-1)];  % 缓冲区    
    % -- Filtered-X NLMS算法 --
    w = w - mu * e .* r_buf ./ mean(r_buf.^2);  % 更新
    in(loop) = out_1st;
    out(loop) = e;    
end
%% 波形图
% 绘制图表
figure(1);plot((1:len)./fs, in); hold on;plot((1:len)./fs, out); hold off;
% 设置图表
title('误差麦克风获得的波形');xlim([1, len/fs]);xlabel('时间 [s]');ylabel('振幅');
legend('输出（无ANC）', '输出（有ANC）');

% 绘制图表
figure(2);plot(Imp_2nd); hold on;plot(ch); hold off;% 设置图表
title('脉冲响应');xlim([1, max(N_2nd, L_2nd)]);xlabel('样本数');ylabel('振幅');
legend('真实', '估计');

%% 保存wav文件
audiowrite('input.wav', in, fs);audiowrite('output.wav', out, fs);


OldFile =0;
if OldFile==1
%
%	能動騒音制御 (フォードフォワード型)
%	* ２次経路の推定あり(システム同定法)
% ----------------------------------------
%	作成者： 杉浦陽介
%	作成日： 2019.4.11
%

clear;
close all;


%% 設定変数 (任意に設定)
%-------------------------------------
% スピーカ・マイク間距離(cm)
Dist_1st	= 10;				% 1次経路の距離(cm)
Dist_2nd	= 3;				% 2次経路の距離(cm)

% 適応フィルタの次数
N_1st		= 120;				% 騒音制御フィルタ W(z) の次数
N_2nd		= 100;				% ２次経路モデル C_h(z) の次数

% 適応フィルタの設定
mu			= 0.02;				% 更新ステップサイズ for 騒音制御フィルタ
mu_h		= 0.01;				% 更新ステップサイズ for 2次経路モデル
g_p			= 0.9;				% NLMS用平均パラメータ
L_preEst	= 10000;			% 事前推定に用いる初期サンプル長
%-------------------------------------

%% 騒音の取得
[s,fs]		= audioread('../00_data/cleaner.wav');	% 騒音信号
len			= length(s);

%% インパルス応答の取得 (いじらないで)
Imp_1st		= csvread('../00_data/impulse1.dat');	% １次経路のインパルス応答
Imp_2nd		= csvread('../00_data/impulse2.dat');	% ２次経路のインパルス応答

% １次経路のインパルス応答を作成
smpl		= max( [1, floor(Dist_1st* 0.1/340.29 * fs)] ); % 遅延量
if smpl <= 200
	Imp_1st		= Imp_1st(200-smpl:end)';
else
	Imp_1st		= [zeros(smpl-200,1);Imp_1st]';
end
L_1st = length(Imp_1st);

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
ch			= zeros(1,N_2nd);							% ２次経路モデルの係数 (既知)
% -- Buffer --
x_buf		= zeros(max([L_1st,N_1st, N_2nd]),1);		% 参照信号バッファ
xh_buf		= zeros(max([L_2nd,N_2nd]),1);				% 事前推定用 フィルタード白色雑音バッファ
y_buf		= zeros(max(L_2nd,N_2nd),1);				% ２次経路バッファ
r_buf		= zeros(1, N_1st);
% -- 結果 --
in			= zeros(len,1);								% 誤差マイクでの (誤差信号)
out			= zeros(len,1);								% 結果 (誤差信号)
% -- 計算用 --
p_in		= 1;
p_1st		= 1;
out_2nd		= 0;


%% 騒音制御シミュレーション
tic;

% == 事前推定 ==
for loop=1:L_preEst-1
	
	% -- 白色雑音 --
	xh			= randn(1);						% 白色雑音
	xh_buf		= [xh; xh_buf(1:end-1)];		% 白色雑音バッファ (FILO)
	
	% -- ２次経路を通過した白色雑音 --
	eh			= Imp_2nd * xh_buf(1:L_2nd);
	
	% -- フィルタード白色雑音 --
	rh			= ch * xh_buf(1:N_2nd);	
	
	% -- 誤差 --
	er			= rh - eh;
	
	% -- NLMSアルゴリズム --
	ch		= ch - mu_h * er .* xh_buf(1:N_2nd)' ./mean(xh_buf(1:N_2nd).^2);	% 更新
	
end

% == 騒音制御 ==
for loop=1:len
		

	% -- 参照信号 --
	x			= s(loop);						% 参照信号
	x_buf		= [x; x_buf(1:end-1)];			% 参照信号バッファ (FILO)
	
	% -- １次経路を通過した騒音 --
	out_1st		= Imp_1st * x_buf(1:L_1st);
	
	% -- 制御信号 --
	out_filter	= w * x_buf(1:N_1st);
	
	% -- ２次経路を通過した制御信号 --
	y_buf		= [out_filter; y_buf(1:end-1)];	% 制御信号バッファ
	out_2nd		= Imp_2nd * y_buf(1:L_2nd);		% ２次経路を通過した制御信号

	% -- 誤差信号 --
	e			= out_1st + out_2nd;
	
	% -- フィルタード参照信号 --
	r			= ch * x_buf(1:N_2nd);			% フィルタード参照信号
	r_buf		= [r, r_buf(1:end-1)];			% バッファ
		
	% -- Filtered-X NLMSアルゴリズム --
	w			= w - mu * e .* r_buf ./mean(r_buf.^2);	% 更新

	in(loop)	= out_1st;
	out(loop)	= e;
	
end

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

% 図のプロット
figure(2);
plot(Imp_2nd); hold on;
plot(ch); hold off;
% 図の設定
title('Impulse Response');
xlim([1, max(N_2nd,L_2nd)]);
xlabel('Samples');
ylabel('Amplitude');
legend('True','Estimated');


%% wav保存
audiowrite('input.wav',in,fs);
audiowrite('output.wav',out,fs);

end
