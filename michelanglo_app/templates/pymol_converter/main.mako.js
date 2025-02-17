/*
<%namespace file="labels.mako" name="info"/>
<%doc>
 This file is a mako template to make JS. The extension is backwards to avoid tinkering with the default PyCharm editor.
 This file contains the main page's script.
</%doc>
*/

//housekeeping
$('[data-toggle="tooltip"]').tooltip();


//////////////////////////////////////////////////////////////////////////
//control the resolt of ticking the pdb data in the code checkbutton
$('#pdb_string').change(function () {
    if ($('#pdb_string').is(':checked')) {
        $('#pdb').attr('disabled',true);
        $('#pdb').val('N/A');
        $('#pdb').removeClass('is-invalid');
        $('#error_pdb').hide();
    } else {
        $('#pdb').removeAttr('disabled');
        $('#pdb').val('');
        $('#pdb').addClass('is-invalid');
        $('#error_pdb').show();
    }
});

//////////////////////////////////////////////////////////////////////////
// upload button for PSE and PDB
$('#upload,#upload_id').change(function () {
    window.demo_pse = '';
    var id=$(this).attr('id');
    var extension = id == 'upload' ? '.pse' : '.pdb';
    var file=$(this).val().split('\\').slice(-1)[0];
    if (!! $(this).val()) { //valid upload
        if ($(this).val().toLowerCase().search(extension) != -1) {
        $(this).addClass('is-valid');
        $(this).removeClass('is-invalid');
        $('#error_'+id).hide();
        if (extension == '.pse') {
            if (! $('#pdb').val()) {$('#pdb').val(file.replace('.pse','.pdb'))}
        }
        else {
            //unique actions for pdb
        }
    }
    else { //invalid upload
        $(id).removeClass('is-valid');
        $(id).addClass('is-invalid');
        $('#error_'+id).show();
    }
    $('#'+id+'+.custom-file-label').html(file);
    } // else? nothing added. user chickened out.
});

//control modal demo buttons for pse model
var demo_pse='';
$('.demo-pse').click(function () {
    window.demo_pse=$(this).data('value');
    $('#upload+.custom-file-label').html('DEMO: '+demo_pse);
    $('#demo_modal').modal('hide');
    $('#pdb_string').prop('checked',true);
    $('#pdb_string').trigger('change');
});
//////////////////////////////////////////////////////////////////////////
// demo button for output mode
$('#demo').click(function () {
    $("#input_mode_out").prop("checked", false);
    $.get("static/pymol_demo.txt", function (text) {
        $('#pymol_output').val(text);
    });
});


//////////////////////////////////////////////////////////////////////////
// reset
$('#clear').click(function () {
    $('#results').remove();
    $('#pymol_output').val('');
    $('#pdb').val('');
    $('.is-invalid').removeClass('is-invalid');
    $('.is-valid').removeClass('is-valid');
    $('.invalid-feedback').hide();
    $('#submit').removeAttr('disabled').children('.far').detach();
    ops.halt();
    if (ops.main_ajax) {ops.main_ajax.abort(); ops.addToast('userkiller','User killed job','The user killed the job.','bg-warning')}
});

// validation.
function valid_value(id){
    if (! $(id).val()) {
        window.setTimeout(function () {
            $(id).addClass('is-invalid');
            $(id)[0].scrollIntoView();
            $('#error_' + id.replace('#','')).show();
            ops.halt()
            },0);
        throw 'Incomplete '+id;
    }
    else if (!! $(id)[0].files) {return $(id)[0].files[0]}
    else {return $(id).val();}
}

// submit for calculation
$('#submit').click(function () {
    //get ready by cleaning up
    $('#results').remove();
    stage=false;
    $('.is-invalid').removeClass('is-invalid');
    $('.is-valid').removeClass('is-valid');
    $('.invalid-feedback').hide();

    data = new FormData();
    // determine mode
    var mode='file'; //no longer need
    // deal with the include PDB data which means that the it is not a publicly available PDB.
    // 'string as in store the coordinates as a string in js
    if ($('#pdb_string').is(':checked')) {data.append( 'pdb', false);} else {data.append( 'pdb', valid_value('#pdb'));}
    data.append( 'mode', mode );
    // output mode... no longer active.
    if        (mode == 'out') {
        data.append('pymol_output', valid_value('#pymol_output'));
        ops.addToast('submitting','Submitting','Request is being sent.','bg-info');
    }
    // demo pse mode
    else if (mode == 'file' && !! window.demo_pse) {
        data.append('demo_filename',window.demo_pse);
        ops.addToast('submitting','Submitting','Request is being sent.','bg-info');
    }
    // pse upload mode
    else if (mode == 'file') {
        data.append( 'file', valid_value('#upload'));
        if ($('#upload')[0].files[0].size > 5e7) {
                ops.addToast('startingjob',
                    'Excessive size',
                    'This file is larger than 50 MB. If you are not attempting a DoS attack, please email Matteo Ferla to process your file.','bg-danger');
                throw 'DoS attack blocked?';
            } else {ops.addToast('uploading','Uploading','Uploading file in progress.','bg-info');}
    }
    // error.
    else {throw 'Impossible mode';}
    //finish adding data.
    data.append( 'uniform_non_carbon',$('#uniform_non_carbon').is(':checked'));
    data.append( 'combine_objects',$('#combine_objects').is(':checked'));
    data.append('stick_format', $("input[name='sticks']:checked").val());
    // ajax to convert_pse
    //{pdb: pdb, uniform_non_carbon: uniform_non_carbon, pymol_output: pymol_output, indent: indent, cdn: cdn}
    $('#submit .far').detach();
    $('#submit').attr('disabled','disabled').prepend('<i class="far fa-circle-notch fa-spin"></i> ');
    ops.main_ajax = $.ajax({
        type: "POST",
        url: "convert_pse",
        processData: false,
        enctype: "multipart/form-data",
        cache: false,
        contentType: false,
        data:  data
    })
            .done(function (msg) {
                ops.addToast('jobcompletion','Conversion complete','The data has been converted successfully.','bg-success');
                window.location.href = "/data/"+msg.page;
                $('#submit').removeAttr('disabled').children('.far').detach();
            })
            .fail(function (xhr) {
                ops.addErrorToast(xhr);
                $('#submit').removeAttr('disabled').children('.far').detach();
            });
    setTimeout(() => ops.statusCheck(), 2000);
});

//why is it stored!?
if (! $('#pdb_string').is(':checked')) $('#pdb_string').click();
$('#pdb').attr('disabled', "disabled");
