require 'spec_helper'

describe 'users/description/show.html.haml', type: :view do
  let(:user) { create(:user) }
  let(:dossier) { create(:dossier, :with_procedure, user: user) }
  let(:dossier_id) { dossier.id }

  before do
    assign(:dossier, dossier)
    assign(:procedure, dossier.procedure)
  end

  context 'tous les attributs sont présents sur la page' do
    before do
      render
    end
    it 'Le formulaire envoie vers /users/dossiers/:dossier_id/description en #POST' do
      expect(rendered).to have_selector("form[action='/users/dossiers/#{dossier_id}/description'][method=post]")
    end

    it 'Nom du projet' do
      expect(rendered).to have_selector('input[id=nom_projet][name=nom_projet]')
    end

    it 'Description du projet' do
      expect(rendered).to have_selector('textarea[id=description][name=description]')
    end

    it 'Montant du projet' do
      expect(rendered).to have_selector('input[id=montant_projet][name=montant_projet]')
    end

    it 'Montant du projet est de type number' do
      expect(rendered).to have_selector('input[type=number][id=montant_projet]')
    end

    it 'Montant des aides du projet' do
      expect(rendered).to have_selector('input[id=montant_aide_demande][name=montant_aide_demande]')
    end

    it 'Montant des aides du projet est de type number' do
      expect(rendered).to have_selector('input[type=number][id=montant_aide_demande]')
    end

    it 'Date prévisionnelle du projet' do
      expect(rendered).to have_selector('input[id=date_previsionnelle][name=date_previsionnelle]')
    end

    it 'Date prévisionnelle du projet est de type text avec un data-provide=datepicker' do
      expect(rendered).to have_selector('input[type=text][id=date_previsionnelle][data-provide=datepicker]')
    end

    it 'Charger votre CERFA (PDF)' do
      expect(rendered).to have_selector('input[type=file][name=cerfa_pdf][id=cerfa_pdf]')
    end

    it 'Lien CERFA' do
      expect(rendered).to have_selector('#lien_cerfa')
    end
  end

  context 'si la page précédente n\'est pas recapitulatif' do
    before do
      render
    end
    it 'le bouton "Terminer" est présent' do
      expect(rendered).to have_selector('#suivant')
    end
  end

  context 'si la page précédente est recapitularif' do
    before do
      dossier.initiated!
      dossier.reload
      render
    end

    it 'le bouton "Terminer" n\'est pas présent' do
      expect(rendered).to_not have_selector('#suivant')
    end

    it 'le bouton "Modification terminé" est présent' do
      expect(rendered).to have_selector('#modification_terminee')
    end

    it 'le lien de retour au récapitulatif est présent' do
      expect(rendered).to have_selector("a[href='/users/dossiers/#{dossier_id}/recapitulatif']")
    end
  end

  context 'les valeurs sont réaffichées si elles sont présentes dans la BDD' do
    let!(:dossier) do
      create(:dossier, :with_procedure,
             nom_projet: 'Projet de test',
             description: 'Description de test',
             montant_projet: 12_000,
             montant_aide_demande: 3000,
             date_previsionnelle: '20/01/2016',
             user: user)
    end

    before do
      render
    end


    it 'Nom du projet' do
      expect(rendered).to have_selector("input[id=nom_projet][value='#{dossier.nom_projet}']")
    end

    it 'Description du projet' do
      expect(rendered).to have_content("#{dossier.description}")
    end

    it 'Montant du projet' do
      expect(rendered).to have_selector("input[id=montant_projet][value='#{dossier.montant_projet}']")
    end

    it 'Montant des aides du projet' do
      expect(rendered).to have_selector("input[id=montant_aide_demande][value='#{dossier.montant_aide_demande}']")
    end

    it 'Date prévisionnelle du projet' do
      expect(rendered).to have_selector("#date_previsionnelle", dossier.date_previsionnelle)
    end
  end

  context 'Pièces justificatives' do
    let(:all_type_pj_procedure_id) { dossier.procedure.type_de_piece_justificative_ids }

    before do
      render
    end

    context 'la liste des pièces justificatives a envoyé est affichée' do
      it 'RIB' do
        expect(rendered).to have_css("#piece_justificative_#{all_type_pj_procedure_id[0]}")
      end
    end

    context 'la liste des pièces récupérées automatiquement est signaliée' do
      it 'Attestation MSA' do
        expect(rendered).to have_selector("#piece_justificative_#{all_type_pj_procedure_id[1]}","Nous l'avons récupéré pour vous.")
      end
    end
  end
end
