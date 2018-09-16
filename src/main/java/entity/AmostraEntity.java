/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package entity;

import java.util.Date;
import java.util.List;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import utils.BaseBean;

/**
 *
 * @author Dallagnol
 */
@Entity
@Table(name = "amostra")
public class AmostraEntity extends BaseBean {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	@Id
    @SequenceGenerator(name = "amostra_codigo_seq", sequenceName = "amostra_codigo_seq", allocationSize = 1)
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "amostra_codigo_seq")
    private Long codigo;
    private Date data;
    private String descricao;
    private Long area_codigo;
    private Long atributo_codigo;
    private Long usuario_codigo;
    private String nomedatabela;

    @OneToMany(mappedBy = "amostra")
    private List<AnaliseEntity> analises;

    public AmostraEntity() {
    }

    public AmostraEntity(Long codigo, Date data, String descricao, Long area_codigo, Long atributo_codigo, Long usuario_codigo, List<AnaliseEntity> analises,String nomedatabela) {
        this.codigo = codigo;
        this.data = data;
        this.descricao = descricao;
        this.area_codigo = area_codigo;
        this.atributo_codigo = atributo_codigo;
        this.usuario_codigo = usuario_codigo;
        this.analises = analises;
        this.nomedatabela = nomedatabela;
    }

    public Long getCodigo() {
        return codigo;
    }

    public void setCodigo(Long codigo) {
        this.codigo = codigo;
    }

    public Date getData() {
        return data;
    }

    public void setData(Date data) {
        this.data = data;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public Long getArea_codigo() {
        return area_codigo;
    }

    public void setArea_codigo(Long area_codigo) {
        this.area_codigo = area_codigo;
    }

    public Long getAtributo_codigo() {
        return atributo_codigo;
    }

    public void setAtributo_codigo(Long atributo_codigo) {
        this.atributo_codigo = atributo_codigo;
    }

    public Long getUsuario_codigo() {
        return usuario_codigo;
    }

    public void setUsuario_codigo(Long usuario_codigo) {
        this.usuario_codigo = usuario_codigo;
    }

    public List<AnaliseEntity> getAnalises() {
        return analises;
    }

    public void setAnalises(List<AnaliseEntity> analises) {
        this.analises = analises;
    }
    
    public String getNomedatabela() {
		return nomedatabela;
	}
    public void setNomedatabela(String nomedatabela) {
		this.nomedatabela = nomedatabela;
	}

}
