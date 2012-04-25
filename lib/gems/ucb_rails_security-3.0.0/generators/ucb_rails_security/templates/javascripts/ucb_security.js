
var DoubleSelectList = {
    /* Takes the dom Ids of two Select Elements. Moves the
     * options from the Element with fromId that are selected
     * to the Element with toId
     */
    moveSelected: function(fromId, toId) {
        var fromList = $(fromId)
        var toList = $(toId)
  
        if (!fromList) {
            throw new Error("Dom id for fromId not found: " + fromId)
        } else if (!toList) {
            throw new Error("Dom id for toId not found: " + toId)
        }
  
        this._transferSelected(fromList, toList);
    },
    /* Takes the dom Ids of two Select Elements. Moves all the
     * options from the Element with fromId to the Element
     * with toId
     */
    moveAll: function(fromId, toId) {
        var fromList = $(fromId)
        var toList = $(toId)

        if (!fromList) {
            throw new Error("Dom id for fromId not found: " + fromId)
        } else if (!toList) {
            throw new Error("Dom id for toId not found: " + toId)
        }

        this._transferAll(fromList, toList);
    },
    /*
     * Takes an array of Option elements and sets their selected attribute to true/false.
     *
     *   setSelectedToFalse([<option selected=true></option>], false)
     *   => [<option selected=false></option>]
     */
    setOptionsSelectedAttribute: function(selectOptions, selectedValue) {
        return selectOptions.map( 
            function(elem) { 
                elem.selected = selectedValue;
                return elem;
            }
        );

    },
    /**
     * When the form is submitted, we want to make sure the values from both
     * select lists are sent to our controller/action.  Only select options
     * that have their selected attribute set to true actually get submitted.
     * We call this function the first time the page loads and as soon as the
     * submit button is clicked, it updates the selected attribute of both
     * select lists to true
     */
    initSubmitCallback: function(buttonId, fromId, toId) {
        var fromOptions = $(fromId).childElements();      
        var toOptions = $(toId).childElements();
        $(buttonId).observe('click', function() { fromOptions.each(function(elem) {elem.selected = true}) })
        $(buttonId).observe('click', function() { toOptions.each(function(elem) {elem.selected = true}) })
    },


    /************************************************************************
     * Private Methods 
     ************************************************************************/

    _transferAll: function(fromList, toList) {
        var fromOptions = fromList.childElements();
        var toOptions = toList.childElements();
        var newOptions = new Array(fromOptions, toOptions).flatten();

        newOptions = newOptions.sort(this._optionsSorter);
        newOptions = this.setOptionsSelectedAttribute(newOptions, false);
        toOptions.each( function(elem) { elem.remove(); } );
        newOptions.each( function(elem) { toList.insert(elem); } );
    },
    _transferSelected: function(fromList, toList) {
        var selFromOptions = fromList.childElements().select( 
            function(elem) { return elem.selected }
        );
        selFromOptions = this.setOptionsSelectedAttribute(selFromOptions, false);
        
        var toOptions = toList.childElements();
        var newOptions = new Array(selFromOptions, toOptions).flatten();
        newOptions = newOptions.sort(this._optionsSorter);
        newOptions.each( function(elem) { toList.insert(elem) } );
    },
    /*
     * To be used as a comparison function with Array.sort. Compares the
     * the text of two Option elements and sorts them Alpha ASC.
     */
    _optionsSorter: function(option1, option2) {
        return option1.text > option2.text ? 1 : (option1.text < option2.text ? -1 : 0);
    },

};