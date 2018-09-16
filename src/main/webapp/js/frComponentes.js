//////////////////
/// Jquery
//////////////////
$('.area').change(function () {
    $.get("buscaAmostrasDaArea?idArea=" + this.value, function (data) {
        if (data.length > 0) {
            var appenddata = '<option>Selecione uma amostra</option>';
            $.each(data, function (key, value) {
                appenddata += "<option value=\"" + value.codigo + "\">" + value.descricao + " </option>";
            });
            $('#amostra').html(appenddata);
        } else {
            $('#amostra').html(null);
        }
    })
});

$('#formGeo').submit(function () {
    $('#msgError').hide();
    $('#spinner').show();
    $('html, body').animate({scrollTop:0}, 'slow');
});
 
$('#formKrig').submit(function () {  
    $('#msgError').hide();
    $('#spinner').show();
    $('html, body').animate({scrollTop:0}, 'slow');
});


$('#formIdw').submit(function () {  
    $('#msgError').hide();
    $('#spinner').show();
    $('html, body').animate({scrollTop:0}, 'slow');
});


