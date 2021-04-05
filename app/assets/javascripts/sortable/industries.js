$(function() {
  let el = document.getElementById("sortable-industries");
  if (el != null) {
    const sortable = Sortable.create(el, {
      animation: 150,
      delay: 100,
      onUpdate: function(evt) {
        $.ajax({
          type: "PATCH",
          url: "<%= sort_employees_settings_companies_industries_path %>",
          cache: false,
          data: { from: evt.oldIndex, 
                  to: evt.newIndex, 
                  remote: true }
        });
      }
    });
  }
});
