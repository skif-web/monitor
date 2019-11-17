<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Admin panel</title>

    <!-- Bootstrap Core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="css/simple-sidebar.css" rel="stylesheet">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->

</head>

<body>

    <div id="wrapper">

        <!-- Sidebar -->
        <div id="sidebar-wrapper">
            <?php include("sidebar.html"); ?>
        </div>
        <!-- /#sidebar-wrapper -->

        <!-- Page Content -->
        <div id="page-content-wrapper">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-lg-12">
                        <h1>Firmware update</h1>
                        <form  method="post" enctype="multipart/form-data">
                        <?php

                        if(isset($_POST["upload_firmware"])) {
                            shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_clean_upload");
                            $target_file = "uploads/firmware";

                            if (move_uploaded_file($_FILES["firmware"]["tmp_name"], $target_file)) {
                                echo "The file ". basename( $_FILES["firmware"]["name"]). " has been uploaded.";
                            } else {
                                echo "Sorry, there was an error uploading your file.";
                            }
                            
                            $status = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_update");
                            echo "<pre>$status</pre>";
                        }
                        ?>
                        <hr>

                        <input type="file" name="firmware" id="firmware">
                        <hr>
                        <input type="submit" value="Upload firmware" name="upload_firmware">
                        </form>


                    </div>
                </div>
            </div>
        </div>
        <!-- /#page-content-wrapper -->

    </div>
    <!-- /#wrapper -->

    <!-- jQuery -->
    <script src="js/jquery.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="js/bootstrap.min.js"></script>

    <!-- Menu Toggle Script -->
    <script>
    $("#menu-toggle").click(function(e) {
        e.preventDefault();
        $("#wrapper").toggleClass("toggled");
    });
    </script>



</body>

</html>


<?php

?>