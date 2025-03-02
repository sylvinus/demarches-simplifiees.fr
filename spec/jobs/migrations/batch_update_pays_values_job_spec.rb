describe Migrations::BatchUpdatePaysValuesJob, type: :job do
  let(:procedure) { create(:procedure, :published, types_de_champ_public:) }
  let(:types_de_champ_public) { [{ type: :pays, mandatory: }] }
  let(:dossier) { create(:dossier, :with_populated_champs, procedure:) }
  let(:pays_champ) { dossier.champs.first }
  let(:mandatory) { true }
  before { pays_champ.update_columns(attributes) }
  subject { described_class.perform_now([pays_champ.id]) }

  context "the value is correct" do
    let(:attributes) { { value: 'France', external_id: 'FR' } }

    it 'does not change it' do
      subject
      expect(pays_champ.reload.value).to eq('France')
      expect(pays_champ.reload.external_id).to eq('FR')
    end
  end

  context "the value is incorrect" do
    let(:attributes) { { value: 'Incorrect' } }
    let(:mandatory) { false }

    it 'updates value to nil' do
      subject
      expect(pays_champ.reload.value).to be_nil
      expect(pays_champ.reload.external_id).to be_nil
    end
  end

  context "the value is easily cleanable" do
    let(:attributes) { { value: 'Vietnam' } }

    it 'cleans the value' do
      subject
      expect(pays_champ.reload.value).to eq('Viêt Nam')
      expect(pays_champ.reload.external_id).to eq('VN')
    end
  end

  context "the value is hard to clean" do
    let(:attributes) { { value: 'CHRISTMAS (ILE)' } }

    it 'cleans the value' do
      subject
      expect(pays_champ.reload.value).to eq('Christmas, Île')
      expect(pays_champ.reload.external_id).to eq('CX')
    end
  end
end
