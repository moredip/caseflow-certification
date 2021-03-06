describe Form8 do
  context "#representative" do
    let(:form8) { Form8.new }
    subject { form8.representative }
    before { form8.representative_name = "Joe" }

    context "when representative_type isn't other" do
      before { form8.representative_type = "Appeal" }
      it { is_expected.to eq "Joe - Appeal" }
    end

    context "when representative_type is other" do
      before do
        form8.representative_type = "Other"
        form8.representative_type_specify_other = "Bossman"
      end
      it { is_expected.to eq "Joe - Bossman" }
    end
  end

  context "remarks rolls over" do
    let(:appeal) { Form8.new(remarks: "Hello, World") }

    it "rolls over remarks properly" do
      expect(appeal.remarks).to eq("Hello, World")

      expect(appeal.remarks_rollover?).to be_falsey
      expect(appeal.remarks_initial).to eq("Hello, World")
      expect(appeal.remarks_continued).to be_nil

      appeal.remarks = "A" * 200 + "Hello, World!"

      expect(appeal.remarks_rollover?).to be_truthy
      expect(appeal.remarks_initial).to eq("A" * 159 + " (see continued remarks page 2)")
      expect(appeal.remarks_continued).to eq("\n\nContinued:\n" + ("A" * 41) + "Hello, World!")
    end
  end

  context ".from_appeal" do
    before do
      Timecop.freeze
    end

    after do
      Timecop.return
    end

    let(:appeal) do
      Appeal.new(
        vacols_id: "VACOLS-ID",
        vbms_id: "VBMS-ID",
        appellant_first_name: "Micah",
        appellant_last_name: "Bobby",
        appellant_relationship: "Brother",
        veteran_first_name: "Shane",
        veteran_last_name: "Bobby",
        nod_date: 3.days.ago,
        soc_date: 2.days.ago,
        form9_date: 1.day.ago,
        insurance_loan_number: "1337"
      )
    end

    it "creates new form8 with values copied over correctly" do
      form8 = Form8.from_appeal(appeal)

      expect(form8).to have_attributes(
        vacols_id: "VACOLS-ID",
        appellant_name: "Micah, Bobby",
        appellant_relationship: "Brother",
        file_number: "VBMS-ID",
        veteran_name: "Bobby, Shane",
        insurance_loan_number: "1337",
        service_connection_nod_date: 3.days.ago,
        increased_rating_nod_date: 3.days.ago,
        other_nod_date: 3.days.ago,
        soc_date: 2.days.ago,
        certification_date: Time.zone.now
      )
    end
  end
end
