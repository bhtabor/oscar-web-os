describe Donor, 'validation' do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
end

describe Donor, 'associations' do
  it { is_expected.to have_many(:clients) }
end