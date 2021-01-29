<?php
//$picture = $_POST['picture'];
//https://www.php.net/manual/en/features.file-upload.post-method.php
//include "config1.php";

$message='';
if (is_uploaded_file($_FILES['picture']['tmp_name'])) {
	$uploads_dir = '../../images/'; //only this was working for root-drive
	
    $tmp_name = $_FILES['picture']['tmp_name'];
    $pic_name = $_FILES['picture']['name'];

    

    $test=move_uploaded_file($tmp_name, $uploads_dir.$pic_name);
    $message=mysqli_real_escape_string($connect, $uploads_dir.$pic_name." ".$test);
}
else{

           $message= "File not uploaded successfully.";
   }
   
echo $message;
?>