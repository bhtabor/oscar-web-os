CIF.Program_streamsNew = CIF.Program_streamsEdit = CIF.Program_streamsCreate = CIF.Program_streamsUpdate = CIF.Program_streamsShow = do ->
  @formBuilder = []
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _initProgramSteps()
    _addFooterForSubmitForm()
    _handleInitProgramRules()
    _addRuleCallback()
    _initSelect2()
    _handleAddCocoon()

  _initSelect2 = ->
    $('select').select2()
  
  _handleSetRules = ->
    rules = $('#program_stream_rules').val()
    rules = JSON.parse(rules.replace(/=>/g, ':'))
    $('#program-rule').queryBuilder('setRules', rules) unless $.isEmptyObject(rules)

  _addRuleCallback = ->
    $('#program-rule').on 'afterCreateRuleFilters.queryBuilder', ->
      _initSelect2()
      _handleSelectOptionChange()

  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#program-rule').data('filter-translation-add-filter')
      addGroup: $('#program-rule').data('filter-translation-add-group')
      deleteGroup: $('#program-rule').data('filter-translation-delete-group')
      next: $('.program-steps').data('next')
      previous: $('.program-steps').data('previous')
      finish: $('.program-steps').data('finish')

  _handleSelectOptionChange = ->
    $('select').on 'select2-selecting', (e) ->
      setTimeout (->
        $('.rule-operator-container select, .rule-value-container select').select2(
          width: '180px'
        )
      ),100

  _handleInitProgramRules = ->
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        $('#program-rule').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        setTimeout (->
          _initSelect2()
          ), 100
        _handleSetRules()
        _handleSelectOptionChange()

  _queryBuilderOption = (fieldList) ->
    inputs_separator: ' AND '
    icons:
      remove_rule: 'fa fa-minus'
    lang:
      delete_rule: ''
      add_rule: @filterTranslation.addFilter
      add_group: @filterTranslation.addGroup
      delete_group: @filterTranslation.deleteGroup
      operators:
        is_empty: 'is blank'
        equal: 'is'
        not_equal: 'is not'
        less: '<'
        less_or_equal: '<='
        greater: '>'
        greater_or_equal: '>='
        contains: 'includes'
        not_contains: 'excludes'
    filters: fieldList

  _handleAddCocoon = ->
    $('#trackings').on 'cocoon:after-insert', (e, element) ->
      trackingBuilder = $(element).find('.tracking-builder')
      _initProgramBuilder(trackingBuilder, [])

  _generateValueForSelectOption = (field) ->
    $(field).find('input.option-label').on 'keyup change', ->
      value = $(@).val()
      $(@).siblings('.option-value').val(value)

  _hideOptionValue = ->
    $('.option-selected, .option-value').hide()

  _addOptionCallback = (field) ->
    $('.add-opt').on 'click', ->
      setTimeout ( ->
        $(field).find('.option-selected, .option-value').hide()
        )

  _initProgramBuilder = (element, data) ->
    data = if data.length != 0 then data.replace(/=>/g, ':') else ''
    @formBuilder.push $(element).formBuilder({
      dataType: 'json'
      formData: data
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button', 'file','checkbox']
      showActionButtons: false
      messages: {
        cannotBeEmpty: 'name_separated_with_underscore'
      }

      typeUserEvents: {
        'checkbox-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        date:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()

        number:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()

        'radio-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        select:
          onadd: (fld) ->
            $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        text:
          onadd: (fld) ->
            $('.fld-subtype ').find('option:contains(color)').remove()
            $('.fld-subtype ').find('option:contains(tel)').remove()
            $('.fld-subtype ').find('option:contains(password)').remove()
            $('.className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()

        textarea:
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      }

    }).data('formBuilder');
      
  _initProgramSteps = ->
    self = @
    form = $('#program-stream')
    form.children('.program-steps').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex == 0 and newIndex == 1 and $('#program-rule').is(':visible')
          form.valid()
          name = $('#program_stream_name').val() == ''
          return false if $.isEmptyObject($('#program-rule').queryBuilder('getRules')) || name

        else if currentIndex == 1 and newIndex == 2 and $('#enrollment').is(':visible')
          elements = $('#enrollment').find('.frmb li')
          return false if $(elements).length == 0

        else if currentIndex == 2 and newIndex == 3 and $('#trackings').is(':visible')
          return false unless $('.form-wrap').is(':visible')
          inputsName = $('#trackings').find('input.string.required')
          emptyValues = []
          $.map(inputsName, (input) -> emptyValues.push input if $(input).val() == '')
          if emptyValues.length > 0
            for input in emptyValues
              $(input).valid()
            return false

          trackingBuilders = $('.tracking-builder:visible')
          for tracking in trackingBuilders
            return false if $(tracking).find('.frmb li').length == 0

        $('section ul.frmb.ui-sortable').css('min-height', '266px')

      onStepChanged: (event, currentIndex, newIndex) ->
        if $('#enrollment').is(':visible')
          enrollment = $('#enrollment')
          enrollmentValue = $(enrollment).data('enrollment')
          _initProgramBuilder(enrollment, (enrollmentValue || [])) unless _preventDuplicateFormBuilder(enrollment)
        else if $('#trackings').is(':visible')
          trackings = $('.tracking-builder')
          for tracking in trackings
            trackingValue = $(tracking).data('tracking')
            _initProgramBuilder(tracking, (trackingValue || [])) unless _preventDuplicateFormBuilder(tracking)
        else if $('#exit-program').is(':visible')
          exitProgram = $('#exit-program')
          exitProgramValue = $(exitProgram).data('exit-program')
          _initProgramBuilder(exitProgram, (exitProgramValue || [])) unless _preventDuplicateFormBuilder(exitProgram)  

      onFinishing: (event, currentIndex) ->
        if currentIndex == 3 and $('#exit-program').is(':visible')
          elements = $('#exit-program').find('.frmb li')
          return false if $(elements).length == 0
        return true

      onFinished: (event, currentIndex) ->
        $('.actions a:contains("Finish")').removeAttr('href')
        _handleRemoveUnuseInput()
        _handleAddRuleBuilderToInput()
        _handleSetValueToField()
        form.submit()
      labels:
        finish: self.filterTranslation.finish
        next: self.filterTranslation.next
        previous: self.filterTranslation.previous

  _handleRemoveUnuseInput = ->
    elements = $('#program-rule ,#enrollment .form-wrap.form-builder, #tracking .form-wrap.form-builder, #exit-program .form-wrap.form-builder')
    $(elements).find('input, select, radio, checkbox, textarea').remove()

  _preventDuplicateFormBuilder = (element) ->
    $(element).children().hasClass('form-builder')

  _handleAddRuleBuilderToInput = ->
    rules = $('#program-rule').queryBuilder('getRules')
    $('#program_stream_rules').val(_handleStringfyRules(rules)) if !($.isEmptyObject(rules))

  _handleSetValueToField = ->
    for formBuilder in @formBuilder
      element = formBuilder.element
      if $(element).is('#enrollment')
        $('#program_stream_enrollment').val(formBuilder.formData)
      else if $(element).is('.tracking-builder')
        hiddenField = $(element).find('.tracking-field-hidden input[type="hidden"]')
        $(hiddenField).val(formBuilder.formData)
      else if $(element).is('#exit-program')
        $('#program_stream_exit_program').val(formBuilder.formData)

  _handleStringfyRules = (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  _addFooterForSubmitForm = ->
    $('.actions.clearfix').addClass('ibox-footer')

  { init: _init }