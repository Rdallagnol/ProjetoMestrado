/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package entity;

import java.util.Date;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import utils.BaseBean;

/**
 *
 * @author Dallagnol
 */
@Entity
@Table(name = "geo_analise_lines")
public class AnaliseLinesEntity extends BaseBean {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Id
    @SequenceGenerator(name = "geo_analise_lines_seq", sequenceName = "geo_analise_lines_seq", allocationSize = 1)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "geo_analise_lines_seq")
    private Long analise_lines_id;

    @ManyToOne
    @JoinColumn(name = "analise_header_id")
    private AnaliseEntity analiseHeader;
    
    private String modelo;
    private String metodo;
    private Double min_ice;
    private Double melhor_contrib;
    private Double melhor_alcance;
    private Double melhor_val_kappa;
    private Double nugget;
    private Double erro_medio;
    private Double dp_erro_medio;
    private Double isi;
    private Long mapa_gerado;
    
    @Temporal(TemporalType.DATE)
    private Date creation_date;
    private Long created_by;

    public AnaliseLinesEntity() {}

    public AnaliseLinesEntity(Long analise_lines_id, AnaliseEntity analiseHeader, String modelo, 
                              String metodo, Double min_ice, Double melhor_contrib, Double melhor_alcance, 
                              Double melhor_val_kappa, Double erro_medio, Double dp_erro_medio, Double isi,
                              Date creation_date, Long created_by, Long mapa_gerado,Double nugget) {
        this.analise_lines_id = analise_lines_id;
        this.analiseHeader = analiseHeader;
        this.modelo = modelo;
        this.metodo = metodo;
        this.min_ice = min_ice;
        this.melhor_contrib = melhor_contrib;
        this.melhor_alcance = melhor_alcance;
        this.melhor_val_kappa = melhor_val_kappa;
        this.erro_medio = erro_medio;
        this.dp_erro_medio = dp_erro_medio;
        this.isi = isi;
        this.creation_date = creation_date;
        this.created_by = created_by;
        this.mapa_gerado = mapa_gerado;
        this.nugget = nugget;
    }

    public AnaliseEntity getAnaliseHeader() {
        return analiseHeader;
    }

    public void setAnaliseHeader(AnaliseEntity analiseHeader) {
        this.analiseHeader = analiseHeader;
    }

    public Long getAnalise_lines_id() {
        return analise_lines_id;
    }

    public void setAnalise_lines_id(Long analise_lines_id) {
        this.analise_lines_id = analise_lines_id;
    }

    public String getModelo() {
        return modelo;
    }
    
    public Double getNugget() {
		return nugget;
	}
    
    public void setNugget(Double nugget) {
		this.nugget = nugget;
	}

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }

    public String getMetodo() {
        return metodo;
    }

    public void setMetodo(String metodo) {
        this.metodo = metodo;
    }

    public Double getMin_ice() {
        return min_ice;
    }

    public void setMin_ice(Double min_ice) {
        this.min_ice = min_ice;
    }

    public Double getMelhor_contrib() {
        return melhor_contrib;
    }

    public void setMelhor_contrib(Double melhor_contrib) {
        this.melhor_contrib = melhor_contrib;
    }

    public Double getMelhor_alcance() {
        return melhor_alcance;
    }

    public void setMelhor_alcance(Double melhor_alcance) {
        this.melhor_alcance = melhor_alcance;
    }

    public Double getMelhor_val_kappa() {
        return melhor_val_kappa;
    }

    public void setMelhor_val_kappa(Double melhor_val_kappa) {
        this.melhor_val_kappa = melhor_val_kappa;
    }

    public Double getErro_medio() {
        return erro_medio;
    }

    public void setErro_medio(Double erro_medio) {
        this.erro_medio = erro_medio;
    }

    public Double getDp_erro_medio() {
        return dp_erro_medio;
    }

    public void setDp_erro_medio(Double dp_erro_medio) {
        this.dp_erro_medio = dp_erro_medio;
    }

    public Double getIsi() {
        return isi;
    }

    public void setIsi(Double isi) {
        this.isi = isi;
    }

    public Date getCreation_date() {
        return creation_date;
    }

    public void setCreation_date(Date creation_date) {
        this.creation_date = creation_date;
    }

    public Long getCreated_by() {
        return created_by;
    }

    public void setCreated_by(Long created_by) {
        this.created_by = created_by;
    }    

    public void setMapa_gerado(Long mapa_gerado) {
        this.mapa_gerado = mapa_gerado;
    }

    public Long getMapa_gerado() {
        return mapa_gerado;
    }

   
  

    
    
    
}
