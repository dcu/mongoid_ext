require 'helper'

class OpenStructTest < Test::Unit::TestCase
  def from_db
    UserConfig.find(@config.id)
  end

  context "working with sets" do
    setup do
      @config = UserConfig.create!()
    end

    should "allow to add new keys" do
      entries = MongoidExt::OpenStruct.new()
      entries.new_key = "my new key"
      @config.entries = entries
      @config.save

      from_db.entries.new_key.should == "my new key"
    end
  end
end
