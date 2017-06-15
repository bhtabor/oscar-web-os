class CustomFormPresentValidator < ActiveModel::Validator
  
  def initialize(record,table_name,field)
    @record     = record
    @table_name = table_name
    @field      = field
  end

  def validate
    return unless @record.properties
    @record.send(@table_name).send(@field).each do |field|
      next unless field['required'] && (@record.properties[field['label']].blank? || @record.properties[field['label']][0].blank?)
      @record.errors.add(field['label'], I18n.t('cannot_be_blank'))
    end
  end
end