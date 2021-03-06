$(document).ready(function() {
  $('#address_address_id').change(function()
	{
		if ($('#address_address_id').val() == ""){
			showNewAddressFields();
		}
		else{
			showExistingAddress($('#address_address_id').val());
		}
  });
	$('#address_address_id').change();
});

function showNewAddressFields(){
	$('.go_to_third_step').hide();
	$('#address_address_id').val('');
	$('.show_address').hide(1000);
	$('.new_address').show(1000);
}

function showExistingAddress(id){
  $.ajax({
    dataType: "json",
    url: '../address/get_address.json?id='+id,
    async: false,
    success: function(data) {
    	fillAddress(data);
    }
  });

	$('.go_to_third_step').show();
	$('.new_address').hide(1000);
	$('.show_address').show(1000);
}

function fillAddress(data){
	var address_info = data.address + ', ' + data.number + ' ' + data.complement;
	var region_info = data.district + ', ' + data.city + ' - ' + data.state;
	var zipcode_info = 'CEP: ' + data.zip_code;

	$('#identifier_info').html(data.identifier);
	$('#address_info').html(address_info);
	$('#region_info').html(region_info);
	$('#zipcode_info').html(zipcode_info);
}

function getChosenAddress(){
	$.ajax({
    dataType: "json",
    url: '../address/get_chosen_address_id.json?',
    async: false,
    success: function(data) {
    	showExistingAddress(data);
    }
  });
}

$.validator.messages.required = '';
$("#address_form").validate({
                rules: {
                    address_identifier: "required",
                    address_zip_code: "required",
                    address_address: "required",
                    address_number: "required",
                    address_district: "required",
                    address_city: "required",
                    address_state: "required"
                }
            });

function recalculateShipmentCosts(source) {
  var input =  $(source).closest("form").find("input.cep_to_estimate_shipping_costs")[0];
  if(input == undefined) {
    alert("Erro interno. Por favor, informe esse erro para o nosso departament sistema.")
    return;
  }

  var cep = input.value;

  if(cep == "") {
    alert("Insira um CEP para recalcular os custos de envio");
    $(".shipping-error").remove();
    return;
  }

  $.ajax({
    url: "shipment_cost/" + cep + ".js",
    success: function(data) {
      //TODO: add support to fill automatically the address and city fields using correios-cep gem.
      if($(".shipping-error").length == 0) {
        $("input[name='address[zip_code]'").val(cep);
      } else
      {
        $("input[name='address[zip_code]'").val("");
      }
    },
  });
}
