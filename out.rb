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
S = 44000.0 #標本化周波数

time = Array.new
N.times do |n|
    time << n
end

fs = S #標本化周波数
bits = 16 #量子化精度
N.times do |n| #波の作成
  num = 2 * PI * n / fs
end

fe = 2000.0 / fs #エッジ周波数 1000Hzに設定する 数字をかえてエッジ周波数を変更
delta = 1000.0 / fs #遷移帯域幅

dn = (3.1 / delta + 0.5) - 1 #遅延器の数 畳み込むフィルタの大きさ
dn = dn.to_i
if (dn % 2) == 1; dn += 1; end #dn+1が奇数になるように調整する 二倍した時に偶数にするため

w = Array.new(dn + 1, 1)
b = Array.new(dn + 1, 0)
w = hanning(w, (dn + 1)) #全て1の信号にハミング窓をかける

fir_lpf(fe, dn, b, w) #------------------------------------------------

#-----------------------------------------
point = Array.new
(dn + 1).times do |n|
  if n < dn 
    point << -(dn / 2 - n) * (2 * PI / dn)
  else
    point << (n - dn / 2)* (2 * PI / dn) 
  end
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.terminal 'postscript eps enhanced color solid "Times-Roman" 23'
    plot.set 'output', "./eps/sinc_2000_win.eps"
    plot.xlabel "Freqency[rad]"
    plot.xrange "[#{point[0]}:#{point[-1]}]"
    plot.xtics "('-π' #{point[0]},'0' 0, 'π' #{point[-1]})"
    plot.ytics "('0' 0)"
    plot.set "grid lt 0 lw 3"
    plot.noborder
    plot.nokey
    plot.data << Gnuplot::DataSet.new( [point, b] ) do |ds|
      ds.with = "lines"
      ds.linewidth = 1.5
    end
  end
end
#-----------------------------------------

fs = S #標本化周波数

real = Array.new(1024, 0)
image = Array.new(1024, 0)

dn.times do |n|
  real[n] = b[n]
end

dft = FFTW3.fft(real, -1) / N
real = dft.real
image = dft.image

real.length.times do |n|
  real[n] = real[n] ** 2 + image[n] ** 2
  real[n] = 20 * sqrt(real[n])
end

temp = Array.new((N * 2), 0)
temp = real[0..(N / 2)].reverse
temp = temp.to_a + real[0..(N / 2)].to_a

#-----------------------------------------
point = Array.new
N.times do |n|
  if n < N
    point << -(N / 2 - n) * (2 * PI / N)
  else
    point << (n - N / 2)* (2 * PI / N) 
  end
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.terminal 'postscript eps enhanced color solid "Times-Roman" 23'
    plot.set 'output', "./eps/sinc_freq_2000_win.eps"
    plot.xlabel "Freqency[rad]"
    plot.xrange "[#{point[0]}:#{point[-1]}]"
    plot.yrange "[0:#{temp.max * 1.5}]"
    plot.xtics "('-π' #{point[0]},'0' 0, 'π' #{point[-1]})"
    plot.ytics "('0' 0)"
    plot.set "grid lt 0 lw 3"
    plot.noborder
    plot.nokey
    plot.data << Gnuplot::DataSet.new( [point, temp] ) do |ds|
      ds.with = "lines"
      ds.linewidth = 1.5
    end
  end
end
