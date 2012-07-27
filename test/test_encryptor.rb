require 'helper'

class StorageTest < Test::Unit::TestCase
  context "Encrypting fields" do
    setup do
      @cc = CreditCard.create(:number => 12345, :data => {:month => 10, :year => 2014})
    end

    should "be able to load the number" do
      @cc.reload
      @cc.number.should == 12345
    end

    should "be able to load a hash or array" do
      @cc.reload
      @cc.data.should == {:month => 10, :year => 2014}
    end

    should "encrypt the field" do
      @cc.reload
      @cc.data_encrypted.should == 'd3f1d84f75f95027af7697f59c07437508ec98377a6d4104c7d7dc79967bf46b'
    end

    should "not fail with nil values" do
      @cc.data = nil
      @cc.save
      @cc = CreditCard.find(@cc.id)
      @cc.data.should == nil
    end
  end
end
