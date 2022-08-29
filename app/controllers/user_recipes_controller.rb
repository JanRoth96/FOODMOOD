class UserRecipesController < ApplicationController
  def create
    recipe = Recipe.find(params[:recipe_id])
    @user_recipe = UserRecipe.new(recipe: recipe, user: current_user)
    authorize @user_recipe
    if @user_recipe.save
      redirect_to recipes_path
    else
      render :recipes
    end
  end

  def cart
    @user_recipes = UserRecipe.where(saved: false, user: current_user)
    authorize @user_recipes
  end

  def update
    raise
    @user_recipe = UserRecipe.find(params[:id])
    authorize @user_recipe
    if @user_recipe.update(cart_params)
      @cart_recipes = UserRecipe.where(saved: false, user: current_user)
      if @cart_recipes.count != 0
        redirect_to cart_path, status: :see_other
      else
        redirect_to cookbook_path, status: :see_other
      end
    else
      render :edit
    end
  end

  def destroy
    @user_recipe = UserRecipe.find(params[:id])
    authorize @user_recipe
    @user_recipe.destroy
    redirect_to cart_path, status: :see_other
  end

  def cookbook
    @user_recipes = UserRecipe.where(saved: true, user: current_user)
    authorize @user_recipes
  end

  private

  def cart_params
    params.require(:user_recipe).permit(:saved, :cooked_status)
  end
end
