ready = ->
  $('.collapse').collapse({toggle: false})
  $('.collapse').on('show.bs.collapse', addActiveClass)
  $('.collapse').on('hidden.bs.collapse', removeActiveClass)
  $('#recommend-course-link').click(toggleAccordion)
  $('#rate-course-link').click(toggleAccordion)
  $('#enroll-course-link').on 'click', (event) -> enrollCourse(event)
  $('#unenroll-course-link').on 'click', (event) -> unenrollCourse(event)

  content_height = $('#course-description').children().find('.content').outerHeight()
  title_height = $('#course-description').children().find('.title').outerHeight()
  if content_height > ($('#course-description').height() - title_height)
    $('#course-description-show-more.show-more').show()
                                                .click(showMore)
  return

$(document).ready(ready)

removeActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).removeClass('entry-active')

addActiveClass = (event) ->
  targetId = $(event.currentTarget)[0].id + '-link'
  $('#' + targetId).addClass('entry-active')

toggleAccordion = (event) ->
  $('.collapse').collapse('hide')

showMore = () ->
  $('#course-description-show-more').parent().css('max-height', 'none')
  $('#course-description-show-more').removeClass('show-more')
  $('#course-description-show-more').addClass('show-less')
  $('#course-description-show-more').text(I18n.t('global.show_less'))
  $('#course-description-show-more.show-less').click(showLess)

showLess = () ->
  $('.show-less').parent().css('max-height', '250px')
  $('.show-less').parent().children('a').addClass('show-more')
  $('#course-description-show-more').text(I18n.t('global.show_more'))
  $('.show-more').parent().children('a').removeClass('show-less')
  $('#course-description-show-more.show-more').click(showMore)

enrollCourse = (event) ->
  course_id = $(event.target).data('course-id')
  url = "/courses/#{course_id}/enroll_course.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      if data.status == true
        $(event.target).text(I18n.t('courses.unenroll_course'))
                       .unbind('click')
                       .attr('id','unenroll-course-link')
                       .on 'click', (event) -> unenrollCourse(event)
      else
        alert(I18n.t('courses.enrollment_error'))
  event.preventDefault()

unenrollCourse = (event) ->
  course_id = $(event.target).data('course-id')
  url = "/courses/#{course_id}/unenroll_course.json"
  $.ajax
    url: url
    method: 'GET'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log('error_status')
      alert(I18n.t('global.ajax_failed'))
    success: (data, textStatus, jqXHR) ->
      if data.status == true
        $(event.target).text(I18n.t('courses.enroll_course'))
                       .unbind('click')
                       .attr('id','enroll-course-link')
                       .on 'click', (event) -> enrollCourse(event)
      else
        alert(I18n.t('courses.unenrollment_error'))
  event.preventDefault()