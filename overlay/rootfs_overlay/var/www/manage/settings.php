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
                        <h1>System settings</h1>
                        <h3>Timezone</h3>
                        <form  method="post">
                        <?php
                        
                        if ( isset($_POST['saveSettings']) ) {
                            if ($_POST['external_drive'] != "y") 
                            {
                                $external_drive="n";
                            }
                            else
                            {
                                $external_drive="y";
                            }
                            $set_list = $_POST['timezone']." ".$external_drive;
                            $set_list = $set_list." ".$_POST['passwd']." ".$_POST['passwd_confirm'];
                            $set_list = str_replace(array("\n","\r"),'', $set_list);
                            $save_timezone = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_save_settings '$set_list'");
                            }
                        ini_set('display_errors',1);
                        error_reporting(E_ALL);
                        ?>
                        <div> 
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
                        </div>
                        <?php
                        if ( isset($save_timezone)) {
                            echo "<pre>$save_timezone</pre>";
                        }
                        ?>
                        <div>
                        <hr>
                        <h3>Use external drive(USB)</h3>
                        <?php
                        $extenal_used = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting external");
                        $extenal_used = str_replace(array("\n","\r"),'', $extenal_used);
                        if (strcmp($extenal_used,'y') == 0){
                            $extenal_used = "checked=y";
                            $external_exist = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_check_external");
                            echo "<pre>$external_exist</pre>";
                        }else{
                            $extenal_used = "";
                        }
                        
                        echo "<input type=\"checkbox\" name=\"external_drive\" value=\"y\" $extenal_used/>Use external drive";
                        ?>
                        </div>
                        <div>
                        <hr>
                        <p>Пароль администратора</p>
                        <input type="password" maxlength='15' size='15' value="" name=passwd></p>
                        <p>Подтверждение пароля</p>
                        <input type="password" maxlength='15' size='15' value="" name=passwd_confirm></p>
                        </div>
                        <div>
                            <!-- <h2>Save settings</h2> -->
                            <hr color=red>
                            <input name="saveSettings" type="submit" value="Сохранить" />
                        </div>
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