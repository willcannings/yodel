/* showing and hiding sections */
var currentSection = null;
function showSection(section) {
  if(currentSection)
    currentSection.hide();
  currentSection = $(section);
  currentSection.show();
}

function hideAllSections() {
  if(!currentSection)
    return;
  currentSection.hide();
  hideSidebar();
  currentSection = null;
}

/* sections side bars */
var sidebarOpen = false;
function toggleSidebar() {
  if(!currentSection)
    return;
  currentSection.toggleClassName('has_sidebar').toggleClassName('sidebar_open');
  currentSection.down('form').hide();
  setTimeout("currentSection.down('form').show()", 0);
  sidebarOpen = !sidebarOpen;
}

/* sidebar tabs */
function selectTab(element) {
  if(!currentSection)
    return;

  // remove the current selection
  selected = currentSection.down('aside ul li.selected');
  if(selected)
    selected.removeClassName('selected');
  
  // select the new tab
  element.addClassName('selected');
}

document.observe("dom:loaded", function() {
  $$('section aside').each(function(sidebar) {
    sidebar.observe('click', function(event) {
      if(sidebarOpen)
        return;
      toggleSidebar();
    });
  });
  
  $$('section aside .close').each(function(closebox) {
    closebox.observe('click', function(event) {
      toggleSidebar();
      event.stop();
    });
  });
  
  $$('section aside ul li a').each(function(tab) {
    tab.observe('click', function(event) {
      selectTab(Event.element(event).up('li'));
      event.stop();
    });
  });
  
  showSection('model_page');
});
