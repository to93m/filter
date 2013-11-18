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
#S = 16000.0 #標本化周波数
S = 16000.0 #標本化周波数

wave = Array.new(N, 0)
wave2 = Array.new(N, 0)

time = Array.new
time_c = 1 / S
N.times do |n|
  time << time_c * n
end

hz = Array.new
hz_c = S / N
N.times do |n|
  hz << hz_c * n
end

hz2 = Array.new
50.times do |n|
  hz2 << hz_c * n
end

fs = S #標本化周波数
bits = 16 #量子化精度
N.times do |n| #波の作成
  num = 2 * PI * n / fs
#=begin
  wave[n] += 10 * sin(num * 200)
  #wave[n] += 10 * sin(num * 500)
  #wave[n] += 10 * sin(num * 2000)
  #wave[n] += 10 * sin(num * 4000)
#=end
#wave[50] = 1
  #if n > 50 && n < 100
  #wave[n] = 1
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
  real[n] = 20 * sqrt(real[n])
end
#=end

#t_plot(time, wave, "before_wave")
#o_plot(time, wave, "Time[ms]", " ", "before_wave")
#t_plot(hz2, real, "before_real")

fe = 1000.0 / fs #エッジ周波数 1000Hzに設定する 数字をかえてエッジ周波数を変更
delta = 1000.0 / fs #遷移帯域幅 

dn = (3.1 / delta + 0.5) - 1 #遅延器の数 畳み込むフィルタの大きさ
dn = dn.to_i
if (dn % 2) == 1; dn += 1; end #dn+1が奇数になるように調整する 二倍した時に偶数にするため

w = Array.new(dn + 1, 1)
b = Array.new(dn + 1, 0)
w = hanning(w, (dn + 1)) #全て1の信号にハミング窓をかける

fir_lpf(fe, dn, b, w) #------------------------------------------------

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

point = Array.new
(dn + 1).times do |n|
  if n < dn 
    point << -(dn / 2 - n) * (2 * PI / dn)
  else
    point << (n - dn / 2)* (2 * PI / dn) 
  end
end

#t_plot(time, real, "lpf_freq")
=begin
Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    #plot.yrange "[0:2]"
    #plot.terminal 'postscript eps enhanced color solid "Times-Roman" 23'
    #plot.set 'output', "./eps/sinc.eps"
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
=end

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

#t_plot(time, wave2, "after_wave")
#o_plot(time, wave2, "Time[ms]", " ", "after_wave")
#t_plot(hz2, real, "after_real")
#d_plot(time, wave, wave2)
Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.terminal 'postscript eps enhanced color solid "Times-Roman" 23'
    plot.set 'output', "./eps/double_wave.eps"
    plot.xrange "[#{time[0]}:#{time[-1]}]"
    plot.nokey
    plot.xlabel "Time[ms]"
    #plot.ylabel ""

    plot.data << Gnuplot::DataSet.new( [time, wave] ) do |ds|
      ds.with = "lines"
      ds.linewidth = 2
    end
    plot.data << Gnuplot::DataSet.new( [time, wave2] ) do |ds|
      ds.with = "lines"
      ds.linewidth = 2
      ds.linecolor = "rgb \"blue\""
    end
  end
end
