require 'helper'

class TestParanoia < Test::Unit::TestCase
  context "working with versions" do
    setup do
      User.delete_all
      User.deleted.delete_all

      @user = User.create(:login => "foo",
                          :email => "foo@bar.baz")
    end

    should "not delete permanently the record" do
      @user.destroy
      User.deleted.count.should == 1
      User.count.should == 0
    end

    should "restore the deleted record" do
      @user.destroy
      User.deleted.first.restore.email.should == "foo@bar.baz"
    end

    should "delete the old records" do
      @user.destroy
      deleted = User.deleted.first
      deleted.created_at = 2.months.ago
      deleted.save

      User.deleted.compact!
      User.deleted.count.should == 0
    end
  end
end
