/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import entity.AreaEntity;

import java.util.ArrayList;
import java.util.List;

import javax.enterprise.context.RequestScoped;


import javax.persistence.EntityManager;


import br.com.caelum.vraptor.Post;
import utils.DaoFactory;
import utils.GenericDao;

/**
 *
 * @author Dallagnol
 */
@RequestScoped
public class AreaDao extends GenericDao<AreaEntity, Long> {
	
	@Post
	public void adiciona(AreaEntity area) {		
		EntityManager manager =	DaoFactory.entityManagerFactoryInstance().createEntityManager();
			
		manager.getTransaction().begin();
		manager.persist(area);		
		manager.getTransaction().commit();
		
    }	
	
	public List<AreaEntity> listaTodos() {
	    return new ArrayList<AreaEntity>();
	}
	
	
}
