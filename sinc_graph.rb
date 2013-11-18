#sinc関数のグラフを作成
require './lib/sinc.rb'
require './lib/plot.rb'
require './lib/dft.rb'
include Math
N = 50
M = 50
FS = 5000.0

wave = Array.new(N, 0)
wave2 = Array.new

N.times do |n|
  num = n / 2.0
  wave[n] = sinc(num)
end

time = Array.new
(M * 2).times do |n|
  time << n - M
end

wave2 = wave[0..M].reverse

wave = wave2 + wave[0..M]

plot(time, wave)

