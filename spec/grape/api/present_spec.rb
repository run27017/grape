# frozen_string_literal: true

require 'spec_helper'
require 'shared/versioning_examples'

# rubocop:disable Security/Eval
describe Grape::API do
  subject { Class.new(Grape::API) }

  def app
    subject
  end

  def inspected_entity_class(inspected = 'entity_class')
    Class.new(Grape::Entity) do
      define_method(:inspect) { inspected.inspect }
    end
  end

  describe '.present' do
    context 'with status dsl' do
      context 'with entity' do
        it 'resolves entity class based on key' do
          entity_class = inspected_entity_class

          subject.status 200 do
            expose :a
            expose :b, using: entity_class
          end
          subject.get do
            status 200
            present :a, 1
            present :b, 2
          end

          get '/'
          expect(last_response.status).to eql 200
          expect(eval(last_response.body)).to eql(a: 1, b: 'entity_class')
        end

        it 'throws error when presenting undefined fields' do
          subject.status 200 do
            expose :a
          end
          subject.get do
            status 200
            present :a, 1
            present :b, 1
          end

          expect { get('/') }.to raise_error(KeyError)
        end

        it 'resolves entity class based on entity name' do
          Entity_02 = inspected_entity_class

          subject.status 200 do
            expose :a
            expose :b, using: 'Entity_02'
          end
          subject.get do
            status 200
            present :a, 1
            present :b, 2
          end

          get '/'
          expect(last_response.status).to eql 200
          expect(eval(last_response.body)).to eql(a: 1, b: 'entity_class')
        end

        it 'presents without defining status' do
          entity_class = inspected_entity_class

          subject.status 200 do
            expose :a
            expose :b, using: entity_class
          end
          subject.get do
            present :a, 1
            present :b, 2
          end

          get '/'
          expect(last_response.status).to eql 200
          expect(eval(last_response.body)).to eql(a: 1, b: 'entity_class')
        end

        it 'supports namespace scope' do
          entity_class = inspected_entity_class

          subject.status 200 do
            expose :value, using: entity_class
          end
          subject.namespace '/foo' do
            get do
              present :value, 'foo'
            end

            put do
              present :value, 'bar'
            end
          end

          get '/foo'
          expect(last_response.status).to eql 200
          expect(eval(last_response.body)).to eql(value: 'entity_class')

          put '/foo'
          expect(last_response.status).to eql 200
          expect(eval(last_response.body)).to eql(value: 'entity_class')
        end
      end

      context 'without entity' do
        specify do
          subject.status 204
          subject.get do
            body false
          end

          get '/'
          expect(last_response.status).to eq(204)
          expect(last_response.body).to be_empty
        end

        specify do
          subject.status 204, '204'
          subject.get do
            body false
          end

          get '/'
          expect(last_response.status).to eq(204)
          expect(last_response.body).to be_empty
        end
      end
    end

    context 'with entity dsl' do
      context 'status code not provided' do
        it 'is resolved as default entity class' do
          entity_class = inspected_entity_class

          subject.entity do
            expose :a
            expose :b, using: entity_class
          end
          subject.get do
            status 400
            present :a, 1
            present :b, 2
          end

          get '/'
          expect(last_response.status).to eql 400
          expect(eval(last_response.body)).to eql(a: 1, b: 'entity_class')
        end
      end
    end

    context 'with success and fail dsl' do
      context 'status code not provided' do
        before do
          success_class = inspected_entity_class 'success'
          fail_class = inspected_entity_class 'fail'

          subject.success do
            expose :value, using: success_class
          end
          subject.entity do
            expose :value, using: fail_class
          end
          subject.namespace '/foo' do
            get '/success' do
              status 200
              present :value, nil
            end

            get '/fail' do
              status 400
              present :value, nil
            end
          end
        end

        it 'is resolved as default success entity class' do
          get '/foo/success'
          expect(last_response.status).to eql 200
          expect(eval(last_response.body)).to eql(value: 'success')
        end

        it 'is resolved as default fail entity class' do
          get '/foo/fail'
          expect(last_response.status).to eql 400
          expect(eval(last_response.body)).to eql(value: 'fail')
        end
      end
    end
  end
end
# rubocop:enable Security/Eval
