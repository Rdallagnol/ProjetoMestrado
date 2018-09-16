<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:import url="/WEB-INF/jsp/template/header.jsp" />

<c:if test="${mensagemOK != null}">
	<div class="alert alert-success alert-block">
		<h4>Success!</h4>
		${mensagemOK}
	</div>
</c:if>
<c:if test="${not empty errorMsg}">
	<div class=" row-fluid" id="msgError">

		<center>
			<div class="alert alert-error">
				<strong>${errorMsg}</strong>
			</div>
		</center>

	</div>
</c:if>

<div class="row-fluid">
	<form action="<c:url value='/cadArea'/>" method="POST"
		enctype="multipart/form-data">
		<div class="row-fluid" style="">

			<div class="bs-docs-example">
				<div class="row-fluid">
					<div class="">
						<div class="span3">
							<label for="area">Name:</label> <input type="text" name="nome" /><br />
							<label for="area">Size:</label> <input type="text" name="tamanho" /><br />
							<label for="area">File:</label> <input type="file"
								class="form-control" id="files" name="uploadedFile"
								required="required" />
						</div>
					</div>
				</div>
				<br>
				<div class="row-fluid">
					<input type="submit" value=Register />
				</div>
			</div>
		</div>
	</form>
</div>
<div class="row-fluid">
	<div class="bs-docs-example">
		<div class="row-fluid">File structure pattern</div>
		<img src="${pageContext.servletContext.contextPath}/img/p_area.png" />
	</div>
</div>



<c:import url="/WEB-INF/jsp/template/footer.jsp" />




