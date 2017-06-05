describe service('zookeeper') do
  it { should be_enabled }
  it { should be_running }
end

describe command('echo ruok | nc localhost 2181') do
  its(:stdout) { should eq("imok") }
  its(:stderr) { should be_empty }
end
