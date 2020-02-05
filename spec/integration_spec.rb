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
                                 content: 'a_variable <- 3',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'a variable is 3', status: :passed, result: ''}],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


  it 'answers a valid hash when submission is not ok' do
    response = bridge.run_tests!(test: 'test_that("a_variable is 3", { expect_equal(a_variable, 3) })',
                                 extra: '',
                                 content: 'a_variable <- 4',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [{title: 'a variable is 3', status: :failed, result: "`a_variable` not equal to 3.\n1/1 mismatches\n[1] 4 - 3 == 1"}],
                           status: :failed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end


  it 'answers a valid hash when submission has compilation errors' do
    response = bridge.run_tests!(test: 'test_that("a variable is 3", { expect_equal(a_variable, 3) })',
                                 extra: '',
                                 content: 'm -< 4',
                                 expectations: [])

    expect(response).to eq(response_type: :unstructured,
                           test_results: [],
                           status: :errored,
                           feedback: '',
                           expectation_results: [],
                           result: "> testthat::test_file('solution.R',reporter='junit')\nError in parse(con, n = -1, srcfile = srcfile, encoding = \"UTF-8\") : \n  solution.R:2:4: unexpected '<'\n1: \n2: m -<\n      ^\nCalls: <Anonymous> ... withOneRestart -> doWithOneRestart -> force -> source_file -> parse\nExecution halted\n")
  end
end
