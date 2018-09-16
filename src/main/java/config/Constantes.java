/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package config;


 
/**
 *
 * @author Dallagnol
 */
public class Constantes {
    

	
    /** INFORMAÇÕES DA BASE DE DADOS **/
    public static final String DATA_BASE_HOST = "localhost";
    public static final String DATA_BASE_PORT = "5432";
    public static final String DATA_BASE_NAME = "sdumOnlinev3";    
    public static final String DATA_BASE_USER = "postgres";
    public static final String DATA_BASE_PASSWORD = "1";
    
    /** ENDEREÇO DO R NO SERVIDOR */
    
    public static final String ENDERECO_R = "C:\\Program Files\\R\\R-3.2.5\\bin\\x64\\Rscript.exe ";    
    
    /** ENDEREÇO DO SCRIPT DE GEOESTATÍSTICA */
    
    public static final String ENDERECO_GEO_S = "D:\\ProjetoGstat-Final\\src\\main\\webapp\\scripts\\R\\Principal\\script_geo.r ";     
    
    /** ENDEREÇO DO SCRIPT DE KRIGAGEM ORDINÁRIA */
    public static final String ENDERECO_KRIG_S = "D:\\ProjetoGstat-Final\\src\\main\\webapp\\scripts\\R\\Principal\\script_krig.r ";  
   
    /** ENDEREÇO DO SCRIPT DO INVERSO DA DISTANCIA */
    public static final String ENDERECO_IDW_S = "D:\\ProjetoGstat-Final\\src\\main\\webapp\\scripts\\R\\Principal\\script_idw.r ";  
    
    /** ENDEREÇO DA PASTA DE GRAVAÇÃO DOS ARQUIVOS */
     
    public static final String ENDERECO_FILE = "D:\\ProjetoGstat-Final\\src\\main\\webapp\\file";
    public static final String ENDERECO_MAPA = "D:\\ProjetoGstat-Final\\src\\main\\webapp\\mapa";
    

}
