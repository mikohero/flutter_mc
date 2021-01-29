<?php 
include "config1.php";
// REGISTER USER
/*
[{"file":"2021_0126_122821_005.JPG","lat":"55.4574008","lng":"10.3708703"},{"file":"2021_0126_122841_006.JPG","lat":"55.457392","lng":"10.3709021"}]

*/
  
    $content = $_POST['content'];
    $json = json_decode($content,false);
    //insert data into rejse. null, null is autoincrement+rejse name
    $query1="INSERT INTO rejse VALUES ('', NULL)";
    $results1 = mysqli_query($connect, $query1);
    $id=mysqli_insert_id($connect);

    //now insert all the marks. imageurl,lat,lng
    //INSERT INTO marks VALUES ('','sdsdsdsds','10.111111','54.1121212',1)   
    foreach($json as $obj){
        $file=$obj->file;
        $lat=$obj->lat;
        $lng=$obj->lng;
        $query = "INSERT INTO marks VALUES ('','".$file."','".$lat."','".$lng."',".$id.")";
        $results = mysqli_query($connect, $query);
    }
 
        
    if($results>0)
    {
        echo "content inserted";
    }
    
    


    
    
    ?>