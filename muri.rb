require 'gnuplot'
require 'narray'
require 'numru/fftw3'
include Math
include NumRu
require './lib/plot.rb'

N = 256
SAMPLE = 500 #畳み込むフィルタの大きさ
wave = Array.new(N * 8, 0)

wave.fill(1, 0, omega)
