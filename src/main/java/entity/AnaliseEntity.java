/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package entity;

import java.io.Serializable;
import java.util.Date;
import java.util.List;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.validation.constraints.NotNull;


/**
 *
 * @author Dallagnol
 */
@Entity
@Table(name = "geo_analise_header")
public class AnaliseEntity implements Serializable {

    /**
	 * 
	 */
	private static final long serialVersionUID = -6814440438895531933L;

	@Id
    @SequenceGenerator(name = "geo_analise_header_seq", sequenceName = "geo_analise_header_seq", allocationSize = 1)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "geo_analise_header_seq")
    private Long analise_header_id;

    @Temporal(TemporalType.DATE)
    private Date creation_date;
    private Long created_by;
    
    @NotNull
    private String descricao_analise;
    private String tipo_analise;
    private String status;

    @OneToMany(mappedBy = "analiseHeader")
    private List<AnaliseLinesEntity> analisesLines;

    @ManyToOne
    @JoinColumn(name = "area_id")
    private AreaEntity area;

    @ManyToOne
    @NotNull
    @JoinColumn(name = "amostra_id")
    private AmostraEntity amostra;

    public AnaliseEntity() {
    }

    public AnaliseEntity(Long analise_header_id, Date creation_date, Long created_by, String descricao_analise, String status, List<AnaliseLinesEntity> analisesLines, AreaEntity area, AmostraEntity amostra, String tipo_analise) {
        this.analise_header_id = analise_header_id;
        this.creation_date = creation_date;
        this.created_by = created_by;
        this.descricao_analise = descricao_analise;
        this.status = status;
        this.analisesLines = analisesLines;
        this.area = area;
        this.amostra = amostra;
        this.tipo_analise = tipo_analise;
    }

    public AmostraEntity getAmostra() {
        return amostra;
    }

    public void setAmostra(AmostraEntity amostra) {
        this.amostra = amostra;
    }

    public List<AnaliseLinesEntity> getAnalisesLines() {
        return analisesLines;
    }

    public void setAnalisesLines(List<AnaliseLinesEntity> analisesLines) {
        this.analisesLines = analisesLines;
    }

    public AreaEntity getArea() {
        return area;
    }

    public void setArea(AreaEntity area) {
        this.area = area;
    }

    public Long getAnalise_header_id() {
        return analise_header_id;
    }

    public void setAnalise_header_id(Long analise_header_id) {
        this.analise_header_id = analise_header_id;
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

    public String getDescricao_analise() {
        return descricao_analise;
    }

    public void setDescricao_analise(String descricao_analise) {
        this.descricao_analise = descricao_analise;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

	public String getTipo_analise() {
		return tipo_analise;
	}

	public void setTipo_analise(String tipo_analise) {
		this.tipo_analise = tipo_analise;
	}

}
