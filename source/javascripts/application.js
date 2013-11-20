var getHatebuCount = function(permalink) {
  $.ajax({
    type: 'GET',
    url: 'http://api.b.st-hatena.com/entry.count',
    data: {
      url: permalink
    },
    dataType: 'jsonp',
    success: function(data) {
      var count = (data) ? data : 0;
      $('.hatebu .count').text(count);
    }
  });
};

var getFacebookShareCount = function(permalink) {
  $.ajax({
    type: 'GET',
    url: 'http://graph.facebook.com/' + permalink,
    dataType: 'jsonp',
    success: function(data) {
      var count = (data) ? data.shares : 0;
      $('.facebook .count').text(count);
    }
  });
};
