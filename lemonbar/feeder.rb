require 'i3ipc'
require 'listen'
require 'pp'

def c (code)
  $colData[code]
end

def print (o = nil)
  $message = o if ! o.is_a? NilClass
  $pipe.puts "%{B#{c 1}}%{l} %{B#{c 0}}|#{$focused}|%{B#{c 1}} - #{$workspace_string}%{c}>>#{$message} %{r}%{F#{c 2}}#{Time.now}      "
end

def parseColours
  lines = File.readlines("../theme_info")
  for i in 1...lines.length
    d = lines[i].split(": ")
    $colData[d[0].gsub(/[^0-9]*/, "").to_i] = "##{d[1].gsub(/[^0-9A-F]/, '')}"
  end
  pp $colData
end

name_map = {}
$focused = ""
$message = ""
$colData={}
parseColours

listener = Listen.to("..", only:/theme_info$/, latency:5) { parseColours }
listener.start

i3 = I3Ipc::Connection.new
work = i3.workspaces

work.each { |e|
  name_map[e.num] = e.name[2..-1]
}

block = Proc.new do |reply|
  puts reply.change
  if reply.change == "focus"
    $focused = name_map[reply.current.num]
  elsif reply.change == "rename"
    name_map[reply.current.num] = reply.current.name[2..-1]
  else
    puts "Unknown change #{reply.change}"
  end
  print
end

pid = i3.subscribe('workspace', block)
i3List = Thread.new{pid.join()}
Signal.trap("PIPE", "EXIT")

$pipe = IO.popen("sh bar", "r+")

last = Time.now
while true
    print
    now = Time.now
    _next = [last + 1,now].max
    sleep (_next-now)
    last = _next
end
