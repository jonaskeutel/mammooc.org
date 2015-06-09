# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

ready = ->
  $('.remove-recommendation-group').click(delete_group_recommendation)
  $('.remove-recommendation-current-user').click(delete_user_from_recommendation)
  return

$(document).ready(ready)

delete_group_recommendation = () ->
  recommendation_id = $(this).data('recommendation_id')
  recommendation = $(this).closest('.recommendations')

  $.ajax
    url: "/recommendations/#{recommendation_id}/delete_group_recommendation"
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('group delete recommendation error')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      recommendation.remove()
  return false


delete_user_from_recommendation = () ->
  recommendation_id = $(this).data('recommendation_id')
  recommendation = $(this).closest('.recommendations')

  $.ajax
    url: "/recommendations/#{recommendation_id}/delete_user_from_recommendation"
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('user delete recommendation error')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      recommendation.remove()
  return false

group_ids = []
groups_autocomplete = []
users_autocomplete = []
courses_autocomplete = []


generate_groups_autocomplete = () ->
  get_my_groups()
  $("#recommendation_related_group_ids").tokenfield
    autocomplete:
      source: groups_autocomplete
      delay: 100
      autoFocus: true
    showAutocompleteOnFocus: true

get_my_groups = () ->
  group_ids = []
  groups_autocomplete = []
  $.ajax
    url: '/groups.json'
    method: 'GET'
    async: false
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_get_my_groups')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      console.log('success_get_my_groups')
      for group in data
        group_ids.push(group.id)
        groups_autocomplete.push({ value: group.id, label: group.name })


generate_users_autocomplete = () ->
  users_autocomplete = []
  get_my_groups()
  for group_id in group_ids
    $.ajax
      url: "/groups/#{group_id}/members.json"
      async: false
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('users error')
        alert(I18n.t('global.ajax_failed'))
      success: (data, textStatus, jqXHR) ->
        console.log('users success')
        for user in data.group_members
          users_autocomplete.push({ value: user.id, label: user.first_name + ' ' + user.last_name })

  $("#recommendation_related_user_ids").tokenfield
    autocomplete:
      source: users_autocomplete
      delay: 100
      autoFocus: true
    showAutocompleteOnFocus: true

generate_course_autocomplete = () ->
  $('#recommendation_course_id').tokenfield
    autocomplete:
      minLength: 3
      source: (request, response) ->
        $.ajax
          url: "/courses/autocomplete.json"
          dataType: "json"
          data:
            q: request.term
          error: (jqXHR, textStatus, errorThrown) ->
            console.log('courses error')
            alert(I18n.t('global.ajax_failed'))
          success: (data, textStatus, jqXHR) ->
            results = []
            for course in data
              results.push({ label: course.name, value: course.id })
            response(results)
      delay: 100
      autoFocus: true
    showAutocompleteOnFocus: true
    limit: 1

@recommendationNewParameters = () ->
  generate_course_autocomplete()
  generate_groups_autocomplete()
  generate_users_autocomplete()
  params = getParams()
  if 'course_id' of params
    course_id = params['course_id']
    $.ajax
      url: "/courses/#{course_id}.json"
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('course id error')
        alert(I18n.t('global.ajax_failed'))
      success: (data, textStatus, jqXHR) ->
        console.log('course id success')
        course_name = data.name
        $('#recommendation_course_id').tokenfield('setTokens', [{value: course_id, label: course_name}])
  else if 'group_id' of params
    group_id = params['group_id']
    $.ajax
      url: "/groups/#{group_id}.json"
      method: 'GET'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log('group id error')
        alert(I18n.t('global.ajax_failed'))
      success: (data, textStatus, jqXHR) ->
        console.log('group id success')
        group_name = data.name
        $('#recommendation_related_group_ids').tokenfield('setTokens', [{value: group_id, label: group_name}])
