# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserDate, type: :model do
  let(:user) { FactoryBot.create(:user) }

  describe 'synchronize user' do
    it 'calls openHPI and openSAP Connectors to load the dates for the given user' do
      expect_any_instance_of(OpenHPIConnector).to receive(:load_dates_for_users).with([user])
      expect_any_instance_of(OpenSAPConnector).to receive(:load_dates_for_users).with([user])
      described_class.synchronize(user)
    end

    it 'sets for each called Connector the synchronization_state to true' do
      expect_any_instance_of(OpenHPIConnector).to receive(:load_dates_for_users).with([user]).and_return(true)
      expect_any_instance_of(OpenSAPConnector).to receive(:load_dates_for_users).with([user]).and_return(true)
      synchronization_state = described_class.synchronize(user)
      expect(synchronization_state[:openHPI]).to eq(true)
      expect(synchronization_state[:openSAP]).to eq(true)
    end
  end

  describe 'create current calendar for a given user' do
    let(:user_date) { FactoryBot.create(:user_date, user: user) }

    context 'with a calendar with an event representing the user_date' do
      it 'sets the start time correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.dtstart).to eq(user_date.date.to_date)
      end

      it 'sets the end time correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.dtend).to eq(user_date.date.to_date + 1.day)
      end

      it 'sets the summary correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.summary).to eq(user_date.title)
      end

      it 'sets the description correctly' do
        user_date
        calendar = described_class.create_current_calendar(user)
        expect(calendar.events.first.description).to include(user_date.kind)
        expect(calendar.events.first.description).to include(user_date.course.name)
      end
    end

    it 'collects more than one event' do
      FactoryBot.create_list(:user_date, 5, user: user)
      calendar = described_class.create_current_calendar(user)
      expect(calendar.events.count).to eq(5)
    end

    it 'collects only the dates of the given user' do
      FactoryBot.create_list(:user_date, 5)
      FactoryBot.create_list(:user_date, 2, user: user)
      calendar = described_class.create_current_calendar(user)
      expect(calendar.events.count).to eq(2)
    end
  end

  describe 'generate token for a user' do
    let(:user) { FactoryBot.create(:user) }

    it 'does not create a token if there is already one defined' do
      token = '1234567890'
      user.token_for_user_dates = token
      described_class.generate_token_for_user(user)
      expect(user.token_for_user_dates).to eq(token)
    end

    it 'saves a token to the database for the given user' do
      expect(user.token_for_user_dates).to be nil
      described_class.generate_token_for_user(user)
      expect(user.token_for_user_dates).not_to be nil
    end

    it 'creates a unique token for each user' do
      FactoryBot.create_list(:user, 5)
      User.all.each do |user|
        described_class.generate_token_for_user(user)
      end
      created_tokens = User.all.collect(&:token_for_user_dates)
      expect(created_tokens.uniq.count).to eq(created_tokens.count)
    end
  end
end
