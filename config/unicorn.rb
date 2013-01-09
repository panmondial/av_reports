# If you have a very small app you may be able to
# increase this, but in general 3 workers seems to
# work best
worker_processes 3

# Load your app into the master before forking
# workers for super-fast worker spawn times
preload_app true

# Immediately restart any workers that
# haven't responded within 30 seconds
timeout 30


before_fork do |_server, _worker|
  Signal.trap 'TERM' do
    puts 'intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end
end

# Fix PostgreSQL SSL error
# http://stackoverflow.com/a/8513432/235297
after_fork do |server, worker| 
  defined?(ActiveRecord::Base) and 
  ActiveRecord::Base.establish_connection 
end
