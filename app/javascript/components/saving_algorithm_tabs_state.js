$(document).ready(function(){

    var currentPage = window.location.href.split("/").at(-2)

    if (currentPage == 'algorithm_versions') {
        console.log("Saving algorithm tabs state loaded")

        var elements = [$('[data-toggle="algorithm-tab"]'), $('[data-toggle="improvements-tab"]'),
            $('[data-toggle="usage-examples-tab"]'), $('[data-toggle="settings-tab"]'),];

        var combinedObj = $.map(elements, function(el){return el.get()});
        $(combinedObj).on('click', function(ev){
            console.log(`id: ${$(ev.target).attr('id')} saved to localstorage `)
            localStorage.setItem('activeAlgorithmTabId', $(ev.target).attr('id'));
        });

        var activeTabId = localStorage.getItem('activeAlgorithmTabId');
        console.log("Got from localstoarege")
        if(activeTabId){

            console.log(`active tab: ${activeTabId} clicked`)
            console.log($("#"+ activeTabId))

            $("#"+ activeTabId).click()
            if ($("#"+ activeTabId).attr("aria-selected") == 'false') {
                console.log("Second select fired!")
                setTimeout($("#"+ activeTabId).click(), 300000);
            }
        }
    }


});