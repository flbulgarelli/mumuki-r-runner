require_relative './spec_helper'
require 'ostruct'

describe RQueryHook do
  let(:hook) { RQueryHook.new(nil) }
  let(:file) { hook.compile(request) }
  let(:result) {
    hook.run!(file)
  }

  describe 'expressions' do
    context 'integral query' do
      let(:request) { struct(query: '5') }
      it { expect(result[0]).to eq "[1] 5\n" }
    end

    context 'string query' do
      let(:request) { struct(query: '"hello"') }
      it { expect(result[0]).to eq "[1] \"hello\"\n" }
    end

    context 'array query' do
      let(:request) { struct(query: 'c(1,2, 3)') }
      it { expect(result[0]).to eq "[1] 1 2 3\n" }
    end

    context 'NULL query' do
      let(:request) { struct(query: 'NULL') }
      it { expect(result[0]).to eq "NULL\n" }
    end

    context 'function query' do
      let(:request) { struct(query: 'function(x) { return (x+1) }') }
      it { expect(result[0]).to eq 'function(x) { return (x+1) }' }
    end
  end

  describe 'declarations' do
    context 'with let' do
      let(:request) { struct(query: 'x <- 3') }
      it { expect(result[0]).to eq "[1] 3\n" }
    end
  end

  context 'query and content' do
    context 'no cookie' do
      let(:request) { struct(query: 'x', content: 'x<-2*2') }
      it { expect(result[0]).to eq "[1] 4\n" }
    end

    context 'with cookie' do
      let(:request) { struct(query: 'x', cookie: ['x <- x + 1', 'x <- x + 1'], content: 'x <- 4') }
      it { expect(result[0]).to eq "[1] 6\n" }
    end

    context 'with failing cookie' do
      let(:request) { struct(query: 'x', cookie: ['assssfdsfds', 'x <- 1'], content: 'x <- 4') }
      it { expect(result[0]).to eq "[1] 5\n" }
    end
  end

  context 'query and extra' do
    context 'with variable' do
      let(:request) { struct(query: 'y', extra: 'y<-64+2') }
      it { expect(result[0]).to eq "[1] 66\n" }
    end

    context 'with expression ' do
      let(:request) { struct(query: 'x + 1', extra: 'x <- 4') }
      it { expect(result[0]).to eq "[1] 5\n" }
    end
  end

  context 'query with syntax errors' do
    context 'with invalid token' do
      let(:request) { struct(query: '!') }
      it { expect(result[0]).to eq %q{!;
                               ^

SyntaxError: Unexpected token ;} }
      it { expect(result[1]).to eq :errored }
    end

    context 'with unclosed curly braces' do
      let(:request) { struct(query: 'function () {') }
      it { expect(result[0]).to eq %q`});
 ^

SyntaxError: Unexpected token )` }
      it { expect(result[1]).to eq :errored }
    end
  end

  context 'query with unknown reference' do
    let(:request) { struct(query: 'someFunction(23)') }
    it { expect(result[0]).to include 'ReferenceError' }
    it { expect(result[0]).to_not include '__mumuki_query_result__' }
    it { expect(result[1]).to eq :errored }
  end
end
