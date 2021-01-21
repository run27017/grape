# frozen_string_literal: true

module Grape
  module DSL
    module Entity
      include Grape::DSL::Settings

      def entity(klass = nil, &block)
        if klass
          route_setting :entity, klass
        elsif block_given?
          route_setting :entity, Class.new(Grape::Entity, &block)
        else
          throw ArgumentError, 'It should pass an entity class or a block'
        end
      end
    end
  end
end
