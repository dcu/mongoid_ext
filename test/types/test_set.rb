require 'helper'

class SetTest < Test::Unit::TestCase
  def from_db
    Recipe.find(@recipe.id)
  end

  context "working with sets" do
    setup do
      @recipe = Recipe.new
      @recipe.ingredients = Set.new(%w[salt sugar water salt sugar water])
      @recipe.save
    end

    should "not have duplicates" do
      from_db.ingredients.size.should == 3
      from_db.ingredients.should include("salt")
      from_db.ingredients.should include("sugar")
      from_db.ingredients.should include("water")
    end

    should "not add duplicates" do
      original_size = @recipe.ingredients.size
      @recipe.ingredients << "salt"
      @recipe.save
      @recipe.reload

      @recipe.ingredients.size.should == original_size
    end
  end
end
