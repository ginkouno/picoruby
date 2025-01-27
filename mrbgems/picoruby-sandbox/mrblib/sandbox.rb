require 'io/console'

class Sandbox

  class Abort < Exception
  end

  TIMEOUT = 10_000 # 10 sec

  def wait(signal: true, timeout: TIMEOUT)
    n = 0
    # state 0: TASKSTATE_DORMANT == finished
    while self.state != 0 do
      if signal && (line = STDIN.read_nonblock(1)) && line[0]&.ord == 3
        puts "^C"
        interrupt
        return false
      end
      sleep_ms 50
      if timeout
        n += 50
        if timeout < n
          puts "Error: Timeout (sandbox.state: #{self.state})"
          return false
        end
      end
    end
    return true
  end

  def load_file(path, signal: true)
    f = File.open(path, "r")
    begin
      return nil unless rb = f.read
      started = if rb.to_s.start_with?("RITE0300")
        # assume mruby bytecode
        exec_mrb(rb)
      else
        # assume Ruby script
        if compile(rb)
          execute
        else
          # TODO: detailed error message
          raise RuntimeError, "#{path}: compile failed"
        end
      end
      if started && wait(signal: signal, timeout: nil) && error
        puts "#{error.message} (#{error})"
      end
    ensure
      f.close
    end
  end
end
