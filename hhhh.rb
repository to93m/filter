require 'gnuplot'
require 'narray'
require 'numru/fftw3'
include Math
include NumRu
require './lib/window_function.rb'
require './lib/plot.rb'
require './lib/sinc.rb'
require './lib/fir_filter'
require './lib/dft.rb'

N = 512 #波の長さ
S = 16000.0 #標本化周波数

wave = Array.new(N, 0)
wave2 = Array.new(N, 0)

time = Array.new
time_c = 1 / S
(N/2).times do |n|
  time << time_c * n
end

hz = Array.new
hz_c = S / N
N.times do |n|
  hz << hz_c * n
end

fs = S #標本化周波数
bits = 16 #量子化精度
N.times do |n| #波の作成
  num = 2 * PI * n / fs
#=begin
  wave[n] += 10 * sin(num * 200)
  #wave[n] += 10 * sin(num * 500)
  wave[n] += 10 * sin(num * 2000)
  wave[n] += 10 * sin(num * 7000)
  wave[n] += 10 * sin(num * 5000)
#=end

  #wave[n] = 1
  #if n > 50 && n < 100
  #wave[n] = 1
  #end

  #if n >= 20 && n <= 70
  #  wave[n] = 10
  #end
end

#=begin #フーリエ変換
real = Array.new(wave.length, 0)
image = Array.new(wave.length, 0)

#real, image = dft(wave)
dft = FFTW3.fft(wave, -1) / N
real = dft.real
image = dft.image

real.length.times do |n|
  real[n] = real[n] ** 2 + image[n] ** 2
  real[n] = 2 * sqrt(real[n])
end
#=end

plot(time, wave)
plot(hz, real)

fe = 6000.0 / fs #エッジ周波数 1000Hzに設定する 数字をかえてエッジ周波数を変更
delta = 7000.0 / fs #遷移帯域幅 

dn = (3.1 / delta + 0.5) - 1 #遅延器の数 畳み込むフィルタの大きさ
dn = dn.to_i
if (dn % 2) == 1; dn += 1; end #dn+1が奇数になるように調整する 二倍した時に偶数にするため

w = Array.new(dn + 1, 1)
b = Array.new(dn + 1, 1)
w = hanning(w, (dn + 1)) #全て1の信号にハミング窓をかける

fir_hpf(fe, dn, b, w) 

#ここから畳み込み
wave.length.times do |m|
  (dn + 1).times do |n|
    if m - n >= 0
      wave2[m] += b[n] * wave[m - n]
    end
  end
end

#=begin #フーリエ変換
real = Array.new(wave2.length, 0)
image = Array.new(wave2.length, 0)
dB = Array.new(wave2.length, 0)

#real, image = dft(wave2)
dft = FFTW3.fft(wave2, -1) / N
real = dft.real
image = dft.image

real.length.times do |n|
  real[n] = real[n] ** 2 + image[n] ** 2
  dB[n] = 10 * log10(real[n])
  real[n] = sqrt(real[n])
end
#=end

#wave = hanning(wave, wave.length)
plot_title(time, wave2, "after_wave")
plot_title(hz, real, "after_real")
#plot_title(hz, dB, "after_dB")
