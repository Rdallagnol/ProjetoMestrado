<%-- 
    Document   : index
    Created on : 19/03/2016, 14:42:37
    Author     : Dallagnol
--%>

<%@page import="java.io.IOException"%>
<%--<%@page contentType="text/html" pageEncoding="UTF-8"%>--%>
<%@page contentType="text/html; charset=UTF-8"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html>
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="Content-Style-Type" content="text/css">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>GAS - Geostatistical Analysis System</title>


<link href="${pageContext.request.contextPath}/css/bootstrap.min.css"
	rel="stylesheet" />
<link
	href="${pageContext.request.contextPath}/css/bootstrap-responsive.css"
	rel="stylesheet" />
<link href="${pageContext.request.contextPath}/css/loader.css"
	rel="stylesheet" />
<link rel="shortcut icon"
	href="${pageContext.request.contextPath}/img/favicon.ico">
</head>

<body style="background-color: #fafafa;">

	<div id="container-fluid">
		<div class="row-fluid">
			<div id="header">
				<div class="navbar navbar-fixed-top">
					<div class="navbar-inner row-fluid">
						<ul class="nav">
							<li>
								<div style="padding: 4px;">
									<img src="${pageContext.request.contextPath}/img/logoMenu.png">
								</div>
							</li>
							<li class="active"><a
								href="${linkTo[PrincipalController].index()}">Home</a></li>
						</ul>

					</div>
				</div>
				<br>
			</div>
		</div>

		<div class="row-fluid" style="padding-top: 1.56%">
			<div class="nav ">
				<div class="menu-fundo ">
					<div id="menu" class="span2">

						<button type="button" class="btn btn-block" data-toggle="collapse"
							style="border: 1px solid silver" data-target="#menuG">
							<li class="nav-header">Geostatistics / Ordinary Kriging</li>
						</button>
						<div class="menu-fundo" style="padding-top: 15px;">

							<ul class="nav nav-pills ">
								<div id="menuG" class="collapse in ">
									<li class="nav-header"
										style="border-bottom: 1px solid silver; border-right: 1px solid silver">
										<a href="<c:url value="/funcaoGeo"/>">Generate
											Geostatistical Analysis</a>
									</li>

									<li class="nav-header"
										style="border-bottom: 1px solid silver; border-right: 1px solid silver">
										<a href="<c:url value="/visualizaGeo"/>">View
											Geostatistical Analyzes </a>
									</li>


								</div>
							</ul>
						</div>
						<button type="button" class="btn btn-block" data-toggle="collapse"
							style="border: 1px solid silver" data-target="#menuIDW">
							<li class="nav-header">Statistics / Inverse Distance</li>
						</button>
						<div class="menu-fundo" style="padding-top: 15px;">

							<ul class="nav nav-pills ">
								<div id="menuIDW" class="collapse in ">

									<li class="nav-header"
										style="border-bottom: 1px solid silver; border-right: 1px solid silver">
										<a href="<c:url value="/funcaoIdw"/>">Generate IDW
											Analyzes</a>
									</li>

									<li class="nav-header"
										style="border-bottom: 1px solid silver; border-right: 1px solid silver">
										<a href="<c:url value="/visualizaIdw"/>">View IDW Analyzes</a>
									</li>

								</div>
							</ul>
						</div>

						<button type="button" class="btn btn-block" data-toggle="collapse"
							style="border: 1px solid silver" data-target="#config">
							<li class="nav-header">Registration</li>
						</button>
						<div class="menu-fundo" style="padding-top: 15px;">

							<ul class="nav nav-pills ">
								<div id="conf" class="collapse in ">

									<li class="nav-header"
										style="border-bottom: 1px solid silver; border-right: 1px solid silver">
										<a href="<c:url value="/cadArea"/>">Register Area</a>
									</li>

									<li class="nav-header"
										style="border-bottom: 1px solid silver; border-right: 1px solid silver">
										<a href="<c:url value="/cadAmostra"/>">Register Attribute </a>
									</li>

								</div>
							</ul>
						</div>

					</div>
				</div>

				<div id="content" class="span10 clearfix">