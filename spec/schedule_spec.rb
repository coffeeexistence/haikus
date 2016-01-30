describe "Schedule" do
  include Shoulda::Whenever

  let(:whenever) { Whenever::JobList.new(file: File.join(Rails.root, "config", "schedule.rb").to_s) }

  it "runs a rake task to remove old uuids every day at 12am" do
    expect(whenever).to schedule_command("db:remove_old_uuids").every(1.day).at("12:00 AM")
  end
end
