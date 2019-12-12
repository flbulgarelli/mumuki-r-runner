require 'active_support/all'
require 'mumukit/bridge'

describe 'runner' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4567') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4567', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it 'answers a valid hash when submission is ok' do
    response = bridge.run_tests!(test: 'test_that("a_variable is 3", { expect_equal(a_variable, 3) })',
                                 extra: '',
                                 content: 'aVariable <- 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'a_variable is 3', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


  it 'answers a valid hash when submission is not ok' do
    response = bridge.run_tests!(test: 'test_that("a_variable is 3", { expect_equal(a_variable, 3) })',
                                 extra: '',
                                 content: 'aVariable <- 4',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'a_variable is 3', status: :failed, result: '3 != 4'}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


  it 'answers a valid hash when submission has compilation errors' do
    response = bridge.run_tests!(test: 'test_that("a_variable is 3", { expect_equal(a_variable, 3) })',
                                 extra: '',
                                 content: 'm -< 4',
                                 expectations: [])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :errored,
                           feedback: '',
                           expectation_results: [],
                           result: 'Error: unexpected '<' in "m -<"')
  end
end
