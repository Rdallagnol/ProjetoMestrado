<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:import url="/WEB-INF/jsp/template/header.jsp" />

<div class="row-fluid">

	<c:if test="${mensagemOK != null}">
		<div class="alert alert-success alert-block">
			<h4>Success</h4>
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
	<form action="<c:url value='/cadAmostra'/>" method="POST"
		enctype="multipart/form-data">
		<div class="row-fluid" style="">

			<div class="bs-docs-example">


				<div class="row-fluid">

					<div class="span8">
						<label for="area">Field:</label> <select name="area" id="area"
							class="area required" required="true">
							<option value="">Select a field</option>
							<c:forEach var="area" items="${areas}">
								<option value="${area.codigo}">${area.nome}</option>
							</c:forEach>

						</select>
					</div>

				</div>

				<div class="row-fluid">
					<div class="span8">
						<label for="descricao">Description:</label> <input type="text"
							name="descricao" />
					</div>
				</div>
				<div class="row-fluid">
					<div class="span8">
						<label for="files">File</label> <input type="file"
							class="form-control" id="files" name="uploadedFile"
							required="required" />
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
		<img src="${pageContext.servletContext.contextPath}/img/p_amostra.png" />
	</div>
</div>



<c:import url="/WEB-INF/jsp/template/footer.jsp" />




