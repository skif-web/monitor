<?php if(!defined('IN_GS')){ die('you cannot load this page directly.'); }
/****************************************************
*
* @File: 		template.php
* @Package:		GetSimple
* @Action:		GSkeleton2 v1.1 Boilerplate Theme for GetSimple CMS
*
*****************************************************/
?>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title><?php get_page_clean_title(); ?> &mdash; <?php get_site_name(); ?></title>

    <!-- Bootstrap Core CSS -->
    <link href="<?php get_theme_url(); ?>/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="<?php get_theme_url(); ?>/css/simple-sidebar.css" rel="stylesheet">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<?php get_header(); ?>
</head>

<body id="<?php get_page_slug(); ?>" >
    <div id="wrapper">

        <!-- Sidebar -->
        <div id="sidebar-wrapper">
            <ul class="sidebar-nav">
                <li class="sidebar-brand">
                    <a href="<?php get_site_url(); ?>">
                      <?php get_site_name(); ?>
                    </a>
                </li>
            <?php get_navigation(return_page_slug()); ?>
            </ul>
        </div>
        <!-- /#sidebar-wrapper -->

        <!-- Page Content -->
        <div id="page-content-wrapper">
            <div class="container-fluid">
                <div class="row">
                    <div class="col-lg-12">
                        <h1><?php get_page_title(); ?></h1>
                        <?php get_page_content(); ?>
						<footer>
			<div class ="six columns" >
				<?php get_site_name(); ?> &copy; <?php echo date('Y'); ?> <?php get_site_credits(); ?>
			</div>
			<?php get_footer(); ?>
		</footer>
                        <a href="#menu-toggle" class="btn btn-primary" id="menu-toggle">Toggle Menu</a>
                    </div>
                </div>
            </div>
        </div>
        <!-- /#page-content-wrapper -->

    </div>
    <!-- /#wrapper -->

    <!-- jQuery -->
    <script src="<?php get_theme_url(); ?>/js/jquery.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="<?php get_theme_url(); ?>/js/bootstrap.min.js"></script>

    <!-- Menu Toggle Script -->
    <script>
    $("#menu-toggle").click(function(e) {
        e.preventDefault();
        $("#wrapper").toggleClass("toggled");
    });
    </script>

</body>

</html>
