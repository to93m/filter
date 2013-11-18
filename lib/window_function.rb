include Math

def hanning(wave, j)
  p = 2 * PI / (j - 1)
  wave.length.times do |n|
    co = 0.5 - cos(n * p) * 0.5
    wave[n] = wave[n] * co
  end

  return wave
end

def hamming(wave, j)
  p = 2 * PI / (j - 1)
  wave.length.tiems do |n|
    co = 0.54 - cos(n * p) * 0.46
    wave[n] = wave[n] * co
  end

  return wave
end
