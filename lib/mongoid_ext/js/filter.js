function filter(collection, q, config) {
  var results = [];
  var counter = 0;

  var fields = {_keywords: 1};
  for(var i in config.select) {
    fields[config.select[i]] = 1;
  }

  var time = new Date().getTime();
  db[collection].find(q, fields).limit(500).forEach(function(doc) {
    var rac = db.eval(
      function(doc, config) {
        var r = [];
        var c = 0;

        var set = {};
        for(var i = 0; i<doc._keywords.length; i++) {
          set[doc._keywords[i]] = true;
        }

        var score = 0.0;
        for(var i = 0; i < config.words.length; i++) {
          var word = config.words[i];
          if(set[word]) {
            score += 15.0;
          }
        }

        for(var i = 0; i < config.stemmed.length; i++) {
          var word = config.stemmed[i];
          if(set[word]) {
            score += (1.0 + word.length);
          }
        }

        if(score >= config.min_score || 1.0 ) {
          delete doc._keywords;
          r.push({'score': score, 'doc': doc});
          c += 1;
        }

        return [r, c];
      },
      doc,
      config
    );

    for(var i = 0; i<rac[0].length; i++) {
      results.push(rac[0][i]);
    }
    counter += rac[1];
  });

  var sorted = results.sort(function(a,b) {
    return b.score - a.score;
  });

  time = (new Date().getTime() - time);

  return {total_entries: counter, elapsed_time:  time, results: sorted.slice(0, config.limit||500)};
}
