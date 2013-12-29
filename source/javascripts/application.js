$(".share .facebook a").on('click', function(e) {
  e.preventDefault();
  window.open(this.href, 'FBwindow', 'width=650, height=450, menubar=no, toolbar=no, scrollbars=yes');
});

$(".share .twitter a").on('click', function(e) {
  e.preventDefault();
  window.open(this.href, 'TWwindow', 'width=650, height=450, menubar=no, toolbar=no, scrollbars=yes');
});
