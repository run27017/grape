# frozen_string_literal: true

require 'spec_helper'

describe Grape::API do
  class UserEntity < Grape::Entity
    expose :name
    expose :age
  end

  class User
    attr_accessor :id, :name, :age, :created_at

    def initialize(attrs = {})
      attrs.each do |name, value|
        send "#{name}=", value
      end
    end
  end

  subject { Class.new(Grape::API) }

  def app
    subject
  end

  before do
    subject.get do
      user = User.new(
        id: 1,
        name: 'name',
        age: 18,
        created_at: Time.new
      )

      status 200
      present :count, 1
      present :user, user, with: UserEntity
    end
  end

  describe 'disassemble api invoking' do
    let(:env) do
      {
        'rack.version' => [1, 3],
        'rack.input' => StringIO.new,
        'rack.errors' => StringIO.new,
        'rack.multithread' => true,
        'rack.multiprocess' => true,
        'rack.run_once' => false,
        'REQUEST_METHOD' => 'GET',
        'SERVER_NAME' => 'example.org',
        'SERVER_PORT' => '80',
        'QUERY_STRING' => '',
        'PATH_INFO' => '/',
        'rack.url_scheme' => 'http',
        'HTTPS' => 'off',
        'SCRIPT_NAME' => '',
        'CONTENT_LENGTH' => '0',
        'rack.test' => true,
        'REMOTE_ADDR' => '127.0.0.1',
        'HTTP_HOST' => 'example.org',
        'HTTP_COOKIE' => ''
      }
    end

    it 'invokes by rack api' do
      get '/'
      expect(last_response.status).to eq 200
      expect(last_response.body).to include(':count=>1')
      expect(last_response.body).to include(':user=>#<UserEntity:')
    end

    it 'invokes by instance call' do
      _code, _headers, _body = subject.new.call(env)
      endpoint = env[Grape::Env::API_ENDPOINT]

      body = endpoint.body
      expect(body[:count]).to eq(1)
      expect(body[:user]).to be_a(Grape::Entity)
    end
  end

  describe 'patching last_env' do
    module Rack
      module Test
        module Methods
          def_delegators :current_session, :last_env
        end

        class Session
          attr_reader :last_env

          def custom_request(verb, uri, params = {}, env = {}, &block)
            uri = parse_uri(uri, env)
            @last_env = env_for(uri, env.merge(method: verb.to_s.upcase, params: params))
            process_request(uri, @last_env, &block)
          end
        end
      end
    end

    it 'contains endpoint' do
      get '/'

      body = last_env[Grape::Env::API_ENDPOINT].body
      expect(body[:count]).to eq(1)
      expect(body[:user]).to be_a(Grape::Entity)
    end

    it 'contains original object in entity' do
      get '/'

      user_entity = last_env[Grape::Env::API_ENDPOINT].body[:user]
      expect(user_entity.object).to be_a(User)
    end
  end
end
