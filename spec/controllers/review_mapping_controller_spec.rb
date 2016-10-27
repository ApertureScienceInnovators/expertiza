require 'rails_helper'
include LogInHelper

RSpec.describe ReviewMappingController, type: :controller do
  context "user not logged in" do
    # user not logged in
    describe "GET #new_feedback" do
      it "returns http success" do
        allow(Response).to receive(:find)
        get :new_feedback
        expect(response).to redirect_to request.env['HTTP_REFERER'] ? :back : :root
      end
    end
  end

  context 'logged in as student' do
    let(:review) { Response.create(map_id: 1, additional_comment: 'hello', round: 1) }
    let(:map) { FeedbackResponseMap.create(reviewed_object_id: 1, reviewer_id: 1, reviewee_id: 1) }
    let(:assignment) { AssignmentParticipant.new }
    let(:responsemap) { ResponseMap.new }
    before(:each) do
      student.save
      @user = User.find_by(name: 'student')
      @role = double('role', super_admin?: false)
      stub_current_user(@user, 'Student', @role)
    end

    describe "GET #new_feedback" do
      it "redirects to new if review object is found" do
        allow(Response).to receive(:find).and_return(review)
        allow(session[:user]).to receive(:id).and_return(1)
        allow(review).to receive_message_chain(:map, :assignment, :id).and_return(1)
        allow(review).to receive_message_chain(:map, :reviewer, :id).and_return(1)
        allow_any_instance_of(AssignmentParticipant).to receive_message_chain(:where, :first).and_return(assignment)
        allow_any_instance_of(FeedbackResponseMap).to receive_message_chain(:where, :first).and_return(map)
        allow_any_instance_of(FeedbackResponseMap).to receive(:create).and_return(map)

        get :new_feedback

        expect(response).to redirect_to controller: 'response', action: :new, id: map.id, return: "feedback"
      end
      it "redirects to same page if no review is found" do
        allow(Response).to receive(:find).and_return(false)
        expect(response).to have_http_status(200)
      end
    end
  end
end
