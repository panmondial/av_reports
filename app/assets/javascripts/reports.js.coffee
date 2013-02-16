# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  path = ($(location).attr('pathname')).split("/")
  #if document.title.match(/^(?=.*?\| Reports\b)/)
  if path[1] = "reports"  
    $("#other_person").hide()
    recallFields()

$ ->
  $("input[name=person_select]").change ->
    if $("input[name=person_select]:checked").val()=="other"
      $("#other_person").show()
      $("#other_person_id").focus()
    else
      $("#other_person").hide()
      $('input[id=person_select_me]').focus()
    
intervalID = null

recallFields = ->
  $.getJSON('/reports/orig_params')
    .done((data, status) ->
      if data.percent_complete < 100 && data.percent_complete > 0
        setPageValue(data.jperson_select, data.jother_person_id, data.jreport_type, "", "")
        startProgressCheck(data.percent_complete)
        setAttrButtons(true, true, true, true, true, false)
      else if data.percent_complete == 100
        setPageValue(data.jperson_select, data.jother_person_id, data.jreport_type, data.jresult_person_name, data.jresult_person_id)
        setAttrButtons(true, false, false, false, false, false)
        $('#data_loaded').css('width', "#{data.percent_complete}%")
        stopProgressCheck("Finished")
      else
        setPageValue("me", "", "", "", "")
        setAttrButtons(false, true, true, true, true, true)
        setAttrForm(false, false, false)
        stopProgressCheck("Load")
    )
    .fail( ->
      setResultsText("", "", true)
      setAttrForm(true, true, true)
      setAttrButtons(true, true, true, true, true, true)
      setValuesForm("me", "", "")
      stopProgressCheck("Load")
    )

checkProgress = ->
  $.getJSON('/reports/progress')
    .done((data, status) ->
      if data.jerror
        if data.jerror.search("[404]")
          alert "The FamilySearch person identifier: " + data.j_root_person + " could not be found. Please verify the ID and try again."
        else if data.jerror.search("[401.23]")
          alert "Your FamilySearch session has expired. Please click 'sign out', then 'sign in' to refresh your FamilySearch session."
        else
          alert "The following error has occurred: \n \n" + data.jerror + "\n \n Please verify your Internet connection, logout and try running the report again."
        stopProgressCheck("Load")
        setAttrForm(false, false, false)
        setAttrButtons(false, false, false, true, true, true)
        setValuesForm(person_select_val, other_person_id, report_type)
        $('#data_loaded').parent().hide()
      else
        displayProgress(data.percent_complete)
        if data.percent_complete == 100
          stopProgressCheck("Finished")
          setResultsText(data.jresult_person_name, data.jresult_person_id, false)
          setAttrButtons(true, false, false, false, false, false)
          setAttrForm(true, true, false)
        else
          setAttrButtons(true, true, true, true, true, true)
          setAttrForm(true, true, true)
          displayProgress(data.percent_complete)
    )
    .error((data, status) -> 
      alert "There was an error checking progress!"
    )
    .fail( -> alert 'There was a problem checking progress!' )
	
displayProgress = (percent_complete) ->
  $('#data_loaded').css('width', "#{percent_complete}%")
  $('#Load').prop('value', "Loading... #{percent_complete}%")

showProgressBar = (value) ->
  setResultsText("", "", true)
  displayProgress(value)
  $('#data_loaded').parent().show()

startProgressCheck = (bar_value) ->
  showProgressBar(bar_value)
  setAttrForm(true, true, false)
  setAttrButtons(true, true, true, true, true, true)
  setValueLoadButton("Loading...")
  intervalID = setInterval(checkProgress, 2500)  

stopProgressCheck = (Load_btn_val) ->
  clearInterval(intervalID)
  setValueLoadButton(Load_btn_val)
	  
setPageValue = (jperson_select, jother_person_id, jreport_type, jresult_person_name, jresult_person_id) ->
  if jperson_select == "other"
    setResultsText(jresult_person_name, jresult_person_id, false)
    setAttrForm(true, true, false)
    setOtherPersonHide(false)
    setValuesForm(jperson_select, jother_person_id, jreport_type)
    setValueLoadButton("Finished")
    return false
  else if jperson_select == "me"
    setResultsText(jresult_person_name, jresult_person_id, false)
    setAttrForm(true, true, false)
    setOtherPersonHide(true)
    setValuesForm("me", "", jreport_type)
    setValueLoadButton("Finished")
    return false

setResultsText = (person_name, person_id, hidden_state) ->
  $('#result_person_name').text(person_name)
  $('#result_person_id').text(person_id)
  $('#data_detail').prop(hidden: hidden_state)
	
setValuesForm = (person_select_val, other_person_id, report_type) ->
  $("[name=person_select]").filter("[value="+person_select_val+"]").attr("checked","checked") 
  $('input[name=other_person_id]').prop(value: other_person_id)
  if person_select_val == "other"
    $("#other_person").show()
  else
    $("#other_person").hide()
  if ($(location).attr('search'))
    $('#type').prop(value: report_type)
  else
    $('#type').prop(value: "")

setValueLoadButton = (Load) ->
  $('#Load').prop(value: Load)
  
setAttrForm = (person_select_disable, other_person_disable, report_type_disable) ->
  $('input[name=person_select]').prop(readonly: person_select_disable)
  $('input[name=other_person_id]').prop(readonly: other_person_disable)
  $('#type').prop(readonly: report_type_disable)

setOtherPersonHide = (hidden_state) ->
  $("#other_person").prop(hidden: hidden_state)

setAttrButtons = (Load_disabled, Clear_Data_disabled, Clear_Data_hidden, Run_Report_disabled, Reset_disabled, Reset_hidden) ->
  $('#Load').prop(disabled: Load_disabled)
  $("#Clear_Data").prop(disabled: Clear_Data_disabled)
  $("#Clear_Data").toggle(not(Clear_Data_hidden))
  $('#Run_Report').prop(disabled: Run_Report_disabled)
  $("#Reset").prop(disabled: Reset_disabled)
  $('#Reset').toggle(not(Reset_hidden))

$ ->
  $("#Load").click ->
    if $("input[name=person_select]:checked").val() is "me"
      jqroot_person = $("input[name=person_select]:checked").val()
    else if $("input[name=person_select]:checked").val() is "other"
      if ($("#other_person_id").val().match(/^[a-zA-Z0-9]{4}[\-]{1}[a-zA-Z0-9]{3}$/))
        jqroot_person = $("#other_person_id").val()
      else 
        alert "Please enter a valid Personal Identifier for the root person of the report. (example: KQZZ-N2J)"
        $("#other_person_id").focus()
        return false

    $.getJSON("../reports/build_detail_ped", root_person: jqroot_person)
      .done((data, status) ->
        startProgressCheck(0)
      )
      .fail((data, status) ->
        stopProgressCheck()
        alert 'Your connection to FamilySearch has expired. Please check your Internet connection and login again to build your report.'
      )
  
$ ->
  $("#Run_Report").click ->
    if $("#type").val().length==0
      alert "Please select a report type."
      return false
    else
      $(this).closest('form').submit()
      return false
	  
$ ->
  $("#Reset").click ->
    setResultsText("", "", true)
    #alert "something"
    setAttrForm(false, false, false)
    setAttrButtons(false, true, true, true, true, true)
    setValuesForm("me", "", "")
    setValueLoadButton("Load")
    $('input[id=person_select_me]').focus()
    $('#data_loaded').parent().hide()
	
$ ->
  $("#Clear_Data").click ->
    $.getJSON("../reports/clear_cache")
      .done( ->
        setResultsText("", "", true)
        setAttrForm(false, false, false)
        setAttrButtons(false, true, true, true, true, true)
        setValuesForm("me", "", "")
        setValueLoadButton("Load")
        $('#data_loaded').parent().hide()
        $('input[id=person_select_me]').focus()
        alert "Your data has been cleared. Please select a new starting person and load data."
      )
      .fail((data, status) ->
        alert 'An error has occurred with your data refresh request. Please try again.'
      )

  
#setResultsText(person_name, person_id, hidden_state)
#setAttrForm(person_select_disable, other_person_disable, report_type_disable)
#setAttrButtons(Load_disabled, Clear_Data_disabled, Clear_Data_hidden, Run_Report_disabled, Reset_disabled, Reset_hidden)
#setValuesForm(person_select_val, other_person_id, report_type)
#setValueLoadButton(Load)