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
    <form action="funcaoGeo" method="post" name="formGeo" id="formGeo">
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
                <div class="">
                    <div class="bs-docs-example span4" id="defaultdiv" name="defaultdiv" style="margin-left: 0px;">
                        <div class="bs-docs-text">Pixel</div>
                        <div class=" form-inline">
                            <div class="span6">
                                <label for="tamx">Size X</label>
                                <input id="tamx" type="text" name="tamx" class="input-mini" value="5"/>
                            </div>
                            <div class="span6">

                                <label for="tamy">Size Y</label>
                                <input id="tamy" type="text" name="tamy" class="input-mini" value="5"/>
                            </div>
                        </div>
                    </div>                 
                </div>

                <div class="">
                    <div class="bs-docs-example span12" style="margin-left: 0px;">
                        <div class="bs-docs-text">Advanced</div>

                        <div class="row-fluid" style="">
                            <div class="span4">
                                <label for="auto_lags">ISI</label>
                                <select id="isi" name="isi" class="input-mini">
                                    <option value="true" selected="selected">Yes</option>
                                    <option value="false">No</option>                                 
                                </select>

                                <label for="v_lambda">Transform data?</label>
                                <select id="v_lambda" name="v_lambda" class="input-mini">
                                    <option value="1" selected="selected">Yes</option>
                                    <option value="0">No</option>                                 
                                </select>


                                <label for="auto_lags">Automatic Lags</label>
                                <select id="auto_lags" name="auto_lags" class="input-mini">
                                    <option value="true" selected="selected">Yes</option>
                                    <option value="false">No</option>                                 
                                </select>

                                <label for="estimador">Estimator</label>
                                <select id="estimador" name="estimador" class="input-large">
                                    <option value="classical" selected="selected">Matheron - Classical</option>
                                    <option value="modulus">Cressie - Modulus</option>                                 
                                </select>
                            </div>
                            <div class="span4">


                                <label for="nro_lags">Lags number</label>
                                <input id="nro_lags" type="text" name="nro_lags" class="input-mini" value="11"/>


                                <label for="nro_pares">Number of Pairs</label>
                                <input id="nro_pares" type="text" name="nro_pares" class="input-mini" value="30"/>

                                <label for="nro_min_contr">Minimum Sequence Contribution</label>
                                <input id="nro_min_contr" type="text" name="nro_min_contr" class="input-mini" value="0"/>

                                <label for="nro_min_alc">Minimum Sequence Range</label>
                                <input id="nro_min_alc" type="text" name="nro_min_alc" class="input-mini" value="0"/>
                            </div>
                            <div class="span4">


                                <label for="cutoff">Cutoff</label>
                                <input id="cutoff" type="text" name="cutoff" class="input-mini" value="50"/>

                                <label for="nro_intervalos_alc">Interval Reach</label>
                                <input id="nro_intervalos_alc" type="text" name="nro_intervalos_alc" class="input-mini" value="5"/>

                                <label for="nro_intervalos_contr">Contribution Interval</label>
                                <input id="nro_intervalos_contr" type="text" name="nro_intervalos_contr" class="input-mini" value="5"/>

                            </div>
                        </div>
                    </div>                 
                </div>
            </div>
        </div>
        <div class="btn span11" style="visibility: hidden"></div>
        <div class="navbar navbar-fixed-bottom">
            <center>
                <button class="btn btn-large btn-primary" type="submit" id="btnEnviar" name="btnEnviar"><i class="icon-ok-sign icon-white"></i> Generate</button>
            </center>
        </div>
    </form>
</div>




<c:import url="/WEB-INF/jsp/template/footer.jsp"/>




