<%@include file="../template/header.jsp" %>
<div class="row-fluid" >
    <form action="funcaoGeo" method="post">
        <div class="row-fluid" style="">

            <div class="bs-docs-example">
                <div class="bs-docs-text"> Informa��es </div>
                <div>
                    Usu�rio : <b>Rodrigo</b>
                    <input id="user" type="hidden" name="user" value="Rodrigo_1" class="input-mini"/>
                </div>
                <hr>
                <!-- SER� NECESS�RIO UMA CONEX�O COM O BANCO DE DADOS PARA BUSCAR ESSAS INFORMA��ES-->
                <div class="row-fluid">
                    <div class="">
                        <div class="span3">
                            <label for="area">�rea:</label>
                            <select name="area">
                                <option value="1">A</option>
                                <option value="2">B</option>
                                <option value="3">C</option>
                            </select> 
                        </div>
                        <div class="span3">
                            <label for="amostra">Amostra:</label>
                            <select name="amostra">
                                <option value="1">C�lcio</option>
                                <option value="2">Produ��o</option>
                                <option value="3">PH</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
        </div>


        <div class="row-fluid" style="">

            <div class="bs-docs-example span12" >                       
                <div class="bs-docs-text "> Configura��es </div>
                <div class="">
                    <div class="span3">
                        <label for="desc">Descri��o:</label>
                        <input id="desc" type="text" name="desc" required="true"/>
                    </div>
                    <div class="span9">
                        <label for="interpolador">Interpolador:</label>
                        <select name="interpolador" required="TRUE">
                            <option value=""></option>
                            <option value="KO">Krigagem Ordin�ria</option>
                            <option value="ID">Inverso da Dist�ncia</option>
                            <option value="MM">MM(Verificar)</option>
                            <option value="VMP">Vizinho mais pr�ximo</option>
                        </select> 
                    </div>
                </div>



                <div class="row-fluid">

                    <!-- ESTRUTURA INTERNA COME�A AQUI DA KRIGAGEM-->
                    <div class="bs-docs-example span12" id="krigdiv" name="krigdiv" style="margin-left: 0px;display: none;" >

                        <div class="bs-docs-text">Krigagem Ordin�ria</div> 
                        <div class="tabbable"> 
                            <ul class="nav nav-tabs">
                                <li class="active"><a href="#krigtab1" data-toggle="tab">Parametr�s</a></li>
                                <li><a href="#krigtab2" data-toggle="tab">Semivariograma</a></li>

                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane active" id="krigtab1">
                                    <div class="row-fluid" style="">
                                        <div class="span2">                                  
                                            <label for="nlags">N� Lags</label>
                                            <input id="nlags" type="text" name="nlags" class="input-mini" value="11"/>
                                            <label for="npares">N� Pares</label>
                                            <input id="npares" type="text" name="npares" class="input-mini" value="30"/>
                                        </div>
                                        <div class="span2">

                                            <label for="estimador">Estimador:</label>
                                            <select name="estimador" class="input-medium">
                                                <option value="classical">Matheron</option>                  
                                            </select>


                                            <label for="vlkappa">Valor Kappa</label>
                                            <select name="vlkappa" class="input-small">
                                                <option value="0.5">0.5</option>
                                                <option value="1.0">1.0</option>
                                                <option value="1.5">1.5</option>
                                                <option value="2.0">2.0</option>                                            
                                            </select> 
                                        </div>
                                        <div class="span3">                                  
                                            <label for="ncontri">N� Intervalos Contribui��o</label>
                                            <input id="ncontri" type="text" name="ncontri" class="input-mini" value="20"/>
                                            <label for="nalcance">N� Intervalos Alcance</label>
                                            <input id="nalcance" type="text" name="nalcance" class="input-mini" value="15"/>
                                        </div>
                                    </div>
                                </div>
                                <div class="tab-pane" id="krigtab2">
                                    <div class="row-fluid" style="">

                                        <div class="row-fluid">
                                            <div class="span2">
                                                <label for="modelo">Modelo(Verificar)</label>
                                                <select name="modelo" class="input-medium">
                                                    <option value="all">Todos</option>         
                                                    <option value="exp">Exponencial</option>
                                                    <option value="sph">Esf�rico</option>
                                                    <option value="gaus">Gaussiano</option>
                                                    <option value="matern">Matheron</option>
                                                </select>
                                                <label for="semicorlinha">Cor linha</label>
                                                <select name="semicorlinha" class="input-medium">
                                                    <option value="yellow">Amarelo</option>   
                                                    <option value="blue">Azul</option>
                                                    <option value="green">Verde</option>
                                                    <option value="red">Vermelho</option>                                                                                        
                                                </select>
                                            </div>                                          
                                            <div class="span2">
                                                <label for="nalcance">M�todo de Ajuste</label>
                                                <select name="metodoajust" class="input-small">
                                                    <option value="ols">OLS</option>                                                                                                                                            
                                                </select>
                                                <label for="nalcance">Pesos</label>
                                                <select name="pesos" class="input-small">
                                                    <option value="pesos">equals - OLS</option>                                                                                                                                            
                                                </select>

                                            </div>

                                        </div>
                                    </div>
                                </div>                              

                            </div>

                        </div>

                    </div>

                    <div class="bs-docs-example span12" id="ivdiv" name="ivdiv"  style="margin-left: 0px; display: none;" >

                        <div class="bs-docs-text">Inverso da Dist�ncia</div> 
                        <div class="tabbable"> 
                            <ul class="nav nav-tabs">
                                <li class="active"><a href="#invtab1" data-toggle="tab">Parametr�s</a></li>


                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane active" id="invtab1">
                                    <div class="row-fluid" style="">
                                        <div class="span2">
                                            <label for="expoente">Expoente</label>
                                            <input id="expoente" type="text" name="expoente" class="input-mini" value="1"/>

                                            <label for="vizinhos">N� Vizinhos</label>
                                            <input id="vizinhos" type="text" name="vizinhos" class="input-mini" value="10"/>
                                        </div>

                                        <div class="span2">
                                            <label for="expoente">Expoente Inicial</label>
                                            <input id="expoini" type="text" name="expoini" class="input-mini" value="0.5"/>

                                            <label for="expofinal">Expoente Final</label>
                                            <input id="expofinal" type="text" name="expofinal" class="input-mini" value="4.0"/>
                                        </div>
                                        <div class="span2">
                                            <label for="expoente">Intervalo Expoentes</label>
                                            <input id="expoinv" type="text" name="expoinv" class="input-mini" value="0.5"/>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </div>

                    </div>

                    <div class="bs-docs-example span12" id="mmdiv" name="mmdiv"  style="margin-left: 0px; display: none;" >

                        <div class="bs-docs-text">M�ximo Minimo</div> 
                        <div class="tabbable"> 
                            <ul class="nav nav-tabs">
                                <li class="active"><a href="#mmtab1" data-toggle="tab">Parametr�s</a></li>


                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane active" id="mmtab1">
                                    <div class="row-fluid" style="">

                                    </div>
                                </div>
                            </div>

                        </div>

                    </div>
                    <div class="bs-docs-example span12" id="vmpdiv" name="vmpdiv"  style="margin-left: 0px; display: none;" >
                        <div class="bs-docs-text">Vizinho mais pr�ximo</div> 
                        <div class="tabbable"> 
                            <ul class="nav nav-tabs">
                                <li class="active"><a href="#vmptab1" data-toggle="tab">Parametr�s</a></li>
                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane active" id="vmptab1">
                                    <div class="row-fluid" style="">                                        
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>


                    <!-- ESTRUTURA INTERNA FECHA AQUI DA KRIGAGEM-->

                    <!-- AQUIO S�O INFORMA��ES DOS OUTROS METODOS -->


                    <!-- FIM DAS INFORMA��ES DOS OUTROS METODOS -->


                </div>  

            </div>
            <div class="bs-docs-example span4" id="defaultdiv" name="defaultdiv" style="margin-left: 0px; display: none;">

                <div class="bs-docs-text">Pixel</div>
                <div class=" form-inline">
                    <label for="tamx">Tam. X</label>
                    <input id="tamx" type="text" name="tamx" class="input-mini" value="5"/>

                    <label for="tamy">Tam. Y</label>
                    <input id="tamy" type="text" name="tamy" class="input-mini" value="5"/>
                </div>

            </div>
        </div>


        <div class="btn span11" style="visibility: hidden"></div>
        <div class="navbar navbar-fixed-bottom">
            <center>
                <button class="btn btn-large btn-primary" type="submit">Enviar</button>
            </center>
        </div>

    </form>
</div>

<%@include file="../template/footer.jsp" %>




