var wrap_data_value = function(data) {
    return '<div>' + data.value + '</div>';
};

var filter_value = function(result) {
    return result.value.replace(/<strong>|<\/strong>|<i>|<\/i>/g, '');
};

var init_typeahead = function(){ 

  var authors = new Bloodhound({
        datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.value);},
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        remote: {
            url: '/typeahead?type=author&q=%QUERY',
            wildcard: '%QUERY'
            //filter: function (results) {

            //    return $.map(results, function (result) {
            //        return { value: result.value };
            //    });
            //}
        }
  });

  var quotes = new Bloodhound({
        datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.value);},
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        remote: {
            url: '/typeahead?type=quote&q=%QUERY',
            wildcard: '%QUERY'
        }
  });

  var categories = new Bloodhound({
        datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.value);},
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        remote: {
            url: '/typeahead?type=category&q=%QUERY',
            wildcard: '%QUERY'
        }          
  });

  authors.initialize(); 
  quotes.initialize();
  categories.initialize();

  $('#q').typeahead(
    {
        hint: true,
        highlighter: true,
        minLength: 1
    }, 
    {
        name: 'authors',
        displayKey: 'value',
        display: filter_value,
        source: authors.ttAdapter(),
        templates: {
            header: '<h3 class="type">Authors</h3>',
            suggestion: wrap_data_value
        }
    },
    {
        name: 'categories',
        displayKey: 'value',
        display: filter_value,
        source: categories.ttAdapter(),
        templates: {
            header: '<h3 class="type">Categories</h3>',
            suggestion: wrap_data_value

        }
    },
    {
        name: 'quotes',
        displayKey: 'value',
        display: filter_value,
        source: quotes.ttAdapter(),
        templates: {
            header: '<h3 class="type">Quotes</h3>',
            suggestion: wrap_data_value
        }
    }
  ); 

  $('#q').bind('typeahead:render', function(ev, suggestion) {
    var $authors = $('.tt-dataset-authors');
    var $categories = $('.tt-dataset-categories');

    var authors_hasChildren = ($authors.children().length > 0); 
    var categories_hasChildren = ($categories.children().length > 0);
    if(authors_hasChildren && categories_hasChildren) {
        $authors.css('width', '50%');
        $categories.css('width', '50%');
    } else {
        $authors.css('width', '100%');
        $categories.css('width', '100%');
    }
  });

};

$(document).on('page:load', init_typeahead);
$(document).ready(init_typeahead);

  
