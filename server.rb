require 'socket'
require 'base64'
require 'json'

PORT = 4876
@server = TCPServer.new PORT
@filenums = {}
CONFIG = JSON.parse(File.read('config.json'))

loop do
    Thread.start(@server.accept) do |socket|
        puts "\e[32;1mConnected to \e[0m\e[32m#{socket.addr[2]}\e[1m.\e[0m"
        loop do
            input = socket.gets
            puts "\e[32;1mReceived command #{input} from \e[0m\e[32m#{socket.addr[2]}\e[1m.\e[0m"
            command = input.split(' ')
            case command[0].downcase
            when 'exists'
                a = true
                unless command[2].nil? && command[2] == 'gz'
                    a = CONFIG[command[1]]['isgz'] == true
                end
                if CONFIG[command[1]].nil? && a
                    socket.puts 'no'
                else
                    socket.puts CONFIG[command[1]]['filenum']
                    @filenums[CONFIG[command[1]]['filenum']] = CONFIG[command[1]]
                end
            when 'get'
                socket.puts Base64.encode64(File.read(@filenums[command[1].to_i]['file'])).gsub("\n", '')
            when 'close'
                puts "\e[1m----------------------\e[0m"
                puts "\e[32;1mSocket closed. (\e[0m\e[32m#{socket.addr[2]}\e[1m)\e[0m"
                socket.close
                break
            end
        end
    end
end
