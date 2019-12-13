require_relative './spec_helper'

describe 'running' do

  let(:runner) { RTestHook.new }

  let(:file) { runner.compile(struct content: content, test: test, extra: extra) }
  let(:raw_results) { runner.run!(file) }
  let(:results) { raw_results[0] }

  let(:extra) { '' }
  let(:content) { '' }

  context 'on simple passed file' do
    let(:test) do
<<R
test_that("true is true", { expect_true( TRUE ) })
R
    end

    it { expect(results).to eq([['true is true', :passed, '']]) }
  end

  context 'on simple failed file' do
    let(:test) do
<<R
test_that("true is true", { expect_true( FALSE ) })
R
    end

    it { expect(results).to eq([['true is true', :failed, "FALSE isn't true."]]) }
  end

  context 'on multiple tests' do
    let(:test) do
<<R
test_that("true is true", { expect_true( TRUE ) })
test_that("false is true", { expect_true( FALSE ) })
R
    end

    it { expect(results).to eq([['true is true', :passed, ''], ['false is true', :failed, "FALSE isn't true."]]) }
  end
end
