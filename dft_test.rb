require 'narray'
require 'numru/fftw3'
include Math
include NumRu
require './lib/plot.rb'
require './lib/dft.rb'

N = 512
S = 8000.0

wave = Array.new(N, 0)
real = Array.new(N, 0)
image = Array.new(N, 0)
power = Array.new(N, 0)
dB = Array.new(N, 0)

time = Array.new
time_c = 1 / S
(N/2).times do |n|
    time << time_c * n
end

hz = Array.new
hz_c = 4000.0 / N
N.times do |n|
  hz << hz_c * n
end

N.times do |n| #波の作成
  num = 2 * PI * n / S
  wave[n] += 5 * sin(num * 2000)
  wave[n] += 10 * sin(num * 1000)
  #  wave[n] += 10 * sin(num * 2000)
  #    #wave[n] += 10 * sin(num * 4000)
end

#plot(time, wave)

#real, image = dft(wave)
#=begin
dft = FFTW3.fft(wave, -1) / N
real = dft.real
image = dft.image
#=end

N.times do |n|
  power[n] = real[n] ** 2 + image[n] ** 2
  dB[n] = 10 * log10(power[n])
  real[n] = 2 * sqrt(power[n])
end

plot(hz, real)
