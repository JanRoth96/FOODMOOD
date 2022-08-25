# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require "open-uri"

puts "Destroying all the Recipes..."
# Recipe.destroy_all

puts "Creating 100 dinner Recipes..."

dinner_recipes_meta = GetRecipesService.new('dinner').call
10.times do
  dinner_recipes = dinner_recipes_meta["hits"]
  dinner_recipes.each do |recipe|
    if recipe["recipe"]["totalTime"] != 0 && recipe["recipe"]["calories"] != 0 && recipe["recipe"]["yield"] != 0
      rec = Recipe.create!(
        name: recipe["recipe"]["label"],
        cooking_time: recipe["recipe"]["totalTime"],
        calories: recipe["recipe"]["calories"],
        source: recipe["recipe"]["source"],
        url: recipe["recipe"]["url"],
        yield: recipe["recipe"]["yield"],
        cuisine_type: recipe["recipe"]["cuisineType"].first,
        # meal_type: recipe["recipe"]["mealType"].first,
        # dish_type: recipe["recipe"]["dishType"].first
      )

      delete = 0

      recipe["recipe"]["ingredients"].each do |ingredient|
        food = Food.find_or_create_by!(
          name: ingredient["food"],
          category: ingredient["foodCategory"],
          edamam_id: ingredient["foodId"]
        )
        if ingredient["measure"] != "<unit>" && ingredient["quantity"] != 0
          Ingredient.create!(
            recipe: rec,
            food: food,
            quantity: ingredient["quantity"],
            measure: ingredient["measure"]
          )
        else
          delete += 1
        end
      end
      url = recipe["recipe"]["images"]["REGULAR"]["url"]
      file = URI.open(url)
      rec.photo.attach(io: file, filename: "#{rec.name}.jpg", content_type: "image/jpg")
      rec.save
      rec.destroy if delete != 0
    end

  end
  url = dinner_recipes_meta["_links"]["next"]["href"]
  dinner_recipes_meta = JSON.parse(URI.open(url).read)
  puts "Hop"
end
puts "Done!"

puts "Creating User"

User.create!(email: "daniel.hamm@gmx.de", name: "Daniel Hamm", password: "123456")

puts "Done!"
