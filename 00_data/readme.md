Audio and Impulse Response Data
Audio Data
cleaner.wav

Audio wav data of vacuum cleaner noise.
Used in the feedforward control simulation.

Sampling rate: 16 kHz
Channels: Mono
Bit depth: 16-bit
harmonics.wav

Audio wav data of machine noise + narrowband noise.
Used in the feedback control simulation.

Sampling rate: 16 kHz
Channels: Mono
Bit depth: 16-bit
artificial_harmonic.wav

Audio wav data artificially generated (white noise + harmonic signals) by noise_maker.m.
Parameters can be changed in noise_maker.m.
Can be used for debugging in both feedforward and feedback control.

Sampling rate: 16 kHz
Channels: Mono
Bit depth: 16-bit
Impulse Response Data
impulse1.dat

Impulse response of the primary path.

impulse2.dat

Impulse response of the secondary path.

Noise Generation Source Code
noise_maker.m

Creates a wav file of (Gaussian white noise + multiple sine waves).
Allows specification of the frequencies and amplitudes of the sine waves.
Outputs artificial_harmonic.wav.

#  音声・インパルス応答データ

## 音声データ

- **cleaner.wav**

   掃除機騒音の音声wavデータ．  
   フィードフォワード制御のシミュレーションで使用．  
   - サンプリングレート：16k Hz  
   - チャンネル：モノラル
   - 量子化ビット幅：16bit
   
- **harmonics.wav**

   機械騒音＋狭帯域騒音の音声wavデータ．  
   フィードバック制御のシミュレーションで使用．
   - サンプリングレート：16k Hz  
   - チャンネル：モノラル
   - 量子化ビット幅：16bit
   
- **artificial_harmonic.wav**

   ```noise_maker.m```で人工的に生成した(白色雑音＋調波信号)の音声wavデータ．  
   ```noise_maker.m```でパラメータを変更可能．  
   フィードフォワード・フィードバック制御のどちらでもデバッグで使用可能．
   - サンプリングレート：16k Hz  
   - チャンネル：モノラル
   - 量子化ビット幅：16bit
   
## インパルス応答データ

- **impulse1.dat**

   １次経路のインパルス応答．
   
- **impulse2.dat**

   ２次経路のインパルス応答．
   
## 雑音生成ソースコード

- **noise_maker.m**
   
   (ガウス性白色雑音 + 複数正弦波)のwavデータを作成する．  
   正弦波の周波数や振幅等を指定できる．  
   ```artificial_harmonic.wav```を出力する．
