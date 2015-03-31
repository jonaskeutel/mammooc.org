require 'rails_helper'

describe MoocHouseCourseWorker do

  before(:all) do
    @mooc_provider = FactoryGirl.create(:mooc_provider, name: 'mooc.house')
  end

  let(:mooc_house_course_worker){
    MoocHouseCourseWorker.new
  }

  it 'should deliver MOOCProvider' do
    expect(mooc_house_course_worker.mooc_provider).to eql @mooc_provider
  end

  it 'should get an API response' do
    pending
    expect(mooc_house_course_worker.get_course_data).not_to be_nil
  end

end
