//sets parallax background images
$('#cat').parallax({ imageSrc: '/images/cat.jpg' });
$('#ruby').parallax({ imageSrc: '/images/gears.jpeg' });
$('#java').parallax({ imageSrc: '/images/aromatic-bean.jpg' });

$(document).ready(function() {
    //if mobile device, remove parallax effect
    if (/Mobi/.test(navigator.userAgent) || /Andriod/i.test(navigator.userAgent) || $(window).width() < 400) {
        $('#non-mobile')[0].disabled = true;

        //remove DOM elements that break on mobile, change placement of other elements
        $('.parallax-mirror').remove();
        $('#cat').css('background-image', '');
        $('#ruby').css('background-image', '');
        $('#java').css('background-image', '');
        $('<div class="highlights"></div>').insertBefore('#cat');
        $('.highlights').append($('.rubyList'));
        $('.highlights').append($('.javaList'));
        $('<p>Web Services</p>').appendTo('span.services');
        $('<p>Pet Aggregation</p>').appendTo('span.aggregate');
    } else {
        //fix white space between parallax images
        $('.parallax-window').parallax({
            bleed: 40
        });
        $('#mobile')[0].disabled = true;
        $('body').css('background', 'none');
    }
});