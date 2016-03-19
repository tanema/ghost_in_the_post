require 'spec_helper'

describe GhostInThePost::JSLoaders::AssetPipelineLoader do
  before do
    assets = double(prefix: '/assets')
    config = double(assets: assets)
    allow(Rails).to receive(:configuration).and_return(config)
  end

  describe "#file_name" do
    subject do
      GhostInThePost::JSLoaders::AssetPipelineLoader.file_name(asset)
    end

    context "when asset file path contains prefix" do
      let(:asset) { '/assets/application.css' }
      it { is_expected.to eq('application.css') }
    end

    context "when asset file path contains 32 chars fingerprint" do
      let(:asset) { 'application-6776f581a4329e299531e1d52aa59832.css' }
      it { is_expected.to eq('application.css') }
    end

    context "when asset file path contains 64 chars fingerprint" do
      let(:asset) { 'application-02275ccb3fd0c11615bbfb11c99ea123ca2287e75045fe7b72cefafb880dad2b.css' }
      it { is_expected.to eq('application.css') }
    end

    context "when asset file page contains numbers, but not a fingerprint" do
      let(:asset) { 'test/20130708152545-foo-bar.css' }
      it { is_expected.to eq("test/20130708152545-foo-bar.css") }
    end
  end
end