/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package dao;

import entity.AnaliseEntity;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import utils.GenericDao;

/**
 *
 * @author Dallagnol
 */
@RequestScoped
public class AnaliseDao extends GenericDao<AnaliseEntity, Long>{
    
    @SuppressWarnings("unchecked")
    public List<AnaliseEntity> findById(Long id){
        return  (List<AnaliseEntity>) this.executeQuery("select a from AnaliseEntity a where a.analise_header_id = ?0", id);
    }

    @SuppressWarnings("unchecked")
    public List<AnaliseEntity> findAllOrdenado(String tipoAnalise) {   
        return (List<AnaliseEntity>) this.executeQuery("from AnaliseEntity where tipo_analise  = ?0 order by 1 desc",tipoAnalise);
    }

}
