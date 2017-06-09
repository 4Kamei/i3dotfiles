require 'i3ipc'
require 'listen'

listener = Listen.to("..") do |mod, add, rem|
  str = mod[0][-10..-1]
  if str == "theme_info"
    puts "UPDATING COLOURS"
  end
end

begin
listener.start
rescue
  puts "test"
end
name_map = {}
focused =

i3 = I3Ipc::Connection.new
work = i3.workspaces


work.each { |e|
  puts e
  name_map[e.num] = e.name[2..-1]
}

name_map.each { |key, value| puts "workspace #{key} has name #{value}"}

block = Proc.new do |reply|
  if reply.change == "focus"
    focused = reply.current.num

  else
    puts "Unknown change #{reply.change}"
  end
end

pid = i3.subscribe('workspace', block)
pid.join
