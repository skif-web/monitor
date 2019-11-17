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
                        <h1>Backup/Restore/Factory reset</h1>
                        <form  method="post" enctype="multipart/form-data">
                        <?php
                        if ( isset($_POST['backup_settings']) ) {
                            $status = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_backup_settings");
                            echo "<pre>$status</pre>";
                            $file='/var/www/manage/uploads/backup.tar.gz';
                            if (file_exists($file)) {
                                ob_clean();
                                header('Content-Description: File Transfer');
                                header("Content-Type: application/octet-stream");
                                header('Content-Disposition: attachment; filename="'.basename($file).'"');
                                header('Expires: 0');
                                header('Cache-Control: must-revalidate');
                                header('Pragma: public');
                                header('Content-Length: ' . filesize($file));
                                header("Content-Type: application/force-download");
                                header("Content-Transfer-Encoding: binary");
                                readfile($file);
                            }
                        }
                        // ini_set('display_errors',1);
                        // error_reporting(E_ALL);
                        if ( isset($_POST['backup_dump']) ) {
                            $status = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_backup_dump");
                            echo "<pre>$status</pre>";
                            $file='/var/www/manage/uploads/last.sql';
                            if(file_exists($file)) {
                                ob_clean();
                                header('Content-Description: File Transfer');
                                header("Content-Type: application/octet-stream");
                                header('Content-Disposition: attachment; filename="'.basename($file).'"');
                                header('Expires: 0');
                                header('Cache-Control: must-revalidate');
                                header('Pragma: public');
                                header('Content-Length: ' . filesize($file));
                                header("Content-Type: application/force-download");
                                header("Content-Transfer-Encoding: binary");
                                readfile($file);
                            }
                        }

                        if ( isset($_POST['factory_reset']) ) {
                            $status = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_factory_reset");
                            echo "<pre>$status</pre>";
                        }
                        
                        if(isset($_POST["upload_conf"])) {
                            shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_clean_upload");
                            $target_file = "uploads/backup.tar.gz";

                            if (move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) {
                                echo "The file ". basename( $_FILES["fileToUpload"]["name"]). " has been uploaded.";
                            } else {
                                echo "Sorry, there was an error uploading your file.";
                            }
                            
                            $status = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_upload_config");
                            echo "<pre>$status</pre>";
                            shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_clean_upload");

                        }

                        if(isset($_POST["upload_dump"])) {
                            shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_clean_upload");
                            $target_file = "uploads/last.sql";
                            if (move_uploaded_file($_FILES["fileToUpload2"]["tmp_name"], $target_file)) {
                                echo "The file ". basename( $_FILES["fileToUpload"]["name"]). " has been uploaded.";
                            } else {
                                echo "Sorry, there was an error uploading your file.";
                            }
                            $status = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_upload_dump");
                            echo "<pre>$status</pre>";
                            // shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_clean_upload");
                        }
                        
                        ?>

                        <h3>Save config</h3>
                        <input name="backup_settings" type="submit" value="backup settings" />
                        <hr>
                        <h3>Save zabbix dump</h3>
                        <input name="backup_dump" type="submit" value="backup dump" />
                        <hr>
                        <h3>Factory reset</h3>
                        <input name="factory_reset" type="submit" value="factory reset" />
                        <hr>
                        <h3>Upload config</h3>
                        <input type="file" name="fileToUpload" id="fileToUpload">
                        <hr>
                        <input type="submit" value="Upload config" name="upload settings backup">
                        <hr>
                        <h3>Upload zabbix dump</h3>
                        <input type="file" name="fileToUpload2" id="fileToUpload2">
                        <hr>
                        <input type="submit" value="Upload dump" name="upload dump">
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