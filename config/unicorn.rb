# -*- coding: utf-8 -*-
# ワーカーの数
worker_processes 2
 
# capistrano 用に RAILS_ROOT を指定
working_directory "/usr/local/study_site/"

listen '/tmp/unicorn.sock', :backlog => 1
listen 3000, :tcp_nopush => true

pid '/tmp/unicorn.pid'

timeout 10

stdout_path '/usr/local/study_site/log/unicorn.stdout.log'
stderr_path '/usr/local/study_site/log/unicorn.stderr.log'

preload_app  true
GC.respond_to?(:copy_on_write_friendly=) and GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  sleep 1
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
