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

  def search(terms, region \\ :all, category \\ :annonces) when category in @categories do
    query = URI.encode_query(%{"q" => terms})
    str_category = to_string(category)
    str_region = to_string(region)
    url = "#{@base_site}/#{str_category}/offres/#{str_region}/"
    full_url = "#{url}?#{query}"

    case HTTPoison.get(full_url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.inspect Lbcparser.parse(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

end
