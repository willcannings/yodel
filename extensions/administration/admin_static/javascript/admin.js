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
  if(sidebarOpen)
    toggleSidebar();
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


/* selecting and unselecting record */
function selectRecord(record) {
  $(record.id).addClassName('selected');
}

function unselectAllRecords() {
  $$('.record_row').each(function(row) {
    row.removeClassName('selected');
  })
}


/* creating records */
function newRecord(type, url) {
  showSection('model_' + type);
  currentSection.down('.submit').value = 'Create';
  currentSection.down('form').action = url;
  currentSection.down('form').method = 'POST';
}


/* loading records */
var LOAD_RECORD_ERROR = "An error occurred loading this record"
function loadRecord(url) {
  new Ajax.Request(url, {method: 'get', onSuccess: processRecord})
}

function processRecord(transport) {
  if(transport.responseJSON && transport.responseJSON.record && transport.responseJSON.type) {
    record = transport.responseJSON.record;
    type = transport.responseJSON.type;
    
    /* show the correct form and change the submit text */
    showSection('model_' + type);
    currentSection.down('.submit').value = 'Save';
    
    /* reset the form action to perform an update */
    currentSection.down('form').action = transport.request.url;
    currentSection.down('form').method = 'POST';
    
    /* highlight the selected record */
    unselectAllRecords();
    selectRecord(record);
    
    /* show the record's values in the form */
    $H(record).each(function(pair) {
      $(type + '_' + pair.key).value = pair.value;
    });
  } else {
    alert(LOAD_RECORD_ERROR);
  }
}


/* event listeners */
document.observe("dom:loaded", function() {
  // opening a side bar
  $$('section aside').each(function(sidebar) {
    sidebar.observe('click', function(event) {
      if(sidebarOpen)
        return;
      toggleSidebar();
    });
  });
  
  // closing the sidebar
  $$('section aside .close').each(function(closebox) {
    closebox.observe('click', function(event) {
      toggleSidebar();
      event.stop();
    });
  });
  
  // switching between side bar tabs
  $$('section aside ul li a').each(function(tab) {
    tab.observe('click', function(event) {
      selectTab(Event.element(event).up('li'));
      event.stop();
    });
  });
  
  // clicking the cancel button
  $$('.cancel').each(function(button) {
    button.observe('click', function(event) {
      hideAllSections();
      unselectAllRecords();
      event.stop();
    })
  });
});
