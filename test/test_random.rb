require 'helper'

class TestRandom < Test::Unit::TestCase
  context "working with tags" do
    setup do
    end

    should "find a random entry" do
      Entry.random.should_not be_nil
      Entry.random.should_not be_nil
      Entry.random.should_not be_nil
    end

    should "increment the counter" do
      entry = Entry.random
      entry._random_times.should > 0
    end

    should "allow to pass conditions" do
      entry = Entry.random(:v => 10)
      entry.v.should == 10
    end

#
#     should "generate the tagcloud" do
#       cloud = BlogPost.tag_cloud
#
#       [{"name"=>"list", "count"=>2.0},
#        {"name"=>"windows", "count"=>1.0},
#        {"name"=>"freebsd", "count"=>1.0},
#        {"name"=>"osx", "count"=>1.0},
#        {"name"=>"linux", "count"=>1.0},
#        {"name"=>"mongodb", "count"=>1.0},
#        {"name"=>"redis", "count"=>1.0},
#        {"name"=>"couchdb", "count"=>1.0}].each do |entry|
#         cloud.should include(entry)
#       end
#     end
#
#     should "find blogpost that include the given tags" do
#       BlogPost.find_with_tags("mongodb").to_a.should == [@blogpost2]
#       posts = BlogPost.find_with_tags("mongodb", "linux").to_a
#       posts.should include(@blogpost)
#       posts.should include(@blogpost2)
#       posts.size.should == 2
#     end
#
#     should "find tags that start with li" do
#       tags = BlogPost.find_tags(/^li/)
#       [{"name"=>"list", "count"=>2.0}, {"name"=>"linux", "count"=>1.0}].each do |entry|
#         tags.should include(entry)
#       end
#       tags.size.should == 2
#     end

  end
end
