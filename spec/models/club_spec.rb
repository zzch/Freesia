require 'rails_helper'

describe Club do
  it 'fails validation without name' do
    expect(Club.create(name: nil).errors[:name].size).to eq(1)
  end

  it 'fails validation without code' do
    expect(Club.create(code: nil).errors[:code].size).to eq(1)
  end

  it 'fails validation without longitude' do
    expect(Club.create(longitude: nil).errors[:longitude].size).to eq(1)
  end

  it 'fails validation without latitude' do
    expect(Club.create(latitude: nil).errors[:latitude].size).to eq(1)
  end

  it 'fails validation without latitude' do
    expect(Club.create(latitude: nil).errors[:latitude].size).to eq(1)
  end
end
