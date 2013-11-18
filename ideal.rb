require 'gnuplot'
require 'narray'
require 'numru/fftw3'
include Math
include NumRu
require './lib/plot.rb'

N = 63
SAMPLE = 100 #畳み込むフィルタの大きさ
wave = Array.new(N * 8, 0)
#-------------------------------------------------
omega = (N * 0.8).to_i
#num = (N / 2) - omega
#num2 = (N / 2) + omega
#wave.fill(1, num, num2) #理想的な周波数特性
wave.fill(1, 0, omega) #理想的な周波数特性
wave_temp = wave[0..SAMPLE].reverse
wave_temp = wave_temp + wave[0..SAMPLE]

#-------------------------------------------------
real = Array.new((N * 8), 0) #逆フーリエ変換
image = Array.new((N * 8), 0)

idft = FFTW3.fft(wave, 1) / (N * 8)
real = idft.real
image = idft.image

real.length.times do |n|
  real[n] = real[n] ** 2 + image[n] ** 2
  real[n] = 20 * sqrt(real[n]) #理想的なフィルタの振幅
end

#-------------------------------------------------
temp = Array.new(SAMPLE, 0) #畳み込むための波をつくる
temp2 = Array.new
temp = real[0..(SAMPLE / 2)].reverse
temp = temp.to_a + real[0..(SAMPLE / 2)].to_a

hz = Array.new
temp.length.times do |n|
  hz << n
end

point = Array.new
wave_temp.length.times do |n|
  point << n - wave_temp.length / 2
end

#t_plot(hz, wave, "wave")
Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    #plot.terminal 'postscript eps enhanced color solid "Times-Roman" 23'
    #plot.set 'output', "./eps/ideal_filter.eps"
    plot.xlabel "Freqency[rad]"
    plot.xrange "[#{point[0]}:#{point[-1]}]"
    plot.yrange "[0:2.5]"
    plot.nokey
    plot.xtics "('π' #{point[0]}, '-ωc' #{point[SAMPLE - omega]}, '0' 0, 'ωc' #{point[SAMPLE + omega]}, 'π' #{point[-1]})"
    plot.noytics
    plot.set "grid"
    plot.data << Gnuplot::DataSet.new( [point, wave_temp] ) do |ds|
      ds.with = "lines"
      ds.linewidth = 2
    end
  end
end

point = Array.new
temp.length.times do |n|
  point << n - temp.length / 2
end
#plot(hz, temp) #理想的なフィルタの振幅
Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    #plot.terminal 'postscript eps enhanced color solid "Times-Roman" 23'
    #plot.set 'output', "./eps/ideal_filter_spec.eps"
    plot.xrange "[#{point[0]}:#{point[-1]}]"
    plot.yrange "[0:2.5]"
    plot.nokey
    plot.xtics "('π' #{point[0]}, '0' 0, 'π' #{point[-1]})"
    plot.noytics
    plot.set "grid"
    plot.data << Gnuplot::DataSet.new( [point, temp] ) do |ds|
      ds.with = "lines"
      ds.linewidth = 2
    end
  end
end

#-------------------------------------------------
wave2 = Array.new(N * 8, 0) #理想的なフィルタを畳み込む
wave3 = Array.new(N * 8, 0)
wave2.fill(1, 0,128)
#wave2[0] = 1

wave2.length.times do |m| #畳み込み
  SAMPLE.times do |n|
    if m - n >= 0
      wave3[m] += real[n] * wave2[m - n]
    end
  end
end

hz = Array.new
N.times do |n|
  hz << n
end
#t_plot(hz, wave2, "wave2")
#t_plot(hz, wave3, "conv")

#-------------------------------------------------
#dft = FFTW3.fft(wave3, -1) / (N * 8)
dft = FFTW3.fft(temp, -1) / (N * 8)
real = dft.real
image = dft.image
dB = Array.new

real.length.times do |n|
  real[n] = real[n] ** 2 + image[n] ** 2
  real[n] = 20 * sqrt(real[n])
end

hz = Array.new
N.times do |n|
  hz << n
end
#plot(hz, real) #理想的なフィルタから求めた周波数特性

