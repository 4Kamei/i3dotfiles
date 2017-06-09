require 'i3ipc'
require 'listen'

def message (m)
  $message = m
  $pipe.puts "%{l}>>#{$message} %{r}#{Time.now}"
end
name_map = {}
focused = ""
$message = ""

listener = Listen.to("..") do |mod, add, rem|
  str = mod[0][-10..-1]
  if str == "theme_info"
  end
end
listener.start

i3 = I3Ipc::Connection.new
work = i3.workspaces

work.each { |e|
  name_map[e.num] = e.name[2..-1]
}

block = Proc.new do |reply|
  if reply.change == "focus"
    message reply.current.name
  else
    puts "Unknown change #{reply.change}"
  end
end

pid = i3.subscribe('workspace', block)
i3List = Thread.new{pid.join()}
Signal.trap("PIPE", "EXIT")

$pipe = IO.popen("sh bar", "r+")

last = Time.now
while true
    $pipe.puts "%{l}>>#{$message} %{r}#{Time.now}"
    now = Time.now
    _next = [last + 1,now].max
    sleep (_next-now)
    last = _next
end
