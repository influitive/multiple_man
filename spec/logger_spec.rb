require 'spec_helper'

describe MultipleMan do 
  let(:mock_logger) { double(Logger) }

  before do
    MultipleMan.configuration.stub(:logger).and_return(mock_logger)
  end

  it "should use the logger from configuration" do
    mock_logger.should_receive(:info).with("My message")
    MultipleMan.logger.info "My message"
  end

end