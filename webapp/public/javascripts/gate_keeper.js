function setBackgroundSize() {
    return $(window).width() + "px " + ($(window).height() + 80) + "px";
}

function isPetGateVisible() {
    let timeout;
    $('.pet_gate:visible').on('inview', function(event, isInView) {
        if (isInView) {
            clearTimeout(timeout);
            timeout = setTimeout(function() {
                if ($('.loader').css('display') == 'none') {
                    return null;
                } else {
                    ajaxGetPets(setShelterName(), countPets());
                }
            }, 90);
        }
    });

}

function setShelterName() {
    if ($('.shelter:visible').attr('id') === undefined) {
        return shelterName = "";
    } else {
        return shelterName = $('.shelter:visible').attr('id').replace(/_/g, " ");
    }
}

function countPets() {
    return $('.pet_pen:visible').children().length;
}

function ajaxGetPets(shelterName, petCount) {
    $.ajax({
        url: window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/getPets",
        type: 'get',
        headers: { "screenSize": $(window).width(), "shelter": shelterName, "count": petCount },
        success: function(data) {
            if (data.includes("No more pets to be seen!")) {
                $('.loader').css('display', 'none');

                if (shelterName === "") {
                    $('.pet_pen').parent().append("<div class='endContent'> No more pets!</div>");
                } else {
                    let shelter_name = "#" + shelterName.replace(/ /g, "_");
                    $(shelter_name).append("<div class='endContent'> No more pets!</div>");
                }
            } else {
                let array = $.parseHTML(data);
                shuffleArray(array);

                if (shelterName === "") {
                    $('.pet_pen').append(array);
                } else {
                    let shelter_name = "#" + shelterName.replace(/ /g, "_");
                    let shelter_child = "#" + $(shelter_name).children('div').attr('id');
                    $(shelter_child).append(array);
                }
            }
        },
        error: function(xhr, ajaxOptions, thrownError) {
            let errorMsg = 'Ajax request failed: ' + xhr.responseText;
            $('section').append(errorMsg);
        }
    });
}

function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
        let j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
    }
}

function openPage(shelter_name, elmnt, color) {
    var i, tabcontent, tablinks;
    tabcontent = $('.tabcontent');
    tablinks = $('.tablink');
    for (i = 0; i < tabcontent.length; i++) {
        tabcontent[i].style.display = "none";
    }
    for (i = 0; i < tablinks.length; i++) {
        tablinks[i].style.backgroundColor = "";
    }
    document.getElementById(shelter_name).style.display = "block";
    elmnt.style.backgroundColor = color;
    $('.loader').css('display', 'flex');
}

$(document).ready(function() {
    $('#fixthis').fixit({ zIndex: 99, addClassAfter: "fixed" });
    if (window.location.pathname === "/") {
        if (/Mobi/.test(navigator.userAgent) || /Android/i.test(navigator.userAgent)) {
            if ($(window).resize()) {
                let backgroundSize = setBackgroundSize();
                $('body').css('background-size', backgroundSize);
            }
            isPetGateVisible();

        } else {
            isPetGateVisible();

        }
    } else if (window.location.pathname === "/shelters") {
        $(".loader").css('color', 'white');
        if (/Mobi/.test(navigator.userAgent) || /Andriod/i.test(navigator.userAgent)) {
            document.getElementById('defaultOpen').click();
            if ($(window).resize()) {
                let backgroundSize = setBackgroundSize();
                $('body').css('background-size', backgroundSize);
            }
            $('.tablink').click(function() {
                isPetGateVisible();
            });
            isPetGateVisible();
        } else {
            document.getElementById('defaultOpen').click();
            $('.tablink').click(function() {
                isPetGateVisible();
            });
            isPetGateVisible();
        }
    }
});