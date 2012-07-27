require 'helper'

class StorageTest < Test::Unit::TestCase
  context "Storing files" do
    setup do
      @avatar = Avatar.create
      @data = StringIO.new("my avatar image")
    end

    should "store the file" do
      @avatar.put_file("an_avatar.png", @data)
      @avatar.save
      avatar = Avatar.find(@avatar.id)
      data = avatar.fetch_file("an_avatar.png").data
      data.should == "my avatar image"
    end

    should "not close the file after storing" do
      @avatar.put_file("an_avatar.png", @data)
      @data.should_not be_closed
    end

    context "in attributes" do
      should "store the given file" do
        @avatar.data = @data
        @avatar.save!
        @avatar.data.should_not be_nil
        @avatar.data.data.should == "my avatar image"
      end
    end

    context "with new objects" do
      setup do
        @avatar = Avatar.new
      end

      should "store the data correctly" do
        @avatar.data = @data
        @avatar.save
        @avatar = Avatar.find(@avatar.id)
        @avatar.data.data.should == "my avatar image"
      end

      should "store the file after saving" do
        @avatar.put_file("an_avatar.png", @data)
        @avatar.save
        @avatar.fetch_file("an_avatar.png").data.should == "my avatar image"
      end

      should "not store the file if object is new" do
        @avatar.put_file("an_avatar.png", @data)
        @avatar.fetch_file("an_avatar.png").data.should be_nil
      end
    end

    context "with lists" do
      setup do
        @avatar = Avatar.new
        @alternative = File.new(__FILE__)
        @data = File.read(__FILE__)
      end
      teardown do
        @alternative.close
      end

      should "store the file" do
        @avatar.first_alternative = @alternative
        @avatar.save
        fromdb = @avatar.reload
        fromdb.first_alternative.data.should == @data
      end

      should "store the file in the alternative list" do
        @avatar.alternatives.put("an_alternative", @alternative)
        @avatar.save
        @avatar.reload
        @avatar.alternatives.get("an_alternative").data.should == @data
      end
    end
  end

  context "Fetching files" do
    setup do
      @avatar = Avatar.create
      @data = StringIO.new("my avatar image")
    end

    should "fetch the list of files" do
      @avatar.put_file("file1", StringIO.new("data1"))
      @avatar.put_file("file2", StringIO.new("data2"))
      @avatar.put_file("file3", StringIO.new("data3"))
      file_names = @avatar.files.map { |f| f.filename }
      file_names.size.should == 3
      file_names.should include("file1")
      file_names.should include("file2")
      file_names.should include("file3")
    end

   should "iterate the list of files" do
      @avatar.put_file("file1", StringIO.new("data1"))
      @avatar.put_file("file2", StringIO.new("data2"))
      @avatar.put_file("file3", StringIO.new("data3"))
      file_names = %w[file1 file2 file3]
      @avatar.file_list.each_file do |key, file|
        file_names.should include key
        file_names.should include file.filename
      end
   end
  end
end
