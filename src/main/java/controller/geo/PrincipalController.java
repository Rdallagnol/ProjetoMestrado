/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package controller.geo;

import br.com.caelum.vraptor.Controller;
import br.com.caelum.vraptor.Get;
import br.com.caelum.vraptor.Path;
import br.com.caelum.vraptor.Result;
import br.com.caelum.vraptor.observer.upload.UploadedFile;
import br.com.caelum.vraptor.view.Results;
import config.Constantes;
import dao.AmostraDao;

import entity.AmostraEntity;
import entity.AnaliseEntity;
import entity.AnaliseLinesEntity;

import entity.AreaEntity;
import entity.PixelAmostraEntity;
import utils.DaoFactory;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.text.DecimalFormat;

import java.util.Date;
import java.util.List;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;

import javax.servlet.http.HttpServletRequest;

import org.geotools.geometry.jts.JTSFactoryFinder;

import com.vividsolutions.jts.geom.GeometryFactory;

import com.vividsolutions.jts.io.WKTReader;

/**
 *
 * @author Dallagnol
 */
@Controller
@RequestScoped
public class PrincipalController implements Serializable {

	private static final long serialVersionUID = 6770785282469692484L;

	@Inject
	private Result result;

	@Inject
	private HttpServletRequest request;

	private static int projection = 4326;
     
	@Path("/")
	public void index() {
		// System.out.println(request.getServletContext().getRealPath("/file")); 
		System.out.println(request.getServletContext().getRealPath("/scripts/R/Principal/script_geo.r") + " ");
	}

	@Path("/funcaoGeo")
	public void funcaoGeo() {

		result.include("areas", DaoFactory.areaDaoInstance().findAll());
		// System.out.println(request.getServletContext().getRealPath("/file"));
		if (request.getMethod().equals("POST")) {
			try {
				
				System.out.println(Constantes.ENDERECO_R);
				
				Process process = Runtime.getRuntime().exec(Constantes.ENDERECO_R
						+ request.getServletContext().getRealPath("/scripts/R/Principal/script_geo.r") + " "
						+ request.getServletContext().getRealPath("/file") + " " + Constantes.DATA_BASE_NAME + " "
						+ Constantes.DATA_BASE_HOST + " " + Constantes.DATA_BASE_USER + " "
						+ Constantes.DATA_BASE_PASSWORD + " " + Constantes.DATA_BASE_PORT + " "
						+ request.getParameter("user") + " " + request.getParameter("area") + " "
						+ request.getParameter("amostra") + " " + '"' + request.getParameter("desc") + '"' + " "
						+ request.getParameter("isi") + " " + request.getParameter("v_lambda") + " "
						+ request.getParameter("auto_lags") + " " + request.getParameter("nro_lags") + " "
						+ request.getParameter("estimador") + " " + request.getParameter("cutoff") + " "
						+ request.getParameter("tamx") + " " + request.getParameter("tamy") + " "
						+ request.getParameter("nro_intervalos_alc") + " "
						+ request.getParameter("nro_intervalos_contr") + " " + request.getParameter("nro_pares") + " "
						+ request.getParameter("nro_min_contr") + " " + request.getParameter("nro_min_alc") + " ");

				try {
					String ok = null;

					BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
					String line = null;

					while ((line = reader.readLine()) != null) {
						System.out.println(line);
						if (line.equals("[1] 9999")) {
							ok = "OK";
						}
					}

					if (ok != null) {
						result.redirectTo(this).visualizaGeo();
					} else {
						result.include("errorMsg", "Could not perform analysis please check data !");
					}
				} catch (final IOException e) {
					e.printStackTrace();
				}
			} catch (IOException e1) {
				e1.printStackTrace();
			}

		}
	}

	@Path("/funcaoKrigagem")
	public void funcaoKrigagem() {

		if (request.getMethod().equals("POST")) {
			try {

				Process process = Runtime.getRuntime()
						.exec(Constantes.ENDERECO_R
								+ request.getServletContext().getRealPath("/scripts/R/Principal/script_krig.r") + " "
								+ request.getServletContext().getRealPath("/mapa") + " " + Constantes.DATA_BASE_NAME
								+ " " + Constantes.DATA_BASE_HOST + " " + Constantes.DATA_BASE_USER + " "
								+ Constantes.DATA_BASE_PASSWORD + " " + Constantes.DATA_BASE_PORT + " "
								+ request.getParameter("user") + " " + request.getParameter("analise_line_id") + " ");

				try {
					final BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
					String line = null;
					String ok = null;
					while ((line = reader.readLine()) != null) {
						// System.out.println(line);
						if (line.equals("[1] 9999")) {
							ok = "OK";
						}
					}
					reader.close();
					if (ok != null) {
						result.redirectTo(this).visualizaMapa(Long.parseLong(request.getParameter("analise_line_id")));
					} else {
						result.include("errorMsg", "Could not perform analysis please check data !");
					}
				} catch (final Exception e) {
					e.printStackTrace();
				}
			} catch (IOException e1) {
				e1.printStackTrace();
			}

		}
	}

	@Path("/funcaoIdw")
	public void funcaoIdw() {

		result.include("areas", DaoFactory.areaDaoInstance().findAll());

		// System.out.println(request.getMethod());
		if (request.getMethod().equals("POST")) {

			try {

				Process process = Runtime.getRuntime()
						.exec(Constantes.ENDERECO_R
								+ request.getServletContext().getRealPath("/scripts/R/Principal/script_idw.r") + " "
								+ request.getServletContext().getRealPath("/mapa") + " " + Constantes.DATA_BASE_NAME
								+ " " + Constantes.DATA_BASE_HOST + " " + Constantes.DATA_BASE_USER + " "
								+ Constantes.DATA_BASE_PASSWORD + " " + Constantes.DATA_BASE_PORT + " "
								+ request.getParameter("user") + " " + request.getParameter("area") + " "
								+ request.getParameter("amostra") + " " + request.getParameter("expoente") + " "
								+ request.getParameter("vizinhos") + " "
								// + request.getParameter("expoini") + " "
								// + request.getParameter("expofinal") + " "
								// + request.getParameter("expoint") + " "
								+ request.getParameter("raio") + " " + request.getParameter("tamx") + " "
								+ request.getParameter("tamy") + " " + request.getParameter("desc") + " ");

				try {
					final BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
					String line = null;
					String ok = null;
					while ((line = reader.readLine()) != null) {
						// System.out.println(line);
						if (line.equals("[1] 9999")) {
							ok = "OK";
						}
					}
					reader.close();
					if (ok != null) {
						result.redirectTo(this).visualizaIdw();
					} else {
						result.include("errorMsg", "Could not perform analysis please check data !");
					}
				} catch (final Exception e) {
					e.printStackTrace();
				}
			} catch (IOException e1) {
				e1.printStackTrace();
			}

		}
	}

	@Get("/buscaAmostrasDaArea")
	public void buscaAmostrasDaArea(Long idArea) {
		AmostraDao amostraDao = DaoFactory.amostraDaoInstance();
		List<AmostraEntity> amostras = amostraDao.findByIdArea(idArea);
		result.use(Results.json()).withoutRoot().from(amostras).serialize();
	}
 
	@Path("/visualizaGeo")
	public void visualizaGeo() {

		result.include("analises", DaoFactory.analiseInstance().findAllOrdenado("KRIG"));

		// result.use(Results.xml()).from(DaoFactory.analiseLineInstance().findByAnaliseHeader(675L)).serialize();

		if (request.getMethod().equals("POST")) {

			List<AnaliseEntity> analise = DaoFactory.analiseInstance()
					.findById(Long.parseLong(request.getParameter("analiseId")));

			AnaliseEntity a = new AnaliseEntity();

			for (AnaliseEntity analiseEntity : analise) {
				a = analiseEntity;
			}

			DaoFactory.analiseLineInstance().getEntityManager().clear(); /* Necessário */

			result.include("analiseLines", DaoFactory.analiseLineInstance()
					.findByAnaliseHeader(Long.parseLong(request.getParameter("analiseId"))));

			result.include("analise", a);

		}
	}

	@Get("/visualizaMapa/{i}")
	public void visualizaMapa(Long i) {

		Double IDE;
		String IDEdesc;

		List<AnaliseLinesEntity> l = DaoFactory.analiseLineInstance().findAnaliseLine(i);

		AnaliseLinesEntity a = new AnaliseLinesEntity();

		for (AnaliseLinesEntity analiseLine : l) {
			a = analiseLine;

		}

		IDE = (a.getNugget() / (a.getNugget() + a.getMelhor_contrib())) * 100;

		if (IDE <= 25) {
			IDEdesc = "Alta";
		} else if (IDE > 75) {
			IDEdesc = "Baixa";
		} else {
			IDEdesc = "Moderada";
		}

		result.include("analise", a);
		result.include("userID", 872);

		DecimalFormat df = new DecimalFormat("0.00");
		String r = df.format(IDE);

		result.include("IDE", r);
		result.include("IDEdesc", IDEdesc);

	}

	@Path("/visualizaIdw")
	public void visualizaIdw() {

		result.include("analises", DaoFactory.analiseInstance().findAllOrdenado("IDW"));

		// result.use(Results.xml()).from(DaoFactory.analiseInstance().findAllOrdenado()).serialize();

		if (request.getMethod().equals("POST")) {

			List<AnaliseEntity> analise = DaoFactory.analiseInstance()
					.findById(Long.parseLong(request.getParameter("analiseId")));

			AnaliseEntity a = new AnaliseEntity();
			for (AnaliseEntity analiseEntity : analise) {
				a = analiseEntity;
			}

			result.include("analise", a);

		}
	}

	@Path("/visuList")
	public void visuList() {

		result.use(Results.xml()).from(DaoFactory.analiseLineInstance().findByAnaliseHeader(Long.parseLong("628")))
				.serialize();
	}

	@Path("/cadAmostra")
	public void cadAmostra(AmostraEntity amostra, UploadedFile uploadedFile) {

		result.include("areas", DaoFactory.areaDaoInstance().findAll());

		if (request.getMethod().equals("POST")) {

			amostra.setData(new Date());
			amostra.setArea_codigo(Long.parseLong(request.getParameter("area")));
			amostra.setNomedatabela("pixelamostra");
			amostra.setAtributo_codigo(1L);
			amostra.setUsuario_codigo(1L);
			amostra.setDescricao(request.getParameter("descricao"));

			try {
				DaoFactory.amostraDaoInstance().adiciona(amostra);

				result.include("mensagemOK", "Registered successfully !");
			} catch (Exception e) {
				result.include("errorMsg", "Error registering field !");
			}

			GeometryFactory geometryFactory = JTSFactoryFinder.getGeometryFactory(null);
			WKTReader reader = new WKTReader(geometryFactory);

			
			try {
				BufferedReader in = new BufferedReader(new InputStreamReader(uploadedFile.getFile(), "UTF8"));

				in.readLine();

				String ponto = "";
				while ((ponto = in.readLine()) != null) {

					String[] valores = ponto.split("\t");

					if (valores.length == 3) {

						PixelAmostraEntity pa = new PixelAmostraEntity();

						pa.setAmostra_codigo(1L);

						pa.setGeometry(reader.read("POINT(" + valores[0] + " " + valores[1] + ")"));

						if (valores[2] != null || (!valores[2].equals("null"))) {
							pa.setValor(valores[2]);
						} else {
							pa.setValor("0");
						}

						pa.getGeometry().setSRID(projection);
						pa.setValor_x(valores[0]);
						pa.setValor_y(valores[1]);
						
						pa.setAmostra_codigo(amostra.getCodigo());

						DaoFactory.pixelAmostraDaoInstance().adiciona(pa);

					}
				}
				in.close();

			} catch (Exception e) {
			}

			result.redirectTo(this).cadAmostra(null, null);
		}
	}

	@Path("/cadArea")
	public void cadArea(AreaEntity area, UploadedFile uploadedFile) {

		if (request.getMethod().equals("POST")) {

			System.out.println(request.getParameter("nome"));

			GeometryFactory geometryFactory = JTSFactoryFinder.getGeometryFactory(null);
			WKTReader reader = new WKTReader(geometryFactory);

			String poligono = "POLYGON((";

			BufferedReader s;
			try {
				s = new BufferedReader(new InputStreamReader(uploadedFile.getFile(), "UTF8"));
				s.readLine();

				String[] parts = s.readLine().split("\t");

				if (parts.length >= 2) {
					String first = parts[0] + " " + parts[1];
					poligono += first + ", ";
					String contornoP = null;
					while ((contornoP = s.readLine()) != null) {

						parts = contornoP.split("\t");

						if (parts.length >= 2) {

							poligono += parts[0] + " " + parts[1];

							poligono += ", ";
						}
					}

					poligono += first;
					poligono += "))";

					area.setGeometry(reader.read(poligono));
					area.getGeometry().setSRID(projection);
					area.setNome(request.getParameter("nome"));
					area.setTamanho(Float.valueOf(request.getParameter("tamanho")));

					DaoFactory.areaDaoInstance().adiciona(area);
				}
				result.include("mensagemOK", "Registered successfully !");
			} catch (Exception e) {
				result.include("errorMsg", "Error registering field !");
			}

			System.out.println(poligono);
			result.redirectTo(this).cadArea(null, null);
		}
	}
	
	
	public void listaAmostra(){
		
	}

}
