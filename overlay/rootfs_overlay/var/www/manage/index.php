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
                        <h1>Bender-zabbix linux dashboard</h1>
                        <h2>Uptime</h2>
                        <?php
                            $output = shell_exec('libWebInterface.sh f_get_uptime');
                            echo "<pre>$output</pre>";
                        ?> 

                        <h2>CPU load</h2>
                        <?php
                            $output = shell_exec('libWebInterface.sh f_get_cpu_load');
                            echo "<pre>$output</pre>";
                        ?> 
                        <h2>Memory load</h2>
                        <?php
                            $output = shell_exec('libWebInterface.sh f_get_memory_load');
                            echo "<pre>$output</pre>";
                        ?>
                        <h2>Network settings</h2>
                        <?php
                            $output = shell_exec('libWebInterface.sh f_get_ip');
                            echo "<pre>$output</pre>";
                        ?>                       

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