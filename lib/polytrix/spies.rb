module Polytrix
  # # @abstract
  class Spy
    def initialize(app, opts = {})
      @app = app
      @opts = opts
    end

    def call(challenge)
      fail NotImplementedError, 'Subclass must implement #call'
    end

    def self.reports
      @reports ||= {}
    end

    def self.report(type, report_class)
      reports[type] = report_class
    end
  end

  module Spies
    class << self
      attr_reader :spies

      def spies
        @spies ||= Set.new
      end

      def register_spy(spy)
        spies.add(spy)
      end

      def reports
        # Group by type
        all_reports = spies.flat_map do |spy|
          spy.reports.to_a if spy.respond_to? :reports
        end
        all_reports.reduce({}) do |h, (k, v)|
          (h[k] ||= []) << v
          h
        end
      end
    end
  end
end