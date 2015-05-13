# -*- encoding : utf-8 -*-
require 'rails_helper'

RSpec.describe 'courses/show', type: :view do
  let(:user) { FactoryGirl.create(:user) }
  let(:mooc_provider) { MoocProvider.create(name: 'open_mammooc', logo_id: 'logo_open_mammooc.png') }
  let!(:course) do
    assign(:course, Course.create!(
                      name: 'Name',
                      url: 'Url',
                      course_instructors: 'Course Instructor',
                      abstract: 'MyAbstract',
                      description: 'MyDescription',
                      language: 'Language',
                      imageId: 'Image',
                      videoId: 'Video',
                      provider_given_duration: 'Duration',
                      categories: 'Categories',
                      difficulty: 'Difficulty',
                      requirements: 'Requirements',
                      workload: 'Workload',
                      provider_course_id: 1,
                      course_result: nil,
                      start_date: Time.zone.local(2015, 9, 3, 9),
                      end_date: Time.zone.local(2015, 10, 3, 9),
                      mooc_provider_id: mooc_provider.id,
                      tracks: [FactoryGirl.create(:course_track)]
    ))
  end
  let!(:provider_logos) { assign(:provider_logos, {}) }

  before(:each) do
    @recommendation = Recommendation.new
  end

  it 'render the enroll button when not signed in' do
    render
    expect(view.content_for(:content)).to match(t('courses.enroll_course'))
    expect(view.content_for(:content)).to have_selector("a[href='#{new_user_session_path}']")
  end

  it 'render the enroll button when signed in but not enrolled in course' do
    sign_in user
    render
    expect(view.content_for(:content)).to match(t('courses.enroll_course'))
    expect(view.content_for(:content)).to have_selector("a[href='']")
    expect(view.content_for(:content)).to have_selector("a[id='enroll-course-link']")
  end

  it 'render the unenroll button when signed in and already enrolled in course' do
    sign_in user
    user.courses << course
    render
    expect(view.content_for(:content)).to match(t('courses.unenroll_course'))
    expect(view.content_for(:content)).to have_selector("a[id='unenroll-course-link']")
  end
end
