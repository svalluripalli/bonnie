namespace :bonnie do
  namespace :qrda do

    desc %{Export patient records as QRDA.

    You must identify the user by EMAIL:

    $ rake bonnie:qrda:export_for_user EMAIL=xxx}
    task :export_for_user => :environment do
      hds_patient_converter = CQM::Converter::HDSRecord.new
      user = User.find_by email: ENV['EMAIL']

      hds_records = Record.where(user: user)

      Zip::ZipOutputStream.open("tmp/#{user.first_name}_#{user.last_name}.zip") do |z|
        options = { start_time: APP_CONFIG['measure_period_start'], end_time: APP_CONFIG['measure_period_end'] }
        hds_records.each_with_index do |hds_record, i|
        	qdm_record = hds_patient_converter.to_qdm(hds_record)
        	cqm_patient = CQMPatient.new(givenNames: qdm_record.givenNames, familyName: qdm_record.familyName, qdmPatient: qdm_record)
        	
          safe_first_name = cqm_patient.givenNames.join(' ').delete("'")
          safe_last_name = cqm_patient.familyName.delete("'")
          entry_path = "#{i}_#{safe_first_name}_#{safe_last_name}"
          z.put_next_entry("#{entry_path}.xml")
          # TODO: R2P: make sure using correct exporter
          z << Qrda1R5.new(cqm_patient, CqlMeasure.where(user: user), options).render
        end
      end
      puts "#{ENV['EMAIL']} is now has #{hds_records.size} QRDA."
    end
  end
end