require 'set'

class BookmarkController < Ramaze::Controller
  map '/uri'
  helper :stack, :user

  layout '/page' => [ :add, :edit, :search ]

  def add
    if ! logged_in?
      call R( MainController, :login )
    end

    uri = h( request[ 'uri' ] )
    if request.post?
      bm = Bookmark.find_or_create( :uri => uri )

      user.bookmark_add(
        bm,
        h( request[ 'title' ] ),
        h( request[ 'notes' ] )
      )

      bm.tags_ensure( requested_tags, user )

      redirect Rs( :edit, bm.id )
    else
      @bookmark = BookmarkStruct.new
      @bookmark.uri = uri
      @bookmark.uri_editable = true
      @bookmark.title = h( request[ 'title' ] )
    end
  end

  def edit( bookmark_id )
    if ! logged_in?
      call R( MainController, :login )
    end

    bm = Bookmark[ bookmark_id.to_i ]
    if bm.nil?
      redirect Rs( :add )
    end

    if request.post?
      bm.set_title( user, h( request[ 'title' ] ) )
      bm.set_notes( user, h( request[ 'notes' ] ) )
      bm.tags_ensure( requested_tags, user )
      flash[ :success ] = "Updated #{bm.uri}."
    end

    @bookmark = bm.to_struct( user )
  end

  def search
    @bookmarks = Set.new
    @tags = Set.new
    requested_tags.each do |tagname|
      tag = Tag[ :name => tagname ]
      if tag
        @tags << tag
        tag.bookmarks.each do |bm|
          @bookmarks << bm
        end
      end
    end
  end

  def requested_tags
    tags_in = request[ 'tags' ]
    if tags_in && tags_in.any?
      tags_in.split( /[\s,+]+/ ).collect { |tag| h( tag ) }
    else
      []
    end
  end
  private :requested_tags
end