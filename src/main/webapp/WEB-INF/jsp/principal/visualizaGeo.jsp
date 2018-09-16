<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:import url="/WEB-INF/jsp/template/header.jsp"/>

    
<div class="row-fluid" style="">
    
    <div class="row-fluid" id="spinner">
        <center><div class="alert alert-info"><strong>Processando </strong><img src="img/gif-image.gif" alt="spinner" /> </div></center>
    </div>
    <c:if test="${mensagemOK != null}"> 
        <div class="alert alert-success alert-block">      
            <h4>Sucesso!</h4>
            ${mensagemOK}
        </div>
    </c:if> 

    <div class="bs-docs-example">
        <div class="bs-docs-text">Analyzes </div>
        <div class="table-responsive " style="overflow: auto; max-height: 300px; overflow-y: auto ">
            <table class="table table-bordered table-striped table-hover table-condensed" style="">
                <thead>
                    <tr>

                        <th>ID</th>
                        <th>Description</th>
                        <th>Area</th>
                        <th>Attribute</th>
                        <th>User</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Options</th>
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
                                <form action="<c:url value='visualizaGeo'/>" method="post" class="btn btn-link" > 
                                    <input id="analiseId" type="hidden" name="analiseId"  value="${analise.analise_header_id}" />
                                    <button class="btn btn-mini " type="submit"><i class="icon-zoom-in "></i> View</button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>

                </tbody>
            </table>
        </div>
    </div>

    <c:if test="${not empty analiseLines}">
        <div class="bs-docs-example">
            <div class="bs-docs-text"> Linhas da Análise </div>
            <div class="table-responsive" style="overflow: auto; max-height: 300px; overflow-y: auto ">
                <table class="table table-bordered  table-hover table-condensed">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Model</th>                   
                            <th>Method</th>                                            
                            <th>Contribution</th>
                            <th>Range</th> 
                            <th>Pepita Effect</th>      
                            <th>Min. ICE</th>                 
                            <th>Kappa Value</th>
                            <!--<th>EM</th>-->
                            <!--<th>Desvio Padrão EM</th>-->
                            <th>ISI</th>                         
                            <th>Options</th>

                        </tr>
                    </thead>
                    <tbody >
                        <c:forEach var="analiseLine" items="${analiseLines}" varStatus="myIndex">
 

                            <c:if test="${myIndex.index == 0}">  
                                <tr style="background-color: #25d366">

                                    <td class="">${analiseLine.analise_lines_id}  </td>
                                    <td>${analiseLine.modelo}</td>
                                    <td>${analiseLine.metodo}</td>
                                    <td>${analiseLine.melhor_contrib}</td>
                                    <td>${analiseLine.melhor_alcance}</td>
                                    <td>${analiseLine.nugget}</td>
                                    <td>${analiseLine.min_ice}</td>
                                    <td>${analiseLine.melhor_val_kappa}</td>
                                    <!--<td>${analiseLine.erro_medio}</td>-->
                                    <!--<td>${analiseLine.dp_erro_medio}</td>-->
                                    <td>${analiseLine.isi}</td>
                                  
                                    <td class="">                           
                                         
                                         <c:choose>
										    <c:when test="${analiseLine.mapa_gerado == 1}">
										        <a href="${linkTo[PrincipalController].visualizaMapa(analiseLine.analise_lines_id)}" class="btn btn-mini btn-warning"><i class="icon-picture"></i> Map</a>										        
										    </c:when>    
										    <c:otherwise>
										        <form action="<c:url value='funcaoKrigagem'/> " method="post" name="formKrig" id="formKrig">
		                                            <input id="analise_line_id" type="hidden" name="analise_line_id" value="${analiseLine.analise_lines_id}" class="input-mini"/>    
		                                            <input id="user" type="hidden" name="user" value="872" class="input-mini"/>
				                                    <button class="btn btn-mini btn-primary" type="submit"><i class="icon-ok-sign icon-white"></i><br> Generate Map</button>
		                                        </form>
										    </c:otherwise>
										</c:choose>
                                         
                                    </td>
                                </tr>
                            </c:if>
                            <c:if test="${myIndex.index != 0}">   
                                <tr>
                                    <td class="">${analiseLine.analise_lines_id} </td>
                                    <td>${analiseLine.modelo}</td>
                                    <td>${analiseLine.metodo}</td>
                                    <td>${analiseLine.melhor_contrib}</td>
                                    <td>${analiseLine.melhor_alcance}</td>
                                    <td>${analiseLine.nugget}</td>
                                    <td>${analiseLine.min_ice}</td>
                                    <td>${analiseLine.melhor_val_kappa}</td>
                                    <!--<td>${analiseLine.erro_medio}</td>-->
                                    <!--<td>${analiseLine.dp_erro_medio}</td>-->
                                    <td>${analiseLine.isi}</td>
                               
                                    <td class="">
                                        
                                         <c:choose>
										    <c:when test="${analiseLine.mapa_gerado == 1}">
										        <a href="${linkTo[PrincipalController].visualizaMapa(analiseLine.analise_lines_id)}" class="btn btn-mini btn-warning"><i class="icon-picture"></i> Map</a>										        
										    </c:when>    
										    <c:otherwise>
										        <form action="<c:url value='funcaoKrigagem'/> " method="post" name="formKrig" id="formKrig">
		                                            <input id="analise_line_id" type="hidden" name="analise_line_id" value="${analiseLine.analise_lines_id}" class="input-mini"/>    
		                                            <input id="user" type="hidden" name="user" value="872" class="input-mini"/>
				                                    <button class="btn btn-mini btn-primary" type="submit"><i class="icon-ok-sign icon-white"></i><br> Generate Map</button>
		                                        </form>
										    </c:otherwise>
										</c:choose>
                                            
                                         
                                    </td>
                                </tr>
                            </c:if>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </c:if>

    <c:if test="${not empty analise}">
        <div class="row-fluid bs-docs-example" >
         
            <div class="bs-docs-text"> Graphic Representations </div>
            <div class="row-fluid bs-docs-example">
                <img src="${pageContext.servletContext.contextPath}/file/${analise.created_by}/${analise.descricao_analise}/box_plot.png">
                <img src="${pageContext.servletContext.contextPath}/file/${analise.created_by}/${analise.descricao_analise}/grafico_pontos.png">
                <img src="${pageContext.servletContext.contextPath}/file/${analise.created_by}/${analise.descricao_analise}/histograma.png">
                <img src="${pageContext.servletContext.contextPath}/file/${analise.created_by}/${analise.descricao_analise}/plot_geral.png">              
                <img src="${pageContext.servletContext.contextPath}/file/${analise.created_by}/${analise.descricao_analise}/modelos.png">
                <img src="${pageContext.servletContext.contextPath}/file/${analise.created_by}/${analise.descricao_analise}/melhor_modelo.png">
                
            </div>
         
        </div>
    </c:if>
</div>
<c:import url="/WEB-INF/jsp/template/footer.jsp"/>

