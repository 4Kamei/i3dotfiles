require 'i3ipc'
require 'listen'

def print (o = nil)
  $message = o if ! o.is_a? NilClass
  $pipe.puts "%{B#77000000}%{l}#{$focused} - #{$workspace_string}%{c}>>#{$message} %{r}#{Time.now}"
end
name_map = {}
$focused = ""
$message = ""

listener = Listen.to("..", only:/theme_info$/, latency:5) do |mod, add, rem|
  lines = File.read(mod[0]).split("\n")
  if lines.length != 1
      colData={}
      for i in 1...lines.length
        d = lines[i].split(": ")
        colData[d[0].to_sym] = d[1]
      end
      puts colData
  end
end
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
    $focused = name_map[reply.current.num]
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
