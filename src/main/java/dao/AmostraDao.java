/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import entity.AmostraEntity;


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
public class AmostraDao extends GenericDao<AmostraEntity, Long>{
    
    @SuppressWarnings("unchecked")
    public List<AmostraEntity> findByIdArea(Long id){               
        return (List<AmostraEntity>) this.executeQuery("select a from AmostraEntity a where a.area_codigo = ?0", id);
    } 

    @Post
	public void adiciona(AmostraEntity amostra) {		
		EntityManager manager =	DaoFactory.entityManagerFactoryInstance().createEntityManager();
			
		manager.getTransaction().begin();
		manager.persist(amostra);		
		manager.getTransaction().commit();
		
    }
}
