$(function() {
  $('code').each(function() {
    var $this = $(this);
    var klass = $this.prop('class');
    var split = klass.split(':');
    var lang = split[0];
    var name = split[1];
    if (name) {
      var $pre = $this.parent('pre');
      var caption = ['<h6>', name, '</h6>'].join('');
      $pre.before(caption);
    }
  })
})
