include Math

def fft(num, real, image)
  num_of_stage = log2(num)

  0.upto(num_of_stage) do |stage|
    ((stage - 1) ** 2).times do |m|
      ((num_of_stage - stage) ** 2).times do |n|

      


