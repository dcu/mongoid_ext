require 'helper'

class ModifiersTest < Test::Unit::TestCase
  context "Modifying documents" do
    setup do
      @entry = Entry.create(:v => 345)
    end

    should "increment the value" do
      Entry.increment({:_id => @entry.id}, {:v => 1})
      @entry.reload
      @entry.v.should == 346
    end

    should "decrement the value" do
      @entry.decrement(:v => 1)
      @entry.reload
      @entry.v.should == 344
    end

    should "override the value" do
      @entry.override(:v => 543)
      @entry.reload
      @entry.v.should == 543
    end

    should "unset the value" do
      @entry.unset(:v => true)
      @entry.reload
      @entry.v.should == nil
    end

    should "push a value" do
      @entry.push(:a => 1)
      @entry.reload
      @entry.a.should == [1]
    end

    should "not duplicate the value" do
      @entry.push_uniq(:a => 1)
      @entry.push_uniq(:a => 1)
      @entry.push_uniq(:a => 1)
      @entry.reload
      @entry.a.should == [1]
    end

    should "pull a value" do
      @entry.push_uniq(:a => 1)
      @entry.push_uniq(:a => 2)
      @entry.push_uniq(:a => 3)
      @entry.pull(:a => 2)
      @entry.reload
      @entry.a.should == [1, 3]
    end

    should "pop the last value" do
      @entry.push_uniq(:a => 1)
      @entry.push_uniq(:a => 2)
      @entry.push_uniq(:a => 3)
      @entry.pop(:a => 1)
      @entry.reload
      @entry.a.should == [1, 2]
    end
  end
end
