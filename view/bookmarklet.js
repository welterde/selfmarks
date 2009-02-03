function load_js( uri, id ) {
    var script_tag = document.getElementById( id );
    if( script_tag ) {
        script_tag.parentNode.removeChild( script_tag );
    }
    var script  = document.createElement( 'SCRIPT' );
    script.type = 'text/javascript';
    script.src  = uri;
    script.id   = id;
    document.getElementsByTagName('head')[0].appendChild( script );
}

( function() {
    load_js( 'http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js', 'selfmarks-jquery' );
    load_js( '#{SelfMarks::HOST}/uri/add_window.js', 'selfmarks-javascript' );
} )();