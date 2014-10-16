require 'spec_helper'

describe 'StreamRails::Renderable' do

  describe ":render" do

    before do
      @actionview = double('actionview')
    end

    it "picks the template based on the verb" do
      activity = StreamRails::ActivityResult.new().from_activity({"verb"=> "like"})
      @actionview.should_receive(:render).with({:partial=>"activity/like", :locals=>{:activity=>activity, :parameters=>{}}})
      StreamRails::Renderable.render(activity, @actionview)
    end

    it "should be able to change partial_root" do
      activity = StreamRails::ActivityResult.new().from_activity({"verb"=> "like"})
      @actionview.should_receive(:render).with({:partial=>"custom/like", :partial_root=>"custom", :locals=>{:activity=>activity, :parameters=>{:partial_root=>"custom"}}})
      StreamRails::Renderable.render(activity, @actionview, {:partial_root=>'custom'})
    end

    it "should be able to send extra context" do
      activity = StreamRails::ActivityResult.new().from_activity({"verb"=> "like"})
      @actionview.should_receive(:render).with({:partial=>"activity/like", :tommaso=>1, :locals=>{:activity=>activity, :parameters=>{:tommaso=>1}}})
      StreamRails::Renderable.render(activity, @actionview, {:tommaso=>1})
    end
  end

end
