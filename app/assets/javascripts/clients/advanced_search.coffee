CIF.ClientsAdvanced_search = do ->
  _init = ->
    _initJqueryQueryBuilder()
    _handleInitDatatable()
    _setRuleJqueryQueryBuilder()
    _handleSearch()
    _handleScrollTable()
    _changeButtonAddRuleSize()

  _changeButtonAddRuleSize = ->
    $("button[data-add='rule']").removeClass('btn-xs btn-success')
    $("button[data-add='rule']").addClass('btn-primary')

  _setRuleJqueryQueryBuilder = ->
    queryRules = $('#builder').data('search-rules')
    queryCondition = $('#builder').data('search-condition')
    if queryRules != undefined
      $('#builder').queryBuilder('setRules', queryRules)

  _initJqueryQueryBuilder = ->
    fieldList = $('#builder').data('field-list')
    filterTranslation = $('#builder').data('filter-translation')
    $('#builder').queryBuilder
      allow_groups: false
      conditions: ['AND']
      inputs_separator: ' AND '
      icons:
        remove_rule: 'fa fa-minus'
      lang:
        delete_rule: ''
        add_rule: filterTranslation
        operators:
          equal: 'is'
          not_equal: 'is not'
          less: '<'
          less_or_equal: '<='
          greater: '>'
          greater_or_equal: '>='
          contains: 'includes'
          not_contains: 'excludes'
      filters: fieldList

    
  _handleInitDatatable = ->
    $('.client-advanced-search table').DataTable(
        'sScrollY': 'auto'
        'bFilter': false
        'bAutoWidth': true
        'bSort': false
        'sScrollX': '100%'
        'bInfo': false
        'bLengthChange': false
        'bPaginate': false
      )

  _handleSearch = ->
    $('#search').on 'click', ->
      rules =  JSON.stringify($('#builder').queryBuilder('getRules'))
      if !($.isEmptyObject($('#builder').queryBuilder('getRules')))
        $('#client_search_rules').val(rules)
        $('#advanced-search').submit()

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.client-advanced-search .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _handleResizeWindow = ->
    window.dispatchEvent new Event('resize')    

  { init: _init }