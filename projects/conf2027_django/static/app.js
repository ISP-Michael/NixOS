document.addEventListener('submit', function (event) {
  var form = event.target.closest('.status-form');
  if (!form) {
    return;
  }

  var select = form.querySelector('select[name=status]');
  if (!select) {
    return;
  }

  var chosen = select.options[select.selectedIndex].text;
  if (!window.confirm('Изменить статус заявки на «' + chosen + '»?')) {
    event.preventDefault();
  }
});