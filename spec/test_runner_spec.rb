require_relative './spec_helper'

describe 'running' do

  let(:runner) { RTestHook.new }

  let(:file) { runner.compile(OpenStruct.new(content: content, test: test, extra: extra)) }
  let(:raw_results) { runner.run!(file) }
  let(:results) { raw_results[0] }

  let(:extra) { '' }

  let(:content) do
    <<R
  const _true = true;
R
  end

  describe '#run!' do
    context 'on simple passed file' do
      let(:test) do
        <<R
  describe('_true', () => {
      it('is true', () => assert.equal(_true, true));
  });
R
      end

      it { expect(results).to eq([['_true is true', :passed, '']]) }
    end

    context 'on simple failed file' do
      let(:test) do
        <<R
  describe('_true', () => {
    it('is is something that will fail', () => assert.equal(_true, 3));
  });
R
      end

      it { expect(results).to(
          eq([['_true is is something that will fail', :failed, 'true == 3']])) }
    end

    context 'on multi file' do
      let(:test) do
        <<R
  describe('_true', function() {
    it('is true', function() {
      assert.equal(_true, true)
    });
    it('is not _false', function() {
      assert.notEqual(_true, false)
    });
    it('is is something that will fail', function() {
      assert.equal(_true, 3)
    });
  });
R
end

      it { expect(results).to(
          eq([['_true is true', :passed, ''],
              ['_true is not _false', :passed, ''],
              ['_true is is something that will fail', :failed, 'true == 3']])) }
    end

    context 'when content contains a logging operation' do
      let(:content) do
<<R
function a(){
  console.log('An output.')
  return 3
}
R
      end

      let(:test) do
<<R
describe('a()', function() {
  it('returns 3', function() {
    assert.equal(3, a())
  });
});
R
      end

      it { expect(results).to(
          eq([['a() returns 3', :passed, '']])) }
    end
  end
end
