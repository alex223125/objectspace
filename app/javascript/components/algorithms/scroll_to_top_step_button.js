$(document).ready(function(){
    $('.scroll-to-top-step-button').click(function(){
        console.log("scroll-to-top-step-button activated")
        $('html, body').animate({
            scrollTop: $( $(this).attr('href') ).offset().top
        }, 500);
        return false;
    });
})


