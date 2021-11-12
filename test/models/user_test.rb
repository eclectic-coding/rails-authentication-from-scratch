require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup do
    @user = User.new(email: "unique_email@example.com", password: "password", password_confirmation: "password")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "should have email" do
    @user.email = nil
    assert_not @user.valid?
  end

  test "email should be unique" do
    @user.save!
    @invalid_user = User.new(email: @user.email)

    assert_not @invalid_user.valid?
  end

  test "email should be saved as lowercase" do
    email = "unique_email@example.com"

    @user = User.new(email: email.upcase, password: "password", password_confirmation: "password")
    @user.save!

    assert_equal email.downcase, @user.email
  end

  test "email should be valid" do
    invalid_emails = %w(foo foo@ foo@bar.)

    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?
    end
  end

  test "should respond to confirmed?" do
    assert_not @user.confirmed?

    @user.confirmed_at = Time.now

    assert @user.confirmed?
  end

  test "should respond to unconfirmed?" do
    assert @user.unconfirmed?

    @user.confirmed_at = Time.now

    assert_not @user.unconfirmed?
  end  

  test "should respond to send_confirmation_email!" do
    @user.save!
    original_confirmation_token = @user.confirmation_token
    
    freeze_time

    assert_nil @user.confirmation_sent_at

    assert_emails 1 do
      @user.send_confirmation_email!
    end

    assert_not_equal original_confirmation_token, @user.reload.confirmation_token
    assert_equal Time.now, @user.confirmation_sent_at
  end

  test "should respond to confirmation_token_has_not_expired?" do
    assert_not @user.confirmation_token_has_not_expired?

    @user.confirmation_sent_at = 1.minute.ago
    assert @user.confirmation_token_has_not_expired?

    @user.confirmation_sent_at = 601.seconds.ago
    assert_not @user.confirmation_token_has_not_expired?
  end
 end