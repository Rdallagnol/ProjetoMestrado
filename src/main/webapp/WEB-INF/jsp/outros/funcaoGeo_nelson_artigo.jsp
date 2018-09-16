<%@include file="../template/header.jsp" %>
<div class="row-fluid" >
    <form action="funcaoGeo" method="post">
        <div class="row-fluid" style="">

            <div class="bs-docs-example">
                <div class="bs-docs-text"> Informa��es </div>
                <div>
                    Usu�rio : <b>Nelson</b>
                    <input id="user" type="hidden" name="user" value="872" class="input-mini"/>
                </div>
                <hr>
                <!-- SER� NECESS�RIO UMA CONEX�O COM O BANCO DE DADOS PARA BUSCAR ESSAS INFORMA��ES-->
                <div class="row-fluid">
                    <div class="">
                        <div class="span3">
                            <label for="area">�rea:</label>
                            <select name="area">
                                <option value="1">Schenatto - B</option>
                                <option value="2">B</option>
                                <option value="3">C</option>
                            </select> 
                        </div>
                        <div class="span3">
                            <label for="amostra">Amostra:</label>
                            <select name="amostra">
                                <option value="1">Produtividade</option>
                                <option value="2">Produ��o</option>
                                <option value="3">PH</option>
                            </select>
                        </div>
                    </div>               
                </div>

                <div class="row-fluid">
                    <div class="span3">
                        <label for="desc">Descri��o:</label>
                        <input id="desc" type="text" name="desc" class="input-xxlarge" required="true"/>
                    </div> 
                </div>
            </div>
        </div>


        <div class="row-fluid" style="">
            <div class="bs-docs-example span12" >                       
                <div class="bs-docs-text "> Configura��es </div>
                <div class="">
                    <div class="bs-docs-example span4" id="defaultdiv" name="defaultdiv" style="margin-left: 0px;">
                        <div class="bs-docs-text">Pixel</div>
                        <div class=" form-inline">
                            <label for="tamx">Tam. X</label>
                            <input id="tamx" type="text" name="tamx" class="input-mini" value="5"/>

                            <label for="tamy">Tam. Y</label>
                            <input id="tamy" type="text" name="tamy" class="input-mini" value="5"/>
                        </div>
                    </div>                 
                </div>

                <div class="">
                    <div class="bs-docs-example span12" style="margin-left: 0px;">
                        <div class="bs-docs-text">Avan�ado</div>

                        <div class="row-fluid" style="">
                            <div class="span4">
<!--                                <label for="auto_lags">ISI</label>
                                <select id="isi" name="isi" class="input-mini">
                                    <option value="true" selected="selected">Sim</option>
                                    <option value="false">N�o</option>                                 
                                </select>-->

<!--                                <label for="v_lambda">Transformar dados?</label>
                                <select id="v_lambda" name="v_lambda" class="input-mini">
                                    <option value="1" selected="selected">Sim</option>
                                    <option value="0">N�o</option>                                 
                                </select>-->
                                
                                
                                <label for="auto_lags">Lags Autom�ticos</label>
                                <select id="auto_lags" name="auto_lags" class="input-mini">
                                    <option value="true" selected="selected">Sim</option>
                                    <option value="false">N�o</option>                                 
                                </select>
                                
                                       <label for="nro_lags">N� De Lags</label>
                                <input id="nro_lags" type="text" name="nro_lags" class="input-mini" value="11"/>

                                
<!--                                 <label for="estimador">Estimador</label>
                                <select id="estimador" name="estimador" class="input-large">
                                    <option value="classical" selected="selected">Matheron - Classical</option>
                                    <option value="modulus">Cressie - Modulus</option>                                 
                                </select>-->
                            </div>
                            <div class="span4">
                                

                         
                                 <label for="nro_pares">N� De Pares</label>
                                <input id="nro_pares" type="text" name="nro_pares" class="input-mini" value="30"/>
                                
                                       <label for="cutoff">Cutoff (%)</label>
                                <input id="cutoff" type="text" name="cutoff" class="input-mini" value="50"/>
                                
                                
<!--                                <label for="nro_min_contr">N� M�nimo Sequ�ncia Contribui��o</label>
                                <input id="nro_min_contr" type="text" name="nro_min_contr" class="input-mini" value="0"/>
                                
                                <label for="nro_min_alc">N� M�nimo Sequ�ncia Alcance</label>
                                <input id="nro_min_alc" type="text" name="nro_min_alc" class="input-mini" value="0"/>
                            -->
                            </div>
                            <div class="span4">
                               

                         
                                 <label for="nro_intervalos_alc">N� Intervalo Alcance</label>
                                <input id="nro_intervalos_alc" type="text" name="nro_intervalos_alc" class="input-mini" value="5"/>

                                <label for="nro_intervalos_contr">N� Intervalo Contribui��o</label>
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
                <button class="btn btn-large btn-primary" type="submit">Processar</button>
            </center>
        </div>

    </form>


</div>

<%@include file="../template/footer.jsp" %>




