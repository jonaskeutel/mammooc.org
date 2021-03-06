# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AbstractMoocProviderConnector do
  let(:abstract_mooc_provider_connector) { described_class.new }

  context 'with user enrollments synchronization' do
    let(:mooc_provider) { FactoryBot.create(:mooc_provider) }
    let(:course) { FactoryBot.create(:full_course, mooc_provider_id: mooc_provider.id) }
    let(:second_course) { FactoryBot.create(:full_course, mooc_provider_id: mooc_provider.id) }
    let(:user) { FactoryBot.create(:user) }

    before do
      user.courses << course
      user.courses << second_course
    end

    it 'creates a valid update_map' do
      update_map = abstract_mooc_provider_connector.send(:create_enrollments_update_map, mooc_provider, user)
      expect(update_map.length).to eq 2
      update_map.each_value do |updated|
        expect(updated).to be false
      end
    end

    it 'evaluates the update_map and delete the right enrollment' do
      expect do
        update_map = abstract_mooc_provider_connector.send(:create_enrollments_update_map, mooc_provider, user)

        # set one enrollment to true -> prevent from deleting
        update_map.each_with_index do |(enrollment, _), index|
          update_map[enrollment] = true
          index >= 0 ? break : next
        end

        abstract_mooc_provider_connector.send(:evaluate_enrollments_update_map, update_map, user)
      end.to change(user.courses, :count).by(-1)
    end

    it 'throws exceptions when trying to call abstract methods' do
      expect { abstract_mooc_provider_connector.send(:mooc_provider) }.to raise_error NameError
      expect { abstract_mooc_provider_connector.send(:refresh_access_token, user) }.to raise_error NotImplementedError
      expect { abstract_mooc_provider_connector.send(:get_enrollments_for_user, user) }.to raise_error NotImplementedError
      expect { abstract_mooc_provider_connector.send(:handle_enrollments_response, 'test', user) }.to raise_error NotImplementedError
      expect { abstract_mooc_provider_connector.send(:send_connection_request, user, 'test') }.to raise_error NotImplementedError
      expect { abstract_mooc_provider_connector.send(:send_enrollment_for_course, user, '123') }.to raise_error NotImplementedError
      expect { abstract_mooc_provider_connector.send(:send_unenrollment_for_course, user, '123') }.to raise_error NotImplementedError
      expect { abstract_mooc_provider_connector.oauth_link 'destination', 'csrf_token' }.to raise_error NotImplementedError
    end

    it 'handles internet connection error for user enrollments' do
      allow(abstract_mooc_provider_connector).to receive(:get_enrollments_for_user).and_raise SocketError
      expect { abstract_mooc_provider_connector.send(:fetch_user_data, user) }.not_to raise_error
    end

    it 'handles API not found error user enrollments' do
      allow(abstract_mooc_provider_connector).to receive(:get_enrollments_for_user).and_raise RestClient::ResourceNotFound
      expect { abstract_mooc_provider_connector.send(:fetch_user_data, user) }.not_to raise_error
    end

    it 'handles unauthorized error for user enrollments' do
      allow(abstract_mooc_provider_connector).to receive(:get_enrollments_for_user).and_raise RestClient::Unauthorized
      expect { abstract_mooc_provider_connector.send(:fetch_user_data, user) }.not_to raise_error
    end
  end

  context 'with user dates synchronization' do
    describe 'fetch dates for user' do
      let(:user) { FactoryBot.create(:user) }

      it 'handles internet connection error for user dates' do
        allow(abstract_mooc_provider_connector).to receive(:get_dates_for_user).and_raise SocketError
        expect { abstract_mooc_provider_connector.send(:fetch_dates_for_user, user) }.not_to raise_error
      end

      it 'handles API not found error for user dates' do
        allow(abstract_mooc_provider_connector).to receive(:get_dates_for_user).and_raise RestClient::ResourceNotFound
        expect { abstract_mooc_provider_connector.send(:fetch_dates_for_user, user) }.not_to raise_error
      end

      it 'handles unauthorized error for user dates' do
        allow(abstract_mooc_provider_connector).to receive(:get_dates_for_user).and_raise RestClient::Unauthorized
        expect { abstract_mooc_provider_connector.send(:fetch_dates_for_user, user) }.not_to raise_error
      end

      it 'returns false if an error occurred' do
        allow(abstract_mooc_provider_connector).to receive(:get_dates_for_user).and_raise RestClient::Unauthorized
        result = abstract_mooc_provider_connector.send(:fetch_dates_for_user, user)
        expect(result).to be false
      end

      it 'calls get dates for user' do
        expect(abstract_mooc_provider_connector).to receive(:get_dates_for_user).with(user)
        allow(abstract_mooc_provider_connector).to receive(:handle_dates_response)
        abstract_mooc_provider_connector.send(:fetch_dates_for_user, user)
      end

      it 'calls handle dates response with the received data and the given user' do
        response = 'this should be a real response'
        allow(abstract_mooc_provider_connector).to receive(:get_dates_for_user).with(user).and_return(response)
        expect(abstract_mooc_provider_connector).to receive(:handle_dates_response).with(response, user)
        abstract_mooc_provider_connector.send(:fetch_dates_for_user, user)
      end

      it 'returns true if no error occurs' do
        allow(abstract_mooc_provider_connector).to receive(:get_dates_for_user)
        allow(abstract_mooc_provider_connector).to receive(:handle_dates_response)
        result = abstract_mooc_provider_connector.send(:fetch_dates_for_user, user)
        expect(result).to be true
      end
    end

    describe 'load dates for user' do
      it 'calls fetch_dates_for_user for every user if no user is given' do
        FactoryBot.create_list(:user, 5)
        allow(abstract_mooc_provider_connector).to receive(:connection_to_mooc_provider?).and_return(true)
        expect(abstract_mooc_provider_connector).to receive(:fetch_dates_for_user).exactly(5).times
        abstract_mooc_provider_connector.send(:load_dates_for_users)
      end

      it 'calls fetch_dates_for_user only for the given users' do
        users = [FactoryBot.create(:user), FactoryBot.create(:user)]
        FactoryBot.create_list(:user, 5)
        allow(abstract_mooc_provider_connector).to receive(:connection_to_mooc_provider?).and_return(true)
        expect(abstract_mooc_provider_connector).to receive(:fetch_dates_for_user).twice
        abstract_mooc_provider_connector.send(:load_dates_for_users, users)
      end
    end

    describe 'create update map for user dates' do
      let(:mooc_provider) { FactoryBot.create(:mooc_provider) }
      let(:course) { FactoryBot.create(:course, mooc_provider: mooc_provider) }
      let(:user) { FactoryBot.create(:user, courses: [course]) }

      it 'creates one entry in update map for every user dates with the given user and mooc_provider' do
        FactoryBot.create_list(:user_date, 5, user: user, course: course)
        map = abstract_mooc_provider_connector.send(:create_update_map_for_user_dates, user, mooc_provider)
        expect(map.length).to eq 5
      end

      it 'does not create an entry for user dates that does not belong to the given user' do
        FactoryBot.create_list(:user_date, 2, user: user, course: course)

        FactoryBot.create_list(:user_date, 3, course: course)

        map = abstract_mooc_provider_connector.send(:create_update_map_for_user_dates, user, mooc_provider)
        expect(map.length).to eq 2
      end

      it 'does not create an entry for user dates that does not belong to the given provider' do
        FactoryBot.create_list(:user_date, 2, user: user, course: course)

        FactoryBot.create_list(:user_date, 3, user: user)

        map = abstract_mooc_provider_connector.send(:create_update_map_for_user_dates, user, mooc_provider)
        expect(map.length).to eq 2
      end

      it 'sets every entry to false' do
        FactoryBot.create_list(:user_date, 5, user: user, course: course)
        map = abstract_mooc_provider_connector.send(:create_update_map_for_user_dates, user, mooc_provider)
        map.each_value do |updated|
          expect(updated).to be false
        end
      end
    end

    it 'throws exceptions when trying to call abstract methods' do
      user = FactoryBot.create(:user)
      expect { abstract_mooc_provider_connector.send(:get_dates_for_user, user) }.to raise_error NotImplementedError
      expect { abstract_mooc_provider_connector.send(:handle_dates_response, 'test', user) }.to raise_error NotImplementedError
    end
  end
end
