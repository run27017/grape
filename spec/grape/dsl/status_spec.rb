# frozen_string_literal: true

require 'spec_helper'

module Grape
  module DSL
    module StatusSpec
      class Dummy
        extend Grape::DSL::Status
      end
    end
    describe Status do
      subject { Class.new(StatusSpec::Dummy) }

      describe '.status' do
        it 'sets status code and entity class' do
          sucess_entity = Class.new(Grape::Entity)
          fail_entity = Class.new(Grape::Entity)

          subject.status 200, sucess_entity
          subject.status 400, fail_entity

          status_setting = subject.route_setting(:status)
          expect(status_setting[200]).to include(entity: sucess_entity)
          expect(status_setting[400]).to include(entity: fail_entity)
        end

        it 'sets status code by symbol' do
          sucess_entity = Class.new(Grape::Entity)
          fail_entity = Class.new(Grape::Entity)

          subject.status :ok, sucess_entity
          subject.status :bad_request, fail_entity

          status_setting = subject.route_setting(:status)
          expect(status_setting[200]).to include(entity: sucess_entity)
          expect(status_setting[400]).to include(entity: fail_entity)
        end

        it 'sets entity class by block' do
          current_class = nil

          subject.status 200 do
            current_class = self
            def foo; end
          end

          entity_class = subject.route_setting(:status)[200][:entity]
          expect(entity_class).to eql(current_class)
          expect(entity_class.superclass).to eql(Grape::Entity)
          expect(entity_class.instance_method(:foo)).to_not be_nil
        end

        it 'sets message and entity class' do
          entity_class = Class.new(Grape::Entity)

          subject.status 200, 'message', entity_class

          status_setting = subject.route_setting(:status)
          expect(status_setting[200]).to eq(entity: entity_class, message: 'message')
        end

        it 'sets message and block' do
          subject.status 200, 'message' do
            expose :foo
          end

          status_setting = subject.route_setting(:status)
          expect(status_setting[200]).to include(message: 'message')
          expect(status_setting[200][:entity]).to be < Grape::Entity
        end
      end

      describe 'alias methods' do
        def resolve_method(example)
          example.metadata[:example_group][:parent_example_group][:description][1..-1]
        end

        shared_examples 'an alias of status method' do |options|
          it 'is an alias of status method' do |example|
            method = resolve_method(example)
            codes = options[:codes]

            settings = codes.map { |code| [code, Class.new] }
            settings.each { |code, klass| subject.send method, code, klass }

            status_setting = subject.route_setting(:status)
            settings.each do |code, klass|
              expect(status_setting[code]).to include(entity: klass)
            end
          end
        end
        shared_examples 'specify default entity class' do |options|
          it 'specifies default entity when status not matched' do |example|
            method = resolve_method(example)
            key = options[:key]

            entity_class = Class.new(Grape::Entity)

            subject.send method, entity_class
            expect(subject.route_setting(:status)[key]).to include(entity: entity_class)
          end
        end
        shared_examples 'validates status code' do |options|
          it 'validates status code' do |example|
            method = resolve_method(example)
            code = options[:code]

            expect do
              subject.send method, code, Class.new(Grape::Entity)
            end.to raise_error(ArgumentError)
          end
        end

        describe '.entity' do
          it_behaves_like 'an alias of status method', codes: [200, 400]
          it_behaves_like 'specify default entity class', key: :default
        end
        describe '.success' do
          it_behaves_like 'an alias of status method', codes: [200, 201]
          it_behaves_like 'validates status code', code: 400
          it_behaves_like 'specify default entity class', key: :success
        end
        describe '.fail' do
          it_behaves_like 'an alias of status method', codes: [400, 500]
          it_behaves_like 'validates status code', code: 200
          it_behaves_like 'specify default entity class', key: :fail
        end
      end
    end
  end
end
