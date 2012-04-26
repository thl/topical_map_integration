require_dependency 'application_controller'

class CategoriesController < ApplicationController
  before_filter :find_main_category
  respond_to :html, :xml, :js
  
  # GET /categories
  # GET /categories.xml
  def index
    if @main_category.nil?
      @categories = Category.find(:all, :conditions => {:parent_id => nil}, :order => 'title')
    else
      @categories = @main_category.children
    end
    selected_category_id = params[:selected_category_id]
    if !selected_category_id.blank?
      @category = Category.find(selected_category_id)
      @ancestors_for_current = @category.ancestors.collect{|c| c.id.to_i} + [@category.id.to_i]
    end
    respond_to do |format|
      format.html { render :partial => 'select_index', :locals => {:categories => @categories} if request.xhr? }
      format.xml  { render :xml => @categories }
    end
  end

  # GET /categories/1
  # GET /categories/1.xml
  def show
    @category = Category.find(params[:id])
    if @main_category.nil?
      @categories = Category.find(:all, :conditions => {:parent_id => nil}, :order => 'title')
    else
      @categories = @main_category.children
    end
    @ancestors_for_current = @category.ancestors.collect{|c| c.id.to_i} + [@category.id.to_i]
    respond_with(@category)
  end
  
  # renders expand.js.erb
  def expand
    @category = Category.find(params[:id])
    @margin_depth = params[:margin_depth].to_i
  end

  # renders contract.js.erb
  def contract
    @category = Category.find(params[:id])
    @margin_depth = params[:margin_depth].to_i
  end
  
  private
  
  def find_main_category
    category_id = params[:category_id]
    if category_id.blank?
      @main_category = nil
    else
      @main_category = Category.find(category_id)
    end
  end  
end