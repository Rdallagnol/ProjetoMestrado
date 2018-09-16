<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:import url="/WEB-INF/jsp/template/header.jsp"/>


<div class=" row-fluid" id="spinner">
    <center><div class="alert alert-info"><strong>Processando </strong><img src="img/gif-image.gif" alt="spinner" /> </div></center>
</div>

<c:if test="${not empty errorMsg}">
    <div class=" row-fluid" id="msgError">

        <center> <div class="alert alert-error" ><strong>${errorMsg}</strong></div></center>

    </div>
</c:if>

<div class="row-fluid" >
    <form action="funcaoIdw" method="post" name="formIdw" id="formIdw">
        <div class="row-fluid" style="">

            <div class="bs-docs-example">
                <div class="bs-docs-text"> Information </div>
                <div>
                    User : <b>Rodrigo</b>
                    <input id="user" type="hidden" name="user" value="872" class="input-mini"/>
                </div>
                <hr>
                <!-- SERÁ NECESSÁRIO UMA CONEXÃO COM O BANCO DE DADOS PARA BUSCAR ESSAS INFORMAÇÕES-->
                <div class="row-fluid">
                    <div class="">
                        <div class="span3">
                            <label for="area">Area:</label>
                            <select name="area" id="area" class="area required" required="true">
                                <option value="">Select an Area</option>
                                <c:forEach var="area" items="${areas}">
                                    <option value="${area.codigo}">${area.nome}</option>
                                </c:forEach>

                            </select> 
                        </div>
                        <div class="span3">
                            <label for="amostra">Attribute:</label>
                            <select name="amostra" id="amostra" class="required" required="true"></select>                        
                        </div>
                    </div>               
                </div>

                <div class="row-fluid">
                    <div class="span3">
                        <label for="desc">Description:</label>
                        <input id="desc" type="text" name="desc" class="input-xxlarge required" required="true"/>
                    </div> 
                </div>
            </div>
        </div>

        <div class="row-fluid" style="">
            <div class="bs-docs-example span12" >                       
                <div class="bs-docs-text "> Settings </div>
        
                    <div class="bs-docs-example span4" id="defaultdiv" name="defaultdiv" style="margin-left: 0px;">
                        <div class="bs-docs-text">Pixel</div>
                        <div class=" form-inline">
                            <div class="span4">
                                <label for="tamx">Size X</label>
                                <input id="tamx" type="text" name="tamx" class="input-mini" value="5"/>
                            </div>
                            <div class="span4">

                                <label for="tamy">Size Y</label>
                                <input id="tamy" type="text" name="tamy" class="input-mini" value="5"/>
                            </div>
                            <div class="span4">

                                <label for="raio">Range radius</label>
                                <input id="raio" type="text" name="raio" class="input-mini" value="0"/>
                            </div>
                        </div>
                    </div>                 
         

                <div class=""> 
                    <div class="bs-docs-example span12" style="margin-left: 0px;">
                        <div class="bs-docs-text">Advanced</div>

                        <div class="row-fluid" style="">
                            <div class="span3">
                            
                                <label for="expoente">Exponent</label>
                              
                                <input id="expoente" type="text" name="expoente" class="input-mini" value="1"/>
						
                                <label for="vizinhos">Number of neighbors</label>
                                <input id="vizinhos" type="text" name="vizinhos" class="input-mini" value="50"/>                      
                                
                            </div>
                            
<!--                             <div class="span3"> -->
<!--                                 <label for="expoini">Expoente Inicial</label> -->
<!--                                 <input id="expoini" type="text" name="expoini" class="input-mini" value="0.5"/> -->

<!--                                 <label for="expofinal">Expoente Final</label> -->
<!--                                 <input id="expofinal" type="text" name="expofinal" class="input-mini" value="4.0"/> -->
<!--                             </div> -->
                            
<!--                             <div class="span3"> -->
<!--                             	<label for="expoint">Intervalo Expoentes</label> -->
<!--                             	<input id="expoint" type="text" name="expoint" class="input-mini" value="0.5"/> -->
<!--                             </div> -->
                            
                        </div>
                    </div>                 
                </div>
            </div>
        </div>
        <div class="btn span11" style="visibility: hidden"></div>
        <div class="navbar navbar-fixed-bottom">
            <center>
                <button class="btn btn-large btn-primary" type="submit" id="btnEnviar" name="btnEnviar"> <i class="icon-ok-sign icon-white"></i> Generate</button>
            </center>
        </div>
    </form>
</div>




<c:import url="/WEB-INF/jsp/template/footer.jsp"/>




