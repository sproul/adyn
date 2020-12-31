j = 0
loop do
        break if j >= ARGV.length
        case ARGV[j]
        when "-url"
                puts "saw -url"
        else
                puts "unrecognized arg #{ARGV[j]}"
                Kernel.exit
        end
end
