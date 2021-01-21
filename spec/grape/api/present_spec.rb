# frozen_string_literal: true

require 'spec_helper'
require 'shared/versioning_examples'

describe Grape::API do
  subject { Class.new(Grape::API) }

  def app
    subject
  end

  describe '.present' do
    context 'with entity dsl' do
      it 'resolves entity class based on key' do
        entity_class = Class.new(Grape::Entity) do
          def inspect
            'entity_class'.inspect
          end
        end

        subject.entity do
          expose :a
          expose :b, using: entity_class
        end

        subject.get do
          present :a, 1
          present :b, nil
        end

        get '/'
        expect(last_response.status).to eql 200
        expect(eval last_response.body).to eql(a: 1, b: 'entity_class')
      end

      it 'resolves entity class based on entity name' do
        class Entity_02 < Grape::Entity
          def inspect
            'entity_class'.inspect
          end
        end

        subject.entity do
          expose :a
          expose :b, using: 'Entity_02'
        end

        subject.get do
          present :a, 1
          present :b, nil
        end

        get '/'
        expect(last_response.status).to eql 200
        expect(eval last_response.body).to eql(a: 1, b: 'entity_class')
      end
    end
  end
end
