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

N = 256 #波の長さ
S = 8000.0 #標本化周波数

wave = Array.new(N, 0)
wave2 = Array.new(N, 0)

time = Array.new
time_c = 1 / S
256.times do |n|
    time << time_c * n
end

hz = Array.new
hz_c = S / 1024
N.times do |n|
  hz << hz_c* n
end

N.times do |n|
  num = 2 * PI * n / S
  wave[n] += sin(num * 100)
  wave[n] += sin(num * 2000)
  wave[n] += sin(num * 3000)
end

plot(time, wave)

real = Array.new(N, 0)
image = Array.new(N, 0)

real, image = dft(N, wave, image)

#real.length.times do |n|
#  real[n] = real[n] ** 2 + image[n] ** 2
#  real[n] = sqrt(real[n])
#end

real, image = idft(N, real, image)
real.length.times do |n|
  wave2[n] = real[n] ** 2 + image[n] ** 2
  wave2[n] = sqrt(wave2[n])
end

plot(hz, real)

x = 500 / hz_c
x = x.to_i
real.fill(0, x..-x)

#plot(hz, real)

real, image = idft(N, real, image)
real.length.times do |n|
  wave2[n] = real[n] ** 2 + image[n] ** 2
end

plot(hz, wave2)
