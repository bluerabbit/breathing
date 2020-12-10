require 'spec_helper'

describe Breathing do
  it 'has a version number' do
    expect(Breathing::VERSION).not_to be nil
  end

  it do
    user = User.create!(name: :a, age: 1)
    expect(user.name).to eq('a')
  end
end
