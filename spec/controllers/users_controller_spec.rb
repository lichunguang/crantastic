require File.dirname(__FILE__) + '/../spec_helper'

describe UsersController do

  integrate_views

  it "should render the index successfully" do
    get :index
    response.should render_template(:index)
  end

  it "should do a 404 for unknown users" do
    get :show, :id => 9999
    response.status.should == "404 Not Found"
  end

end