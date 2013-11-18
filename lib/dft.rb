include Math

def dft(real)
  num = real.length
  temp_real = Array.new(num, 0)
  temp_image = Array.new(num, 0)

  d = 2.0 * PI / num
  num.times do |m|
    num.times {|n|
      temp_real[m] += real[n] * cos(d * m * n)
      temp_image[m] += real[n] * sin(d * m * n) * (-1)
    }
  end

  return [temp_real, temp_image]
end 

def idft(real, image)
  num = real.length
  temp_real = Array.new(num, 0)
  temp_image = Array.new(num, 0)

  d = 2.0 * PI / num

  num.times do |m|
    num.times {|n|
      real[m] += real[n] * cos(d * n) - image[n] * sin(d * n)
      image[m] += real[n] * sin(d * n) + image[n] * cos(d * n)
      temp_real[m] += real[n] * cos(d * m * n) - image[n] * sin(d * m * n)
      temp_real[m] += image[n] * cos(d * m * n) + real[n] * sin(d * m * n)
    }

    temp_real[m] /= num
    temp_image[m] /= num
  end

  return [temp_real, temp_image]
end 

