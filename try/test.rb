while true
	sleep 1
	File.open('log', 'a') do |line|
		line.puts ARGV[0]
	end
end