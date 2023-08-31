<%@include file="/WEB-INF/jsp/libs.jsp" %>
<link rel="stylesheet" href="/css/docScan.css" />

<!-- header -->
<div class="ui fixed inverted menu">
    <div class="ui container header-flex">
      <a href="#" class="header item">
        Doc Scan
      </a>
      <a href="#" class="item">Home</a>
    </div>
</div>

<div class="main-container">
<div class="row">
    <!--input images -->
	<div class="col-sm-6">
	    <form class="ui segment" id="myForm" method="POST" enctype="multipart/form-data">
	        <div class="file-upload">
            <button class="file-upload-btn" type="button" onclick="$('.file-upload-input').trigger( 'click' )">Add Image</button>

            <div class="image-upload-wrap">
            <input class="file-upload-input" type='file' onchange="readURL(this);" accept="image/*" id="imageFile" name="image"/>
            <div class="drag-text">
                <h3>Drag and drop a file or select add Image</h3>
            </div>
            </div>
         <div class="file-upload-content">
           <img class="file-upload-image" src="" alt="your image" />
           <div class="image-title-wrap">
             <button type="button" onclick="removeUpload()" class="remove-image">Remove <span class="image-title">Uploaded Image</span></button>
           </div>
         </div>
       </div>

        <div class="row threshold">
            <div class="col-sm-6">
                <label><strong>Threshold1</strong><input type="number" id="threshold1" name="threshold1" value="44"></label>
            </div>
            <div class="col-sm-6">
                <label><strong>Threshold2</strong><input type="number" id="threshold2" name="threshold2" value="111"></label>
            </div>
        </div>

        <div class="row threshold">
            <input id="btnSubmit" class="ui primary button" type="submit" value="Submit">
        </div>
       </form:form>


	</div>
	<!--output images -->
	<div class="col-sm-6">
	    <div class="ui segment">
	        <h3 class="ui header">Output</h3>
	        <div id="outputImages" class="output-area">
	            <div class="before-output">
	            <svg xmlns="http://www.w3.org/2000/svg" width="100%" height="100%" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" class="feather feather-image"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><circle cx="8.5" cy="8.5" r="1.5"></circle><polyline points="21 15 16 10 5 21"></polyline></svg>
                </div>
	        </div>
	    </div>
	</div>
</div>

<!--other output images -->
<div class="row ui segment">
    <h3 class="ui header">Image after each steps.</h3>
    <div id="stepsImages" class="steps-images">
        <img id="greyScale" class="output-image-thumbnail" src="" width="300" height="200" src="">
        <img id="imageThreshold" class="output-image-thumbnail" width="300" height="200" src="">
        <img id="contours" class="output-image-thumbnail" width="300" height="200" src="">
        <img id="biggestContour" class="output-image-thumbnail" width="300" height="200" src="">
    </div>
</div>

</div>

<script>
var notifier = new AWN();
function getPath(){
    var context = '${pageContext.request.contextPath}';
    return context;
}
function preview(){
    frame.src=URL.createObjectURL(event.target.files[0]);
    $('#frame').show();
}
$(document).ready(function () {
    $("#btnSubmit").click(function (event) {
        //stop submit the form, we will post it manually.
        event.preventDefault();

        var form = $('#myForm').get(0);
        var formData = new FormData(form);

        //disabled the submit button
        $("#btnSubmit").prop("disabled", true);
        $.ajax({
            url : getPath()+"/doc-tool/scan",
            type: "POST",
            enctype: 'multipart/form-data',
            processData: false,
            contentType: false,
            cache: false,
            data : formData,
            async : false,
            timeout:6000,
            success : function(responseData) {
                $('#outputImages').html("");
                var image = new Image();
				image.src = "data:image/png;base64," + responseData.finalImage;
				image.id = "outputImage";
				$('#outputImages').html(image);
                $("#btnSubmit").prop("disabled", false);
                $("#outputImage").addClass("output-image-thumbnail")
                //other steps images
                $('#greyScale').attr('src', "data:image/png;base64," + responseData.greyScale);
                $('#imageThreshold').attr('src', "data:image/png;base64," + responseData.imageThreshold);
                $('#contours').attr('src', "data:image/png;base64," + responseData.contours);
                $('#biggestContour').attr('src', "data:image/png;base64," + responseData.biggestContour);
                $('#stepsImages').show();
            },
            error: function(errorObj) {
                $("#btnSubmit").prop("disabled", false);
                var errMsg = errorObj.responseJSON.error;
                if(errMsg === undefined){
                    errMsg = "Internal server error.";
                }
                notifier.alert(errMsg);
            }
        });
    });
});

function readURL(input) {
  if (input.files && input.files[0]) {

    var reader = new FileReader();

    reader.onload = function(e) {
      $('.image-upload-wrap').hide();

      $('.file-upload-image').attr('src', e.target.result);
      $('.file-upload-content').show();

      $('.image-title').html(input.files[0].name);
    };

    reader.readAsDataURL(input.files[0]);

  } else {
    removeUpload();
  }
}

function removeUpload() {
  $('.file-upload-input').replaceWith($('.file-upload-input').clone());
  $('.file-upload-content').hide();
  $('.image-upload-wrap').show();
  var inputImg = $("#imageFile");
  var fileName = inputImg.val();
  if(fileName){
    inputImg.val('');
  }
}
$('.image-upload-wrap').bind('dragover', function () {
    $('.image-upload-wrap').addClass('image-dropping');
  });
  $('.image-upload-wrap').bind('dragleave', function () {
    $('.image-upload-wrap').removeClass('image-dropping');
});


</script>