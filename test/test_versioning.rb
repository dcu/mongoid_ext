require 'helper'

class TestVersioning < Test::Unit::TestCase
  context "working with versions" do
    setup do
      BlogPost.delete_all
      User.delete_all

      @blogpost = BlogPost.create!(:title => "operating systems",
                                   :body => "list of some operating systems",
                                   :tags => %w[list windows freebsd osx linux],
                                   :updated_by => User.create(:login => "foo"))
    end

    should "generate a new version" do
      @blogpost.versions_count.should == 0
      @blogpost.title = "sistemas operativos"
      @blogpost.save!
      @blogpost.reload
      @blogpost.versions_count.should == 1
    end

    should "be able to generate a diff between versions" do
      @blogpost.title = "sistemas operativos"
      @blogpost.save!
      @blogpost.reload
      @blogpost.diff_by_word(:title, "current", 0, :ascii).should == "{\"operating\" >> \"sistemas\"} {\"systems\" >> \"operativos\"}"
      @blogpost.diff_by_line(:title, 0, "current", :ascii).should == "{\"sistemas operativos\" >> \"operating systems\"}"
    end

    should "be able to restore a previous version" do
      @blogpost.title = "sistemas operativos"
      @blogpost.save!
      @blogpost.reload

      @blogpost.title.should == "sistemas operativos"
      @blogpost.rollback!(0)
      @blogpost.title.should == "operating systems"
    end

    should "respect the max versions limit" do
      @blogpost.title = "sistemas operativos"
      @blogpost.save!
      @blogpost.reload
      @blogpost.title = "sistemas operativos 2"
      @blogpost.save!
      @blogpost.reload
      @blogpost.title = "sistemas operativos 3"
      @blogpost.save!
      @blogpost.reload

      @blogpost.versions.count.should == 2
    end
  end
end
