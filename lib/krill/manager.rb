module Krill

  class ThreadStatus
    attr_accessor :running
  end

  class Manager

    attr_accessor :thread

    def initialize jid

      # Start new thread
      @mutex = Mutex.new
      @thread_status = ThreadStatus.new      
      @thread_status.running = false

      # Get job info
      @jid = jid
      @job = Job.find(jid)
      @code = Repo::contents @job.path, @job.sha
      initial_state = JSON.parse @job.state, symbolize_names: true
      @args = initial_state[0][:arguments]

      # Create Namespace
      @namespace = Krill::make_namespace @code

      # Add base_class ancestor to user's code
      @base_class = make_base
      insert_base_class @namespace, @base_class

      # Make a base object
      @base_object = Class.new.extend(@base_class)

      # Make protocol
      @protocol = @namespace::Protocol.new

    end

    def run

      @thread = Thread.new { 

        begin

          @mutex.synchronize { @thread_status.running = true }

          @job.reload.pc = 0
          @job.save

          begin 
            @protocol.main
          rescue Exception => e
            puts "#{@job.id}: EXCEPTION #{e.to_s} + #{e.backtrace[0,10]}"
            @base_object.error e
          end

          @job.reload.pc = Job.COMPLETED
          @job.save

          @base_object.send( :append_step, { operation: "complete" } )
          ActiveRecord::Base.connection.close

          @mutex.synchronize { @thread_status.running = false }

        rescue Exception => main_error

          puts "#{@job.id}: SERIOUS EXCEPTION #{main_error.to_s}: #{main_error.backtrace[0,10]}"

        end

      }

    end

    def wake

      @mutex.synchronize { @thread_status.running = true }
      @thread.wakeup
      temp = true
      @mutex.synchronize { temp = @thread_status.running }
      while temp
        sleep(0.1) # keeps the processing from being a hog?
        @mutex.synchronize { temp = @thread_status.running }
      end

    end

    def continue

      if @thread.alive?
        wake
      end

      @thread.alive?

    end

    def make_base

      b = Module.new
      b.send(:include,Base)
      b.module_eval "def jid; #{@jid}; end"
      b.module_eval "def input; #{@args}; end"

      manager_mutex = @mutex
      b.send :define_method, :mutex do
        manager_mutex
      end

      manager_thread_status = @thread_status
      b.send :define_method, :thread_status do
        manager_thread_status
      end

      b

    end

    def insert_base_class obj, mod

      obj.constants.each do |c|

        k = obj.const_get(c)

        if k.class == Module
          k.eigenclass.send(:include,mod) unless k.eigenclass.include? mod
          insert_base_class k, mod
        elsif k.class == Class
          k.send(:include,mod) unless k.include? mod
          insert_base_class k, mod
        end

      end

    end

  end
 
end