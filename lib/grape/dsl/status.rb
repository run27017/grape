# frozen_string_literal: true

module Grape
  module DSL
    module Status
      include Grape::DSL::Settings

      def status(code, klass = nil, &block)
        if code.is_a?(Symbol) && ![:success, :fail, :default].include?(code)
          raise ArgumentError: "Status code #{code} is invalid." unless Rack::Utils::SYMBOL_TO_STATUS_CODE.key?(code)
          code = Rack::Utils::SYMBOL_TO_STATUS_CODE[code]
        end

        unless klass
          if block_given?
            klass = Class.new(Grape::Entity, &block)
          else
            throw ArgumentError, 'It should pass an entity class or a block'
          end
        end

        status_setting = route_setting(:status) || {}
        status_setting[code] = klass
        route_setting :status, status_setting
      end

      define_status_alias = ->(method, options) do
        valid_status_range = options[:valid_status_range]
        error_message = options[:error_message]
        key_name = options[:key_name]

        define_method method do |*args, &block|
          if args[0].is_a?(Integer) || args[0].is_a?(Symbol)
            original_code, *remaining_args = args
            code = original_code

            if code.is_a?(Symbol)
              raise ArgumentError: "Status code #{code} is invalid." unless Rack::Utils::SYMBOL_TO_STATUS_CODE.key?(code)
              code = Rack::Utils::SYMBOL_TO_STATUS_CODE[code]
            end

            raise ArgumentError, error_message.call(original_code) unless valid_status_range.include?(code)

            status(code, *remaining_args, &block)
          else
            status(key_name, *args, &block)
          end
        end
      end

      define_status_alias.call :success,
        valid_status_range: 200...400,
        error_message: ->(code) { "Status code #{code} is not a success code." },
        key_name: :success

      define_status_alias.call :fail,
        valid_status_range: 400...600,
        error_message: ->(code) { "Status code #{code} is not an error code." },
        key_name: :fail

      define_status_alias.call :entity,
        valid_status_range: 100...600,
        error_message: ->(code) { "Status code #{code} is not an valid code." },
        key_name: :default
    end
  end
end
