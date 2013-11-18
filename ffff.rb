require 'gnuplot'
require 'narray'
require 'numru/fftw3'
include Math
include NumRu
require './window_function.rb'
require './plot.rb'
require './sinc.rb'
require './fir_filter'
require './dft.rb'

N = 2000 #波の長さ
S = 8000.0 #標本化周波数

wave = Array.new(N, 0) #sinc関数を作る(半分)
wave2 = Array.new #sinc関数の振幅特性
result = Array.new(N + 1, 0)
inp = Array.new(1, 1)

time = Array.new
time_c = 1 / S
(2 * N).times do |n|
    #time << time_c * n
    time << n
end

time2 = Array.new
100.times do |n|
    time2 << n
end

fs = S #標本化周波数
N.times do |n| #波の作成
    num = 2 * PI * n / fs
    wave[n] += sinc(num * 50)
end

wave2 = wave[0..N].reverse
wave2 = wave2 + wave[0..N] #繋げてる
  
plot(time, wave2)
plot(time2, wave)

real = Array.new((2 * N), 0)
image = Array.new((2 * N), 0)
dB = Array.new

real, image = dft((2 * N), wave2)

real.length.times do |n|
  real[n] = real[n] ** 2 + image[n] ** 2
  dB << 10 * log10(real[n])
end

plot(time2, dB)
