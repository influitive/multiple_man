require 'spec_helper'

describe MultipleMan do 
  let(:mock_logger) { double(Logger) }

  before do
    MultipleMan.configure do |config|
      config.logger = mock_logger
    end
  end

  it "should use the logger from configuration" do
    mock_logger.should_receive(:info).with("My message")
    MultipleMan.logger.info "My message"
  end

end