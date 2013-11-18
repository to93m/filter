#sinc()と矩形波とを畳み込み
#矩形波は50サンプル用意
#sinc関数は20サンプル

include Math
require './window_function.rb'
require './plot.rb'
require './sinc.rb'
require './fir_filter'
require './dft.rb'

N = 50
SINC = 50
OUT = N + SINC

time = Array.new
N.times do |n|
  time << n
end

time2 = Array.new
OUT.times do |n|
  time2 << n
end

time3 = Array.new
SINC.times do |n|
  time3 << n
end

wave = Array.new(N, 1)
wave2 = Array.new(N + SINC, 0)
sinc_w = Array.new(SINC, 0)

SINC.times do |n|
  sinc_w[n] = sinc(n)
end

plot(time3, sinc_w)

#畳み込み
N.times do |m|
  SINC.times do |n|
    if m - n >= 0
      wave2[m] += sinc_w[n] * wave[m - n]
    end
  end
end

plot(time2, wave2)

real = Array.new(OUT, 0)
image = Array.new(OUT, 0)

real, image = dft(OUT, wave2, image)

OUT.times do |n|
    real[n] = real[n] ** 2 + image[n] ** 2
      real[n] = sqrt(real[n])
end

plot(time2, real)
