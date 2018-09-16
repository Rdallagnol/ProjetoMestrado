/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utils;

import dao.AmostraDao;
import dao.AnaliseDao;
import dao.AnaliseLineDao;
import dao.AreaDao;
import dao.PixelAmostraDao;

import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

/**
 *
 * @author Dallagnol
 */

public final class DaoFactory {

    public DaoFactory() {
    }

    ////////////////////////////////
    /// Entity Manager Factory
    ////////////////////////////////
    private static final String PERSISTENCE_UNIT_NAME = "default";

    private static EntityManagerFactory entityManagerFactoryInstace;

    public static EntityManagerFactory entityManagerFactoryInstance() {
        if (entityManagerFactoryInstace == null) {
            entityManagerFactoryInstace = Persistence.createEntityManagerFactory(PERSISTENCE_UNIT_NAME);
        }
        return entityManagerFactoryInstace;
    }

    /////////////////////////////
    /// Analise
    /////////////////////////////
    private static AnaliseDao analiseDaoInstance;

    public static AnaliseDao analiseInstance() {
        if (analiseDaoInstance == null) {
            analiseDaoInstance = new AnaliseDao();
        }
        return analiseDaoInstance;
    }

    /////////////////////////////
    /// Analise Lines
    /////////////////////////////
    private static AnaliseLineDao analiseLineDaoInstance;

    public static AnaliseLineDao analiseLineInstance() {
        if (analiseLineDaoInstance == null) {
            analiseLineDaoInstance = new AnaliseLineDao();
        }
        return analiseLineDaoInstance;
    }
    
    
    /////////////////////////////
    /// Area
    /////////////////////////////
    private static AreaDao areaDaoInstance;

    public static AreaDao areaDaoInstance() {
        if (areaDaoInstance == null) {
            areaDaoInstance = new AreaDao();
        }
        return areaDaoInstance;
    }
    
    /////////////////////////////
    /// Amostra
    /////////////////////////////
    private static AmostraDao amostraDaoInstance;

    public static AmostraDao amostraDaoInstance() {
        if (amostraDaoInstance == null) {
            amostraDaoInstance = new AmostraDao();
        }
        return amostraDaoInstance;
    }
    
    /////////////////////////////
    /// Pixel Amostra
    /////////////////////////////
    private static PixelAmostraDao pixelAmostraDaoInstance;

    public static PixelAmostraDao pixelAmostraDaoInstance() {
        if (pixelAmostraDaoInstance == null) {
        	pixelAmostraDaoInstance = new PixelAmostraDao();
        }
        return pixelAmostraDaoInstance;
    }
}
