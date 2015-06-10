# -*- encoding : utf-8 -*-
class DashboardController < ApplicationController
  NUMBER_OF_SHOWN_RECOMMENDATIONS = 2

  def dashboard
    # Recommendations
    all_my_sorted_recommendations = Recommendation.filter_users(current_user.recommendations, [current_user]).sort_by(&:created_at).reverse!
    @recommendations = all_my_sorted_recommendations.first(NUMBER_OF_SHOWN_RECOMMENDATIONS)
    @number_of_recommendations = all_my_sorted_recommendations.length
    @provider_logos = AmazonS3.instance.provider_logos_hash_for_recommendations(@recommendations)
    @profile_pictures = User.author_profile_images_hash_for_recommendations(@recommendations)
    @rating_picture = AmazonS3.instance.get_url('five_stars.png')
    @user_picture = @current_user.profile_image.expiring_url(3600, :square)
    # Bookmarks
    @bookmarks = current_user.bookmarks

    @activities = PublicActivity::Activity.all

    respond_to do |format|
      format.html {}
      format.json { render :dashboard, status: :ok }
    end
  end
end
