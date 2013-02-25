# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ -> $('#Clear_Data').tooltip(trigger: "hover", title: "Remove report data", placement: "right")
#$ -> $('#Load').tooltip(trigger: "hover", title: "Load data for report", placement: "right")
$ -> $('#Reload_Data').tooltip(trigger: "hover", title: "Reload changes made on FamilySearch", placement: "right")
#$ -> $('#Run_Report').tooltip(trigger: "hover", title: "Run report with selected criteria", placement: "right")
$ -> $('#Reset').tooltip(trigger: "hover", title: "Select new starting person", placement: "right")

$ ->
  path = ($(location).attr('pathname')).split("/")
  #if document.title.match(/^(?=.*?\| Reports\b)/)
  if path[1] = "reports"  
    $("#other_person").hide()
    $('#data_detail').hide()
    $('#Reload_Data').hide()
    $('#Reset').hide()
    recallFields()

$ ->
  $("input[name=person_select]").change ->
    if $("input[name=person_select]:checked").val()=="other"
      $("#other_person").show()
      $("#other_person_id").focus()
    else
      $("#other_person").hide()
      $('input[id=person_select_me]').focus()

$ ->
  $("form :input").on("keypress", (e) ->
    e.keyCode isnt 13
  )

intervalID = null

recallFields = ->
  $.getJSON('/reports/orig_params')
    .done((data, status) ->
#      if data.jpedigree_built is true
#        setAttrButtons(true, false, false, false, false, false, false)
#        setPageValue(data.jperson_select, data.jother_person_id, data.j_root_person, data.jreport_type, data.jresult_person_name, data.jresult_person_id)
#      else
      if data.percent_complete is 100
        $('#data_loaded').parent().hide()
        setAttrButtons(true, false, false, false, false, false, false)
        setPageValue(data.jperson_select, data.jother_person_id, data.j_root_person, data.jreport_type, data.jresult_person_name, data.jresult_person_id)
        $('#type').focus()
      else if data.percent_complete is null
        setPageValue("me", "", "", "", "")
        $('#data_detail').hide()
        setAttrButtons(false, true, true, true, true, true, true)
        setAttrForm(false, false, false)
        stopProgressCheck("Load")
      else if data.percent_complete < 100 and data.percent_complete >=0
        setPageValue(data.jperson_select, data.jother_person_id, data.j_root_person, data.jreport_type, "", "")
        startProgressCheck(data.percent_complete)
        setAttrButtons(true, true, true, true, true, true, true)
      else 
        setPageValue("me", "", "", "", "")
        setAttrButtons(false, true, true, true, true, true, true)
        setAttrForm(false, false, false)
        stopProgressCheck("Load")
    )
    .error((data, status) ->
      stopProgressCheck("Load")
      setResultsText("", "", true)
      setAttrForm(true, true, true)
      setAttrButtons(true, true, true, true, true, true, true)
      setValuesForm("me", "", "", "")
      response = $.parseJSON(data.responseText)
      if response is null
        alert "There was a problem loading your report criteria. Please check your Internet connection, refresh your browser, and try again."
      else
        alert response.message
    )

checkProgress = ->
  $.getJSON('/reports/progress')
    .done((data, status) ->
      if data.jerror
        if data.jerror == "Timeout::Error"
          alert "Your FamilySearch session has timed out. Please sign out of the Arbor Vitae site and sign in again to refresh your FamilySearch session."
        #if data.jerror.search("[401.23]")
        #  alert "Your FamilySearch session has timed out. Please sign out of the Arbor Vitae site and sign in again to refresh your FamilySearch session."
        #else
        else
          alert "The following error has occurred: \n" + data.jerror + "\n Please verify your Internet connection, logout and try running the report again."
        stopProgressCheck("Load")
        setAttrForm(false, false, false)
        setAttrButtons(false, false, false, true, true, true, true)
        #setValuesForm(person_select_val, other_person_id, report_type)
        $('#data_loaded').parent().hide()
      else
        displayProgress(data.percent_complete)
#       if data.jpedigree_built is true
#         displayProgress(100)
#         stopProgressCheck("Finished")
#         setAttrForm(true, true, false)
#         setAttrButtons(true, false, false, false, false, false, false)
#         setResultsText(data.jresult_person_name, data.jresult_person_id, false)
#         setValuesForm(jperson_select, jother_person_id, j_root_person, jreport_type)
#       else
        if data.percent_complete == 100
          $.getJSON('/reports/orig_params')
            .done((data, status) ->
              stopProgressCheck("Finished")
              $('#data_loaded').parent().hide()
              setAttrForm(true, true, false)
              setAttrButtons(true, false, false, false, false, false, false)
              setResultsText(data.jresult_person_name, data.jresult_person_id, false)
              #setValuesForm(jperson_select, jother_person_id, j_root_person, jreport_type)
              $('#type').focus()
            )
            .error((data, status) ->
              stopProgressCheck("Load")
              $('#data_loaded').parent().hide()
              setAttrForm(false, false, false)
              setAttrButtons(false, false, false, true, false, false, false)
              setResultsText("", "", true)
              alert "There was a problem refreshing your report criteria page. Please refresh your browser and try again."
            )
        else # if data.percent_complete < 100 and data.percent_complete <= 0
          setAttrButtons(true, true, true, true, true, true, true)
          #setAttrButtons(false, false, false, false, false, false, false)
          setAttrForm(true, true, true)
          displayProgress(data.percent_complete)
          #stopProgressCheck("Error")
    )
    .error((data, status) ->
      stopProgressCheck("Load")
      $('#data_loaded').parent().hide()
      setAttrForm(false, false, false)
      setAttrButtons(false, false, false, true, false, false, false)
      setResultsText("", "", true)
      alert "There was a problem checking the status of your data. Please refresh your page and try loading again."  
    )
	
displayProgress = (percent_complete) ->
  $('#data_loaded').css('width', "#{percent_complete}%")
  if percent_complete == 0
    $('#Load').prop('value', "Starting up...")
  else
    $('#Load').prop('value', "Loading... #{percent_complete}%")

showProgressBar = (value) ->
  setResultsText("", "", true)
  displayProgress(value)
  $('#data_loaded').parent().show()
  
startProgressCheck = (bar_value) ->
  showProgressBar(bar_value)
  setAttrForm(true, true, false)
  setAttrButtons(true, true, true, true, true, true, true)
  if bar_value == 0
    setValueLoadButton("Starting up...")
  else
    setValueLoadButton("Loading... #{bar_value}%")
  intervalID = setInterval(checkProgress, 2500)  

stopProgressCheck = (Load_btn_val) ->
  clearInterval(intervalID)
  setValueLoadButton(Load_btn_val)
	  
setPageValue = (jperson_select, jother_person_id, j_root_person, jreport_type, jresult_person_name, jresult_person_id) ->
  if jperson_select == "other"
    setResultsText(jresult_person_name, jresult_person_id, false)
    setAttrForm(true, true, false)
    setOtherPersonHide(false)
    setValuesForm(jperson_select, jother_person_id, j_root_person, jreport_type)
    setValueLoadButton("Finished")
    return false
  else if jperson_select == "me"
    setResultsText(jresult_person_name, jresult_person_id, false)
    setAttrForm(true, true, false)
    setOtherPersonHide(true)
    setValuesForm("me", "", j_root_person, jreport_type)
    setValueLoadButton("Finished")
    return false

setResultsText = (person_name, person_id, hidden_state) ->
  $('#result_person_name').text(person_name)
  $('#result_person_id').text(person_id)
  #$('#data_detail').prop(hidden: hidden_state)
  $('#data_detail').toggle(not(hidden_state))
	
setValuesForm = (person_select_val, other_person_id, root_person, report_type) ->
  $("[name=person_select]").filter("[value="+person_select_val+"]").attr("checked","checked") 
  $('input[name=other_person_id]').prop(value: other_person_id)
  $("#root_person").val(root_person)
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
  $('input[name=person_select]').prop(disabled: person_select_disable)
  $('input[name=other_person_id]').prop(disabled: other_person_disable)
  $('#type').prop(readonly: report_type_disable)

setOtherPersonHide = (hidden_state) ->
  $("#other_person").prop(hidden: hidden_state)

setAttrButtons = (Load_disabled, Clear_Data_disabled, Clear_Data_hidden, Run_Report_disabled, Reset_disabled, Reset_hidden, Reload_disabled) ->
  $('#Load').prop(disabled: Load_disabled)
  $("#Clear_Data").prop(disabled: Clear_Data_disabled)
  $("#Clear_Data").toggle(not(Clear_Data_hidden))
  $("#Reload_Data").toggle(not(Reload_disabled))
  $('#Run_Report').prop(disabled: Run_Report_disabled)
  $("#Reset").prop(disabled: Reset_disabled)
  $('#Reset').toggle(not(Reset_hidden))

$ ->
  $("#Load").click ->
    if navigator.onLine
      $("#Load").mouseleave()
      if $("input[name=person_select]:checked").val() is "me"
        $("#root_person").val("me")
      else if $("input[name=person_select]:checked").val() is "other"
        if ($("#other_person_id").val().match(/^[a-zA-Z0-9]{4}[\-]{1}[a-zA-Z0-9]{3}$/))
          $("#root_person").val($("#other_person_id").val())
        else 
          alert "Please enter a valid Personal Identifier for the root person of the report. (example: KQZZ-N2J)"
          $("#other_person_id").focus()
          return false
      jqroot_person = $("#root_person").val()
      $.getJSON("/reports/build_detail_ped", root_person: jqroot_person)
        .done((data, status) ->
          startProgressCheck(0)
        )
        .error((data, status) ->
          stopProgressCheck("Load")
          response = $.parseJSON(data.responseText)
          setResultsText("", "", true)
          setAttrForm(false, false, false)
          setAttrButtons(false, false, false, true, true, true, true)
          if response is null
            alert "There was a problem loading your data. Please check your Internet connection, refresh your browser, and try again."
          else
            alert response.message
        )
    else
      alert "Your Internet connection is currently unavailable. Please re-connect your Internet and try again."
	
	
$ ->
  $("#Run_Report").click ->
    if navigator.onLine
      $('#Run_Report').mouseleave()
      if $("#type").val().length==0
        $("#type").focus()
        alert "Please select a report type."
        return false
      else
        $(this).closest('form').submit()
        return false
    else
      alert "Your Internet connection is currently unavailable. Please re-connect your Internet and try again."
	
$ ->
  $("#Reset").click ->
    setResultsText("", "", true)
    setAttrForm(false, false, false)
    $("#Reset").mouseleave()
    setAttrButtons(false, true, true, true, true, true, true)
    setValuesForm("me", "", "", "")
    setValueLoadButton("Load")
    $('input[id=person_select_me]').focus()
    $('#data_loaded').parent().hide()

$ ->
  $("#Clear_Data").click ->
    if navigator.onLine
      $.getJSON("/reports/clear_cache")
        .done( ->
          setResultsText("", "", true)
          setAttrForm(false, false, false)
          $("#Clear_Data").mouseleave()
          setAttrButtons(false, true, true, true, true, true, true)
          setValuesForm("me", "", "", "")
          setValueLoadButton("Load")
          $('#data_loaded').parent().hide()
          $('input[id=person_select_me]').focus()
          alert "Your data has been cleared. Please select a new starting person and load data."
        )
        .error((data, status) ->
          setAttrForm(true, true, false)
          setAttrButtons(true, false, false, false, false, false, false)
          stopProgressCheck("Finished")
          response = $.parseJSON(data.responseText)
          alert "There was a problem clearing your data. Please check your Internet connection, refresh your browser, and try again."
        )
    else
      alert "Your Internet connection is currently unavailable. Please re-connect your Internet and try again."
  
$ ->
  $("#Reload_Data").click ->
    if navigator.onLine
      jqroot_person = $("#root_person").val()
      $.getJSON("/reports/reload_data", root_person: jqroot_person)
        .done((data, status) ->
          startProgressCheck(0)
        )
        .error((data, status) ->
          setAttrForm(true, true, false)
          setAttrButtons(true, false, false, false, false, false, false)
          stopProgressCheck("Load")
          response = $.parseJSON(data.responseText)
          if response is null
            alert "There was a problem reloading your data. Please check your Internet connection, refresh your browser, and try again."
          else
            alert response.message
        )
    else
      alert "Your Internet connection is currently unavailable. Please re-connect your Internet and try again."

	  
	  
#setResultsText(person_name, person_id, hidden_state)
#setAttrForm(person_select_disable, other_person_disable, report_type_disable)
#setAttrButtons(Load_disabled, Clear_Data_disabled, Clear_Data_hidden, Run_Report_disabled, Reset_disabled, Reset_hidden, Reload_disabled)
#setValuesForm(person_select_val, other_person_id, report_type)
#setValueLoadButton(Load)
#setPageValue(jperson_select, jother_person_id, j_root_person, jreport_type, jresult_person_name, jresult_person_id)