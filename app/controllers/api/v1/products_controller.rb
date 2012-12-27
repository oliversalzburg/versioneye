class Api::V1::ProductsController < ApplicationController

  def search
    @query = do_parse_search_input(@query)
    @groupid = params[:g]
    @lang = get_lang_value( params[:lang] )

    error = nil
    if ( (@query.nil? || @query.empty?) && (@groupid.nil? || @groupid.empty?) )
      error = "Please give us some input. Type in a value for name."
    elsif @query.length == 1
      error = "Search term is to short. Please type in at least 2 characters."
    elsif @query.include?("%")
      error = "the character % is not allowed"
    else
      start = Time.now
      languages = get_language_array(@lang)
      @products = ProductService.search( @query, @groupid, languages, params[:page])
      save_search_log( @query, @products, start )
    end    
    respond_to do |format|
      format.json { 
        if error
          render :json => "[#{error}]"    
        else 
          render :json => @products.to_json(:only => [:name, :version, :prod_key, :group_id, :artifact_id, :language] ) 
        end
      }
    end
  end

  def follow
    product_key = url_param_to_origin params[:product_key]
    respond = ProductService.create_follower product_key, current_user
    respond_to do |format|
      format.json { render :json => "[#{respond}]" }
    end
  end
  
  def unfollow
    src_hidden = params[:src_hidden]
    product_key = url_param_to_origin params[:product_key]
    respond = ProductService.destroy_follower product_key, current_user
    respond_to do |format|
      format.json { render :json => "[#{respond}]" }
    end
  end

end