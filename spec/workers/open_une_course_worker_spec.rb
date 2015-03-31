require 'rails_helper'

describe OpenUNECourseWorker do

  before(:all) do
    @mooc_provider = FactoryGirl.create(:mooc_provider, name: 'openUNE')
  end

  let(:open_une_course_worker){
    OpenUNECourseWorker.new
  }

  it 'should deliver MOOCProvider' do
    expect(open_une_course_worker.mooc_provider).to eql @mooc_provider
  end

  it 'should get an API response' do
    pending
    expect(open_une_course_worker.get_course_data).not_to be_nil
  end

end