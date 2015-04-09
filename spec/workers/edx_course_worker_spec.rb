require 'rails_helper'

describe EdxCourseWorker do

  let!(:mooc_provider) { FactoryGirl.create(:mooc_provider, name: 'edX') }

  let(:edx_course_worker){
    EdxCourseWorker.new
  }

  let(:json_course_data) {
    JSON.parse '{"count":475,"value":{"title":"EdX RSS to JSON pipe","description":"Pipes Output","link":"http:\/\/pipes.yahoo.com\/pipes\/pipe.info?_id=74859f52b084a75005251ae7a119f371","pubDate":"Tue, 07 Apr 2015 12:16:40 +0000","generator":"http:\/\/pipes.yahoo.com\/pipes\/","callback":"","items":[{"guid":"https:\/\/www.edx.org\/node\/4116","title":"DemoX","link":"https:\/\/www.edx.org\/course\/demox-edx-demox-1","description":"This brief course is designed to show new students how to take a course on edX. You will learn how to navigate the edX platform and complete your first course! From there, we will help you get started choosing the course that best fits your interests, needs, and dreams.\n\nHave questions before taking the demo course? Check our student FAQs.","pubDate":"Mon, 06 Apr 2015 18:13:23 -0400","course:id":"edX\/DemoX.1\/2014","course:code":"DemoX.1","course:created":"Mon, 15 Sep 2014 10:37:30 -0400","course:start":"2013-07-07 00:00:00","course:end":"2013-08-08 00:00:00","course:subtitle":"<p>A fun and interactive course designed to help you explore the edX learning experience.  Perfect to take before you start your course.<\/p>","course:subject":["Biology & Life Sciences","Business & Management","Chemistry","Computer Science","Economics & Finance","Electronics","Energy & Earth Sciences","Engineering","Environmental Studies","Food & Nutrition","Health & Safety","History","Humanities","Law","Literature","Math","Medicine","Philosophy & Ethics","Physics","Science","Social Sciences","Statistics & Data Analysis"],"course:school":"edX","course:staff":["Raphael Valenti","James Donald","Erik Brown"],"course:video-youtube":"http:\/\/www.youtube.com\/watch?v=1u_QKOrXyMM","course:video-file":null,"course:image-banner":"https:\/\/www.edx.org\/sites\/default\/files\/course\/image\/banner\/demox_608x211_0.jpg","course:image-thumbnail":"https:\/\/www.edx.org\/sites\/default\/files\/course\/image\/promoted\/demox_378x225_0.jpg","course:verified":"0","course:xseries":"0","course:highschool":"0","course:profed":"0","course:effort":"From 10 - 30 minutes, or as much time as you want.","course:length":"2 Weeks","course:prerequisites":"None","y:published":{"hour":"22","timezone":"UTC","second":"23","month":"4","month_name":"April","minute":"13","utime":"1428358403","day":"6","day_ordinal_suffix":"th","day_of_week":"1","day_name":"Monday","year":"2015"},"y:id":{"permalink":"false","value":"https:\/\/www.edx.org\/node\/4116"},"y:title":"DemoX"}]}}'
  }

  it 'should deliver MOOCProvider' do
    expect(edx_course_worker.mooc_provider).to eql mooc_provider
  end

  it 'should get an API response' do
    expect(edx_course_worker.get_course_data).not_to be_nil
  end

  it 'should load new course into database' do
    expect {edx_course_worker.handle_response_data json_course_data}.to change(Course, :count).by(1)
  end

  it 'should load course attributes into database' do
    edx_course_worker.handle_response_data json_course_data

    json_course = json_course_data['value']['items'][0]
    course = Course.find_by(:provider_course_id => json_course['course:id'], :mooc_provider_id => mooc_provider.id)

    expect(course.name).to eql json_course['title']
    expect(course.provider_course_id).to eql json_course['course:id']
    expect(course.mooc_provider_id).to eql mooc_provider.id
    expect(course.url).to eql json_course['link']
    expect(course.imageId).to eql json_course['course:image-thumbnail']
    expect(course.start_date).to eq DateTime.parse(json_course['course:start']).in_time_zone
    expect(course.end_date).to eq DateTime.parse(json_course['course:end']).in_time_zone
    expect(course.provider_given_duration).to eql json_course['course:length']
    expect(course.requirements).to include json_course['course:prerequisites']
    expect(course.categories).to include json_course['course:subject'][0]
    expect(course.description).to eql json_course['description']
    expect(course.course_instructors).to include json_course['course:staff'][0]
  end
end
