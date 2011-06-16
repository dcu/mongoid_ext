require 'helper'

class TestVoteable < Test::Unit::TestCase
  context "working with votes" do
    setup do
      User.delete_all
      @user = User.create!(:login => "foo", :email => "foo@bar.baz")
    end

    should "store the votes average" do
      @user.vote!(1, "voter_id1")
      @user.vote!(1, "voter_id2")
      @user.vote!(-1, "voter_id3")

      @user.reload
      @user.votes_average.should == 1
    end

    should "store the votes count" do
      @user.vote!(1, "voter_id1")
      @user.vote!(1, "voter_id2")
      @user.vote!(-1, "voter_id3")
      @user.vote!(-1, "voter_id4")

      @user.reload
      @user.votes_count.should == 4
    end

    should "only store one vote by voter_id" do
      @user.vote!(1, "voter_id1")
      @user.vote!(1, "voter_id1")
      @user.vote!(1, "voter_id1")
      @user.reload
      @user.votes_count.should == 1
    end

    should "allow to change the vote" do
      @user.vote!(1, "voter_id1")
      @user.vote!(-1, "voter_id1")

      @user.reload
      @user.votes_count.should == 1
      @user.votes_average.should == -1
    end

    should "count the votes" do
      @user.vote!(1, "voter_id1")
      @user.vote!(1, "voter_id2")
      @user.vote!(-1, "voter_id3")
      @user.vote!(-1, "voter_id4")
      @user.vote!(-1, "voter_id5")

      @user.reload
      @user.votes_average.should == -1
      @user.votes_up.should == 2
      @user.votes_down.should == 3
    end

    should "check if a voter_id already voted" do
      @user.vote!("1", "voter_id1")
      @user.vote!("1", "voter_id2")

      @user.voted?("voter_id1").should be_true
      @user.reload
      @user.voted?("voter_id1").should be_true
      @user.voted?("voter_id3").should be_false
    end

    should "check the voter id even if votes was not loaded" do
      @user.vote!("1", "voter_id1")
      @user = User.without(:votes).find(@user.id)
      @user.voted?("voter_id1").should be_true
      @user.voted?("voter_id2").should be_false
    end
  end
end

