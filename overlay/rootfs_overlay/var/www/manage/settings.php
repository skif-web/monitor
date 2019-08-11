<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Benbix Admin panel</title>

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
                        <h1>Bender-zabbix linux settings</h1>
                        <h2>Select timezone</h2>
                        <form  method="post">
                        <?php
                        if ( isset($_POST['saveTimezone']) ) {
                            $save_timezone = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_save_setting {$_POST['timezone']}");
                            }
                        ?>
                        <select name="timezone">
                        <?php
                        $lines = file('/var/www/manage/timezone.list');
                        $output = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting timezone");
                        echo '<option selected="selected" value="'.$output.'">'.$output.'</option>';
                        foreach ($lines as $linesArray) {
                            echo '<option value="'.$linesArray.'">'.$linesArray.'</option>';
                        }
                        ?>
                        </select>
                        <?php
                        if ( isset($save_timezone)) {
                            echo "<pre>$save_timezone</pre>";
                        }
                        ?>
                        <input name="saveTimezone" type="submit" value="Сохранить" />
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