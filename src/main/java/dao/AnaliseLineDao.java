/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;


import entity.AnaliseLinesEntity;
import java.util.List;

import javax.enterprise.context.RequestScoped;

import utils.GenericDao;

/**
 *
 * @author Dallagnol
 */
@RequestScoped
public class AnaliseLineDao extends GenericDao<AnaliseLinesEntity, Long> {

    @SuppressWarnings("unchecked")
    public List<AnaliseLinesEntity> findByAnaliseHeader(Long analiseHeaderId) {    
        return (List<AnaliseLinesEntity>) this.executeQuery("select a from AnaliseLinesEntity a where a.analiseHeader.analise_header_id = ?0 order by a.isi ", analiseHeaderId);
    }
    
    @SuppressWarnings("unchecked")
    public List<AnaliseLinesEntity> findAnaliseLine(Long analiseLineId) {    	 
		List<AnaliseLinesEntity> l =  (List<AnaliseLinesEntity>) this.executeQuery("select a from AnaliseLinesEntity a where a.analise_lines_id = ?0", analiseLineId);    	
    	return l; 
    }
    
}
