# copyright: 2018, The Authors

# Test values

resource_group1 = 'rg-test-asr-basic-resources'


describe azure_generic_resource(resource_group: resource_group1, name: 'ukw-asr-vault-test-basic') do
  it { should exist }
end