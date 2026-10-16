class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    @entries = HomeFeed.entries(include_drafts: authenticated?)
  end
  def about; end
  def projects; end
end
