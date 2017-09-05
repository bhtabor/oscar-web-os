describe AdvancedSearches::RuleFields, 'Method' do
  let(:admin) { create(:user, roles: 'admin') }

  before do
    @client_fields = AdvancedSearches::RuleFields.new(user: admin).render
  end

  context 'render' do
    it 'return field not nil' do
      expect(@client_fields).not_to be_nil
    end

    it 'return all fields' do
      expect(@client_fields.size).to equal 45
    end
  end
end