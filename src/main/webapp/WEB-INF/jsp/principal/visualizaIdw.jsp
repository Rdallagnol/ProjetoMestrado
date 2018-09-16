<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:import url="/WEB-INF/jsp/template/header.jsp" />


<div class="row-fluid" style="">

	<div class="row-fluid" id="spinner">
		<center>
			<div class="alert alert-info">
				<strong>Processando </strong><img src="img/gif-image.gif"
					alt="spinner" />
			</div>
		</center>
	</div>
	<c:if test="${mensagemOK != null}">
		<div class="alert alert-success alert-block">
			<h4>Sucesso!</h4>
			${mensagemOK}
		</div>
	</c:if>

	<div class="bs-docs-example">
		<div class="bs-docs-text">Análises Realizadas</div>
		<div class="table-responsive "
			style="overflow: auto; max-height: 300px; overflow-y: auto">
			<table
				class="table table-bordered table-striped table-hover table-condensed"
				style="">
				<thead>
					<tr>

						<th>Código</th>
						<th>Descrição</th>
						<th>Área</th>
						<th>Amostra</th>
						<th>Usuário</th>
						<th>Data</th>
						<th>Status</th>
						<th>Opções</th>
					</tr>
				</thead>
				<tbody>
					<c:forEach var="analise" items="${analises}">

						<tr>
							<td>${analise.analise_header_id}</td>
							<td>${analise.descricao_analise}</td>
							<td>${analise.area.nome}</td>
							<td>${analise.amostra.descricao}</td>
							<td>${analise.created_by}</td>
							<td>${analise.creation_date}</td>
							<td>${analise.status}</td>
							<td>
								<form action="<c:url value='visualizaIdw'/>" method="post"
									class="btn btn-link">
									<input id="analiseId" type="hidden" name="analiseId"
										value="${analise.analise_header_id}" />
									<button class="btn btn-mini " type="submit"><i class="icon-zoom-in "></i>Visualizar</button>
								</form>
							</td>
						</tr>
					</c:forEach>

				</tbody>
			</table>
		</div>
	</div>


	<c:if test="${not empty analise}">
		<div class="row-fluid bs-docs-example">

			<div class="bs-docs-text">Representações Gráficas</div>
			<div class="row-fluid bs-docs-example">

				<div class="span6">
					<img
						src="${pageContext.servletContext.contextPath}/mapa/${analise.created_by}/${analise.descricao_analise}/mapa_idw.png">
				</div>
				<div class="span2">
					<table class="table table-bordered">
						<thead>
							<tr>
								<th>Informações</th>

							</tr>
						</thead>

						<tbody>
							<tr>
								<th>Área</th>
								<td>${analise.area.nome}</td>
							</tr>

							<tr>
								<th>Amostra</th>
								<td>${analise.amostra.descricao}</td>
							</tr>
							
							<tr>
								<th>Interpolador</th>
								<td>${analise.tipo_analise}</td>
							</tr>

						</tbody>
					</table>
				</div>

			</div>
			<div class="bs-docs-example">
				<img
					src="${pageContext.servletContext.contextPath}/mapa/${analise.created_by}/${analise.descricao_analise}/box_plot.png">

				<img
					src="${pageContext.servletContext.contextPath}/mapa/${analise.created_by}/${analise.descricao_analise}/grafico_pontos.png">
				<img
					src="${pageContext.servletContext.contextPath}/mapa/${analise.created_by}/${analise.descricao_analise}/histograma.png">
				<img
					src="${pageContext.servletContext.contextPath}/mapa/${analise.created_by}/${analise.descricao_analise}/plot_geral.png">
			</div>




		</div>
</div>
</c:if>
</div>
<c:import url="/WEB-INF/jsp/template/footer.jsp" />

