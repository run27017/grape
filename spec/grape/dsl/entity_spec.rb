# frozen_string_literal: true

require 'spec_helper'

module Grape
  module DSL
    module EntitySpec
      class Dummy
        extend Grape::DSL::Entity
      end
    end
    describe Entity do
      subject { Class.new(EntitySpec::Dummy) }

      describe '.entity' do
        it 'sets an entity class' do
          entity_class = Class.new(Grape::Entity)

          subject.entity entity_class
          expect(subject.route_setting(:entity)).to eql(entity_class)
        end

        it 'sets an block' do
          current_class = nil

          subject.entity do
            current_class = self
            def foo; end
          end

          entity_class = subject.route_setting(:entity)
          expect(entity_class).to eql(current_class)
          expect(entity_class.superclass).to eql(Grape::Entity)
          expect(entity_class.instance_method(:foo)).to_not be_nil
        end
      end
    end
  end
end
