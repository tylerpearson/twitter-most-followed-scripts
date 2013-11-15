File.open('nmc.txt', 'r') do |f1|
  index = 1
  while line = f1.gets
    username = line.slice(0..(line.index(' '))).chop
    stats = line.slice((line.index(' ')..-1))
    puts "#{index}. [#{username}](http://twitter.com/#{username}) #{stats}"
    index += 1
  end
end