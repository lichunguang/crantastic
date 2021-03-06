require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/authors" do

  before(:each) do
  end

  it "should display the number of package maintainers" do
    assigns[:authors] = [ Author.make, Author.make ]
    render 'authors/index'
    response.should have_tag('p', %r[There are 2 package maintainers on crantastic])
  end

end
