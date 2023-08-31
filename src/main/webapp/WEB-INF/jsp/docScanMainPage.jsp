<%@include file="/WEB-INF/jsp/libs.jsp" %>

<style>
.threshold {
  background-color: #ffffff;
  margin: 0 auto;
  padding: 5px;
}
.file-upload {
  background-color: #ffffff;
  margin: 0 auto;
  padding: 5px;
}

.file-upload-btn {
  width: 100%;
  margin: 0;
  color: #fff;
  background: #1FB264;
  border: none;
  padding: 10px;
  border-radius: 4px;
  border-bottom: 4px solid #15824B;
  transition: all .2s ease;
  outline: none;
  text-transform: uppercase;
  font-weight: 700;
}

.file-upload-btn:hover {
  background: #1AA059;
  color: #ffffff;
  transition: all .2s ease;
  cursor: pointer;
}

.file-upload-btn:active {
  border: 0;
  transition: all .2s ease;
}

.file-upload-content {
  display: none;
  text-align: center;
}

.file-upload-input {
  position: absolute;
  margin: 0;
  padding: 0;
  width: 100%;
  height: 100%;
  outline: none;
  opacity: 0;
  cursor: pointer;
}

.image-upload-wrap {
  margin-top: 20px;
  border: 4px dashed #1FB264;
  position: relative;
}

.image-dropping,
.image-upload-wrap:hover {
  background-color: #1FB264;
  border: 4px dashed #ffffff;
}

.image-title-wrap {
  padding: 0 15px 15px 15px;
  color: #222;
}

.drag-text {
  text-align: center;
}

.drag-text h3 {
  font-weight: 100;
  text-transform: uppercase;
  color: #15824B;
  padding: 60px 0;
}

.file-upload-image {
  max-height: 200px;
  max-width: 200px;
  margin: auto;
  padding: 20px;
}

.remove-image {
  width: 200px;
  margin: 0;
  color: #fff;
  background: #cd4535;
  border: none;
  padding: 10px;
  border-radius: 4px;
  border-bottom: 4px solid #b02818;
  transition: all .2s ease;
  outline: none;
  text-transform: uppercase;
  font-weight: 700;
}

.remove-image:hover {
  background: #c13b2a;
  color: #ffffff;
  transition: all .2s ease;
  cursor: pointer;
}

.remove-image:active {
  border: 0;
  transition: all .2s ease;
}

.output-area{
   height: 380px;
   width: 600px;
   padding: 5px;
   position: relative;
   display: flex;
   align-items:center;
   justify-content: center;
}

.output-image-thumbnail{
  object-fit: contain;
  max-width: 99%;
  max-height: 99%;
  z-index:999;
  cursor: pointer;
  -webkit-transition-property: all;
  -webkit-transition-duration: 0.3s;
  -webkit-transition-timing-function: ease;
}
.output-image-thumbnail:hover {
    transform: scale(2)
}

.steps-images{
    display: none;
}
.before-output{
    display: flex;
    justify-content: center;
    align-items: center;
    opacity: 0.5;
    height: 5rem;
}
.main-container{
    margin-top:5%;
    padding:0.5%;
}
.header-flex{
    flex: auto;
}
</style>
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