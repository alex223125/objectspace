// $(document).ready(function(){
//     $('[data-toggle="method-tab"]').on('click', function(e) {
//         console.log(`id: ${$(e.target).attr('id')} saved to localstorage `)
//         localStorage.setItem('activeTabId', $(e.target).attr('id'));
//     });
//     var activeTabId = localStorage.getItem('activeTabId');
//     console.log(`active tab: ${activeTabId} got from localstorage`)
//     if(activeTabId){
//         console.log(`active tab: ${activeTabId} clicked`)
//         $("#"+ activeTabId).click()
//     }
// });


// $(window).load(function() {
//     //dom not only ready, but everything is loaded
//     var currentPage = window.location.href.split("/").at(-2)
//     if (currentPage == 'unit_versions') {
//
//         //case 1 we have anchor from url
//
//         // case 2 we have remembered tab from tab reload
//
//         // var elements = [$('#blah'), $('#blup'), $('#gaga')];  //basically what you are starting with
//         //
//         // var combiObj = $.map(elements, function(el){return el.get()});
//         // $(combiObj).on('click', function(ev){
//         //     console.log('EVENT TRIGGERED');
//         // });
//
//
//         var elements = [$('[data-toggle="method-tab"]'), $('[data-toggle="improvements-tab"]'),
//             $('[data-toggle="usage-examples-tab"]'), $('[data-toggle="settings-tab"]')];
//
//
//         var combinedObj = $.map(elements, function(el){return el.get()});
//         $(combinedObj).on('click', function(ev){
//             console.log(`id: ${$(ev.target).attr('id')} saved to localstorage `)
//             localStorage.setItem('activeTabId', $(ev.target).attr('id'));
//         });
//
//         // $('[data-toggle="method-tab"]').on('click', function(e) {
//         //     console.log(`id: ${$(e.target).attr('id')} saved to localstorage `)
//         //     localStorage.setItem('activeTabId', $(e.target).attr('id'));
//         // });
//
//
//
//         var activeTabId = localStorage.getItem('activeTabId');
//         console.log(`active tab: ${activeTabId} got from localstorage`)
//         if(activeTabId){
//             console.log(`active tab: ${activeTabId} clicked`)
//             console.log($("#"+ activeTabId))
//             $("#"+ activeTabId).click()
//             // $("#"+ "improvements-tab")[0].click()
//         }
//     }
//
// });


// $(document).on('ready turbo:load turbo:render', function() {
//     var currentPage = window.location.href.split("/").at(-2)
//     if (currentPage == 'unit_versions') {
//
//         //case 1 we have anchor from url
//
//         // case 2 we have remembered tab from tab reload
//
//         // var elements = [$('#blah'), $('#blup'), $('#gaga')];  //basically what you are starting with
//         //
//         // var combiObj = $.map(elements, function(el){return el.get()});
//         // $(combiObj).on('click', function(ev){
//         //     console.log('EVENT TRIGGERED');
//         // });
//
//
//         var elements = [$('[data-toggle="method-tab"]'), $('[data-toggle="improvements-tab"]'),
//                         $('[data-toggle="usage-examples-tab"]'), $('[data-toggle="settings-tab"]')];
//
//
//         var combinedObj = $.map(elements, function(el){return el.get()});
//         $(combinedObj).on('click', function(ev){
//             console.log(`id: ${$(ev.target).attr('id')} saved to localstorage `)
//             localStorage.setItem('activeTabId', $(ev.target).attr('id'));
//         });
//
//         // $('[data-toggle="method-tab"]').on('click', function(e) {
//         //     console.log(`id: ${$(e.target).attr('id')} saved to localstorage `)
//         //     localStorage.setItem('activeTabId', $(e.target).attr('id'));
//         // });
//
//
//
//         var activeTabId = localStorage.getItem('activeTabId');
//         console.log(`active tab: ${activeTabId} got from localstorage`)
//         if(activeTabId){
//             console.log(`active tab: ${activeTabId} clicked`)
//             console.log($("#"+ activeTabId))
//             $("#"+ activeTabId).click()
//             makeElementVisible(activeTabId)
//             // $("#"+ activeTabId).click()
//             // $("#"+ "improvements-tab")[0].click()
//         }
//     }
//
//     $("#"+ "usage-examples-tab")
//
//     function makeElementVisible(activeTabId) {
//         if ($("#"+ "usage-examples-tab".split("-")[0]).attr("aria-selected") == 'true') {
//             return;
//         }
//
//         if ($("#"+ activeTabId.split("-")[0]).attr("aria-selected") == 'false') {
//             $("#"+ activeTabId).click()
//             makeElementVisible(activeTabId)
//         } else {
//             setTimeout(function(){
//                 makeElementVisible(activeTabId)
//             },2000);
//         }
//
//
//         // if ($("#"+ activeTabId.split("-")[0]).is(":visible")) {
//         //     $("#"+ activeTabId).click()
//         // } else {
//         //     setTimeout(makeElementVisible(activeTabId), 200000);
//         // }
//     }
//
//
//     // $(document).ready(function(){
//     //     console.log("Loaded")
//     //     // $('a[data-toggle="tab"]').on('show.bs.tab', function(e) {
//     //     $('[data-toggle="method-tab"]').on('click', function(e) {
//     //         console.log("Saved to localstorage")
//     //         localStorage.setItem('activeTab', $(e.target).attr('href'));
//     //     });
//     //     var activeTab = localStorage.getItem('activeTab');
//     //     console.log("Got from localstoarege")
//     //     if(activeTab){
//     //         console.log("Displayed")
//     //         console.log(activeTab)
//     //         $('#myTab a[href="' + activeTab + '"]').tab('show');
//     //     }
//     // });
//
//
// });



$(document).ready(function(){

    var currentPage = window.location.href.split("/").at(-2)

    if (currentPage == 'unit_versions') {
        console.log("Saving method tabs state loaded")

        var elements = [$('[data-toggle="method-tab"]'), $('[data-toggle="improvements-tab"]'),
            $('[data-toggle="usage-examples-tab"]'), $('[data-toggle="settings-tab"]'),];

        var combinedObj = $.map(elements, function(el){return el.get()});
        $(combinedObj).on('click', function(ev){
            console.log(`id: ${$(ev.target).attr('id')} saved to localstorage `)
            localStorage.setItem('activeMethodTabId', $(ev.target).attr('id'));
        });

        var activeTabId = localStorage.getItem('activeMethodTabId');
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