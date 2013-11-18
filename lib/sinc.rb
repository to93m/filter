include Math

def sinc(num)
  if num == 0
    num = 1
  elsif num != 0
    num = sin(num) / num
  end

  return num
end
