defmodule Lbcproxy do

  @base_site "http://www.leboncoin.fr"
  @categories [:annonces, :offres_d_emploi, :voitures, :motos, :caravaning,
               :utilitaires, :equipement_auto, :equipement_moto,
               :equipement_caravaning, :nautisme, :equipement_nautisme,
               :ventes_immobilieres, :locations, :colocations,
               :bureaux_commerces, :locations_gites, :chambres_d_hotes,
               :campings, :hotels, :hebergements_insolites, :informatique,
               :consoles_jeux_video, :image_son, :telephonie, :ameublement,
               :electromenager, :arts_de_la_table, :decoration,
               :linge_de_maison, :bricolage, :jardinage, :vetements,
               :chaussures, :accessoires_bagagerie, :montres_bijoux,
               :equipement_bebe, :vetements_bebe, :dvd_films, :cd_musique,
               :livres, :animaux, :velos, :sports_hobbies,
               :instruments_de_musique, :collection, :jeux_jouets,
               :vins_gastronomie, :materiel_agricole, :transport_manutention,
               :btp_chantier_gros_oeuvre, :outillage_materiaux_2nd_oeuvre,
               :equipements_industriels, :restauration_hotellerie,
               :fournitures_de_bureau, :commerces_marches, :materiel_medical,
               :prestations_de_services, :billetterie, :evenements,
               :cours_particuliers, :covoiturage, :autres]

  @regions [:alsace, :aquitaine, :auvergne, :basse_normandie, :bourgogne,
            :bretagne, :centre, :champagne_ardenne, :corse, :franche_comte,
            :haute_normandie, :ile_de_france, :languedoc_roussillon,
            :limousin, :lorraine, :midi_pyrenees, :nord_pas_de_calais,
            :pays_de_la_loire, :picardie, :poitou_charentes, :provence_alpes_cote_d_azur,
            :rhone_alpes, :guadeloupe, :martinique, :guyane, :reunion]

  def all_categories do
    @categories
  end

  def all_regions do
    @regions
  end

  def search(terms, region \\ :all, category \\ :annonces) when category in @categories do
    url = make_url(terms, region, category)

    Stream.resource(fn -> 1 end,
                    fn page ->
                      case get(make_url(url, page)) do
                        [] -> {:halt, page}
                        data when is_list(data) -> {data, page+1}
                        _ -> {:halt, page}
                      end
                    end,
                    fn _page -> end)
  end

  defp get(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Lbcparser.parse(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
        []
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
        []
    end
  end

  defp make_url(terms, region, category) do
    str_category = to_string(category)
    str_region = make_region(region)
    query = URI.encode_query(%{"q" => terms})
    url = "#{@base_site}/#{str_category}/offres/#{str_region}/"
    "#{url}?#{query}"
  end
  defp make_url(url, page) do
    "#{url}&o=#{page}"
  end

  defp make_region(:all) do
    "ile_de_france/occasions"
  end
  defp make_region(region) do
    to_string(region)
  end

end
