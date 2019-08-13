# Test VPC resource
require 'aws-sdk'

describe vpc() do 
    it { should exist }
    it { should be_available }
    it { should have_tag('Name').value("XXXX") }     
end