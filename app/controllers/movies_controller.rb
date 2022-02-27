class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      # @movies = Movie.all
      
      sortby = params[:sort_by]
      @all_ratings = Movie.get_all_ratings
      
      filter = params[:ratings]

      if filter != nil
        # @movies = Movie.with_ratings(filter)
        # return
        session[:filter_ratings] = filter
      end
      
      if sortby != nil
        session[:order] = sortby
      end

      if sortby == nil and filter == nil and (session[:filter_ratings] != nil or session[:order] != nil)
        filter = session[:filter_ratings]
        sortby = session[:order]
        flash.keep
        redirect_to movies_path({sort_by: order, ratings: filter_ratings})
      end
      sortby = session[:order]
      filter = session[:filter_ratings]
      
      if sortby == nil
        @movies = Movie.all()
      else
        @movies = Movie.all().order(sortby)
        if sortby == 'title'
          @table_title = 'bg-warning'
        elsif sortby == 'release_date'
          @table_date = 'bg-warning'
        end
      end
      if filter != nil
        @movies = @movies.select{ |movie| filter.include? movie.rating}
      end
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end