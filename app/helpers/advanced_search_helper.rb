module AdvancedSearchHelper
  def format_advance_search_result(field_name, value)
    associated_value = {
      provinces:            ['birth_province_id', 'province_id'],
      referral_sources:     ['referral_source_id'],
      users:                ['received_by_id', 'followed_up_by_id', 'user_id'],
    }
    if field_name == 'has_been_in_orphanage' || field_name == 'has_been_in_government_care'
      value ? 'Yes' : 'No'
    elsif associated_value[:provinces].include?(field_name) 
      Province.find(value).name
    elsif associated_value[:referral_sources].include?(field_name)
      ReferralSource.find(value).name
    elsif associated_value[:users].include?(field_name)
      User.find(value).name
    else
      value
    end
  end
end