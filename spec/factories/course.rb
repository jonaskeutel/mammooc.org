FactoryGirl.define do

  factory :course do
    name 'Minimal Technologies'
    url 'https://test.com/course'
    start_date DateTime.new(2016,02,16,8)
    end_date DateTime.new(2016,02,28,20)
    sequence(:provider_course_id ) { |n| "a#{n}" }
  end

  factory :full_course, class: Course do
    name 'Full Technologies'
    url 'https://open.hpi.de/courses/webtech2015'
    course_instructors ['Prof. Dr. Christoph Meinel', 'Jan Renz', 'Thomas Staubitz']
    abstract 'WWW, the world wide web or shortly the web - really nothing more than an information  service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.'
    description 'WWW, the world wide web or shortly the web - really nothing more than an information service on the Internet – has changed our world by creating a whole new digital world that is closely intertwined with our real world, making reality what was previously unimaginable: communication across the world in seconds, watching movies on a smartphone, playing games or looking at photos with remote partners in distant continents, shopping or banking from your couch … In our online course on web technologies you will learn how it all works.

We start off by introducing the underlying technologies of the web: URI, HTTP, HTML, CSS and XML. If this sounds cryptic, rest assured that you will soon become familiar with what it’s all about. We will then focus on web services and web programming technologies along with their practical application. And we will look at how search engines – our fast and reliable signposts in the digital world – actually work to find contents and services on the web. The course concludes with a look at cloud computing and how it is changing the way we will access computing power in the future.

Here’s what participants are saying about this course:

Ralf: “The concept is great and methodically and didactically well thought out. We all noticed that further development is continually going on here - indispensable in dealing with this topic today. The support and guidance from the help desk and forum were also outstanding. Thank you.”

Kerstin: “I have to honestly say that I am impressed by what you’ve accomplished here. The course was totally professional and the tasks were set up so that it was possible to learn a lot. It was important for me to get an overview of the technologies and relationships between them. The class was taught really well and it was fun too.”

Claudia; “I enjoyed this course so much. It gave me a chance to expand my horizons in web technologies a great deal. I really liked the practical homework exercises, especially the calculation task in Week 5. I’m already looking forward to the next course. Keep up the good work!”'
    language 'English'
    imageId 'https://open.hpi.de/files/45ce8877-d21b-4389-9032-c6525b4724d0'
    videoId ''
    start_date DateTime.new(2015,6,1,8)
    end_date DateTime.new(2015,7,20,23,30)
    costs 10
    price_currency '€'
    type_of_achievement 'Certificate'
    categories ['Web','Technologies','Computer Science','#geilon']
    requirements %w[Computer Brain Strength]
    difficulty 'medium'
    minimum_weekly_workload 7
    maximum_weekly_workload 45
    sequence(:provider_course_id ) { |n| "#{n}" }
    credit_points 6
    open_for_registration true
  end

end
