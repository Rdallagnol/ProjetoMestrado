/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package entity;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Transient;

import org.geotools.geojson.geom.GeometryJSON;

import com.vividsolutions.jts.geom.Geometry;


@Entity
@Table(name = "pixelamostra")
public class PixelAmostraEntity implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = -548529663458912740L;
	@Id
	@SequenceGenerator(name = "pixelamostra_codigo_seq", sequenceName = "pixelamostra_codigo_seq", allocationSize = 1)
	@GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "pixelamostra_codigo_seq")
	private Long codigo;
	private Long amostra_codigo;
	private String valor_x;
	private String valor_y;
	private String valor;
	@Column(name = "geometry")
	private Geometry geometry;

	@Transient
	private String geom;
	
	public Long getCodigo() {
		return codigo;
	}

	public void setCodigo(Long codigo) {
		this.codigo = codigo;
	}

	public Long getAmostra_codigo() {
		return amostra_codigo;
	}

	public void setAmostra_codigo(Long amostra_codigo) {
		this.amostra_codigo = amostra_codigo;
	}

	public String getValor_x() {
		return valor_x;
	}

	public void setValor_x(String valor_x) {
		this.valor_x = valor_x;
	}

	public String getValor_y() {
		return valor_y;
	}

	public void setValor_y(String valor_y) {
		this.valor_y = valor_y;
	}

	public String getValor() {
		return valor;
	}

	public void setValor(String valor) {
		this.valor = valor;
	}

	public Geometry getGeometry() {
		return geometry;
	}

	public void setGeometry(Geometry geometry) {
		this.geometry = geometry;
	}

	public String getGeom() {
		if (this.getGeometry() != null) {
			GeometryJSON g = new GeometryJSON();
			this.setGeom("{" + '"' + "type" + '"' + ":" + '"' + "Feature" + '"' + "," + '"' + "geometry" + '"' + ":"
					+ g.toString(this.getGeometry()) + "}");
			return geom;
		}
		return geom;
	}

	public void setGeom(String geom) {
		this.geom = geom;
	}
}
