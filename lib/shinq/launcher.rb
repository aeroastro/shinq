require 'shinq/client'
require 'active_support/inflector'

module Shinq
  module Launcher
    def initialize
      Shinq.clear_all_connections!
    end

    # Wait configured queue and proceed each of them until stop.
    # @see Shinq::Configuration#abort_on_error
    def run
      worker_name = Shinq.configuration.worker_name
      worker_class = Shinq.configuration.worker_class

      @loop_count = 0

      until @stop
        begin
          queue = Shinq::Client.dequeue(table_name: worker_name.pluralize)
          next Shinq.logger.info("Queue is empty (#{Time.now})") unless queue

          if Shinq.configuration.abort_on_error
            worker_class.new.perform(queue)
            Shinq::Client.done
          else
            Shinq::Client.done
            worker_class.new.perform(queue)
          end

          Shinq.clear_all_connections!
        rescue => e
          Shinq.logger.error(format_error_message(e))
          sleep Shinq.configuration.sleep_sec_on_error

          Shinq::Client.abort if Shinq.configuration.abort_on_error && queue
          Shinq.clear_all_connections!
          break
        end

        @loop_count += 1

        if lifecycle_limit?
          Shinq.logger.info("Lifecycle Limit pid(#{Process.pid})")
          break
        end
      end
    end

    def stop
      @stop = true
    end

    def lifecycle_limit?
      return false unless Shinq.configuration.lifecycle
      return (Shinq.configuration.lifecycle < @loop_count)
    end

    private

    def format_error_message(error)
      if defined?(::Rails) && ::Rails.backtrace_cleaner
        backtrace = ::Rails.backtrace_cleaner.clean(error.backtrace || []).presence || error.backtrace
      else
        backtrace = error.backtrace
      end
      "#{error.message} at #{backtrace.join('  <<<   ')}"
    end
  end
end
