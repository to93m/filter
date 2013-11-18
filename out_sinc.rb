#矩形波からsincの出す
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

N = 2048
STEP = N / PI

hz = Array.new
hz_c = PI / N
N.times do |n|
    hz << hz_c * n
end

point = Array.new
100.times do |n|
    point << n
end

wave = Array.new(N, 0)
real = Array.new(N, 0)
image = Array.new(N, 0)

omega = PI / 4.0
wave.fill(1, 0..(omega * STEP))

plot(hz, wave)

idft = FFTW3.fft(wave, 1) / N
real = idft.real
image = idft.image

N.times do |n|
    real[n] = real[n] ** 2 + image[n] ** 2
      real[n] = 2 * sqrt(real[n])
end

plot(point, real)
