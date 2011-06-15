function find_tags(collection, regex, query, limit) {
  var counter = function(collection, regex, query){
      var counts = {};
      db[collection].find(query, {"tags":1}).limit(500).forEach(
        function(p){
          if ( p.tags ){
            for ( var i=0; i<p.tags.length; i++ ){
              var name = p.tags[i];
              if(name.match(regex) != null)
                counts[name] = 1 + ( counts[name] || 0 );
            }
          }
        }
      );
      return counts;
  };

  var counts = counter(collection, regex, query);

  var tags = [];
  for ( var tag in counts ){
    tags.push( { name : tag , count : counts[tag] } )
  }

  return tags;
}
