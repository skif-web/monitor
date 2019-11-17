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
<script type="text/javascript">

function showMe (box) {
var vis = (box.checked) ? "none" : "block";
document.getElementById('div1').style.display = vis;
}
</script>

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
                        <h1>Network settings</h1>
                        <form  method="post" enctype="multipart/form-data">
                        <?php
                        if ( isset($_POST['save_net']) ) {
                            $set_list = 'hostname='.$_POST['hostname'];
                            $set_list = $set_list.' network='.$_POST['dhcp'];
                            $set_list = $set_list.' ip='.$_POST['ip'];
                            $set_list = $set_list.' netmask='.$_POST['netmask'];
                            $set_list = $set_list.' gateway='.$_POST['gateway'];
                            $set_list = $set_list.' dns1='.$_POST['dns1'];
                            $set_list = $set_list.' dns2='.$_POST['dns2'];
                            $status = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_save_network '$set_list'");
                            echo "<pre>$status</pre>";
                        }
                        

                        $dhcp_used = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting network");
                        $dhcp_used = str_replace(array("\n","\r"),'', $dhcp_used);
                        if ($dhcp_used == "dhcp"){
                            $dhcp=checked;
                        }else{
                            $static=checked;
                        }
                        $ip = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting ip");
                        $netmask = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting netmask");
                        $gateway = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting gateway");
                        $dns1 = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting dns1");
                        $dns2 = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting dns2");
                        
                        $hostname = shell_exec("sudo -u root /usr/bin/libWebInterface.sh f_get_setting hostname");

                        echo"<p>Hostname";
                        echo "<p><input value=\"$hostname\" name=hostname></p>";

                        echo "<p><input type=\"radio\" $dhcp_used name=\"dhcp\" value=\"dhcp\" onclick=\"showMe(this)\" $dhcp/>DHCP";
                        echo "<p><input type=\"radio\" $dhcp_used name=\"dhcp\" value=\"static\" onclick=\"showMe(this)\" $static/>Static";

                        ?>
                        <div>
                        <?php
                        echo"<p>IP address";
                        echo "<p><input maxlength='15' size='15' value=\"$ip\" name=ip></p>";
                        echo "<p>Netmask(in CIDR)";
                        echo "<p><input maxlength='2' size='2' value=\"$netmask\" name=netmask></p>";
                        echo "<p>Gateway";
                        echo "<p><input maxlength='15' size='15' value=\"$gateway\" name=gateway></p>";
                        echo "<p>DNS 1";
                        echo "<p><input maxlength='15' size='15' value=\"$dns1\" name=dns1></p>";
                        echo "<p>DNS 2";
                        echo "<p><input maxlength='15' size='15' value=\"$dns2\" name=dns2></p>";
                        ?>
                        </div>
                        <input name="save_net" type="submit" value="Save" />
                        
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