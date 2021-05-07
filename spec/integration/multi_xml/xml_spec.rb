# frozen_string_literal: true

require 'spec_helper'

describe Grape::Xml do
  it 'uses multi_xml' do
    skip "Don't know what it is MultiXml"
    expect(Grape::Xml).to eq(::MultiXml)
  end
end
