$(document).ready(function(){
    $('.scroll-to-top-substep-button').click(function(){
        console.log("scroll-to-top-substep-button activated")
        $('html, body').animate({
            scrollTop: $( $(this).attr('href') ).offset().top
        }, 500);
        return false;
    });
})

