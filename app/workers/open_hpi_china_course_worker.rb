# frozen_string_literal: true

class OpenHPIChinaCourseWorker < AbstractXikoloCourseWorker
  MOOC_PROVIDER_NAME = 'openHPI.cn'
  MOOC_PROVIDER_API_LINK = 'https://openhpi.cn/api/v2/courses'
  COURSE_LINK_BODY = 'https://openhpi.cn/courses/'
end
