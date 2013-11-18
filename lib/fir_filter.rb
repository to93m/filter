def fir_lpf(fe, dn, b, w)
  offset = dn / 2

  (-offset).upto(offset) do |n|
    b[offset + n] = 2.0 * fe * sinc(2.0 * PI * fe * n) 
  end

  (dn + 1).times do |n|
    b[n] *= w[n]
  end
end

def fir_hpf(fe, dn, b, w)
  offset = dn / 2

  (-offset).upto(offset) do |n|
    b[offset + n] = sinc(PI * n) - 2.0 * fe * sinc(2.0 * PI * fe * n)
  end

  (dn + 1).times do |n|
    b[n] *= w[n]
  end
end
