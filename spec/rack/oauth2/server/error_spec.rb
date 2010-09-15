require 'spec_helper.rb'

describe Rack::OAuth2::Server::Error, '#finish' do

  context "when state is given" do
    it "should return state as error response" do
      error = Rack::OAuth2::Server::Error.new(400, :invalid_request, "Something Invalid!!", :state => "anything")
      status, header, body = error.finish
      body.should match("\"state\":\"anything\"")
    end
  end

  context "when redirect_uri is given" do
    before do
      @params = {
        :error => :invalid_request,
        :error_description => "Something invalid!!",
        :redirect_uri => "http://client.example.com"
      }
      @error = Rack::OAuth2::Server::Error.new(400, @params[:error], @params[:error_description], :redirect_uri => @params[:redirect_uri])
    end

    it "should redirect to redirect_uri with error message in query string" do
      status, header, body = @error.finish
      status.should == 302
      header['Content-Type'].should == "text/html"
      header['Location'].should == "#{@params.delete(:redirect_uri)}?#{@params.to_query}"
    end
  end

  context "when redirect_uri isn't given" do
    before do
      @params = {
        :error => :invalid_request,
        :error_description => "Something invalid!!"
      }
      @error = Rack::OAuth2::Server::Error.new(400, @params[:error], @params[:error_description])
    end

    it "should return failure response with error message in json body" do
      status, header, body = @error.finish
      body.should == @params.to_json
    end
  end

end

describe Rack::OAuth2::Server::BadRequest do
  it "should use 400 as status" do
    error = Rack::OAuth2::Server::BadRequest.new(:invalid_request)
    error.code.should == 400
  end
end

describe Rack::OAuth2::Server::Unauthorized do
  it "should use 401 as status" do
    error = Rack::OAuth2::Server::Unauthorized.new(:unauthorized_client)
    error.code.should == 401
  end
end