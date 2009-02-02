require 'set'

class BookmarkController < Ramaze::Controller
  map '/uri'
  helper :stack, :user

  layout '/page' => [ :add ]

  def add
    if ! logged_in?
      call R( MainController, :login )
    end

    @bookmark = BookmarkStruct.new

    if request.post?
      bm = Bookmark.find_or_create( :uri => h( request[ 'uri' ] ) )

      user.bookmark_add(
        bm,
        h( request[ 'title' ] ),
        h( request[ 'notes' ] )
      )

      requested_tags.each do |tag|
        t = Tag.find_or_create( :name => h( tag ) )
        bm.tag_add t, user
      end

      @bookmark.uri = bm.uri
      @bookmark.title = bm.title( user )
      @bookmark.tags = bm.tags( user )
      @bookmark.notes = bm.notes( user )
    else
      @bookmark.uri = h( request[ 'uri' ] )
      @bookmark.title = h( request[ 'title' ] )
    end
  end

  def edit
    if ! logged_in?
      call R( MainController, :login )
    end
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
      tags_in.split /[\s,+]+/
    else
      []
    end
  end
  private :requested_tags
end