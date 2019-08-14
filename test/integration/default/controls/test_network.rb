# frozen_string_literal: true

control 'test_network' do
    describe command('lsb_release -a') do 
        its('stdout') { should match (/Ubuntu/) }             
    end
end