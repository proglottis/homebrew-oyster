require "language/go"

class Oyster < Formula
  homepage "https://github.com/proglottis/oyster"
  url "https://github.com/proglottis/oyster/archive/v0.2.10.zip"
  sha256 "e939aa35f01f68996050e020e943af1ddc12e6e64753cbdb5455d4dbefb13926"

  depends_on "go" => :build

  go_resource "github.com/atotto/clipboard" do
    url "https://github.com/atotto/clipboard",
        :revision => "dfde2702d61cc95071f9def0fe9fc47d43136d6d", :using => :git
  end

  go_resource "github.com/codegangsta/cli" do
    url "https://github.com/codegangsta/cli",
        :revision => "942282e931e8286aa802a30b01fa7e16befb50f3", :using => :git
  end

  go_resource "github.com/kr/fs" do
    url "https://github.com/kr/fs",
        :revision => "2788f0dbd16903de03cb8186e5c7d97b69ad387b", :using => :git
  end

  go_resource "github.com/robfig/config" do
    url "https://github.com/robfig/config",
        :revision => "0f78529c8c7e3e9a25f15876532ecbc07c7d99e6", :using => :git
  end

  go_resource "github.com/sourcegraph/rwvfs" do
    url "https://github.com/sourcegraph/rwvfs",
        :revision => "676d97f331b7ffedb030313be4d869c8cda8bc9d", :using => :git
  end

  go_resource "golang.org/x/crypto" do
    url "https://go.googlesource.com/crypto",
        :revision => "ce6bda69189e9f4ff278a5e181691cd695f753ae", :using => :git
  end

  go_resource "golang.org/x/tools" do
    url "https://go.googlesource.com/tools",
        :revision => "3d1847243ea4f07666a91110f48e79e43396603d", :using => :git
  end

  def install
    ENV["GOBIN"] = bin
    ENV["GOPATH"] = buildpath
    ENV["GOHOME"] = buildpath

    mkdir_p buildpath/"src/github.com/proglottis"
    ln_s buildpath, buildpath/"src/github.com/proglottis/oyster"
    Language::Go.stage_deps resources, buildpath/"src"

    system "go", "build", "-o", bin/"oyster", "github.com/proglottis/oyster/cmd/oyster"
    system "go", "build", "-o", bin/"oyster_chrome", "github.com/proglottis/oyster/cmd/oyster_chrome"

    bash_completion.install "cmd/oyster/oyster_bash_completion.sh"
    chrome_native_messaging_path.atomic_write(chrome_native_messaging)
    chrome_native_messaging_path.chmod 0644
  end

  def chrome_native_messaging_name; "com.github.proglottis.oyster.json"; end
  def chrome_native_messaging_path; prefix + chrome_native_messaging_name; end

  def chrome_native_messaging; <<-EOS.undent
    {
      "name": "com.github.proglottis.oyster",
      "description": "Oyster",
      "path": "#{bin}/oyster_chrome",
      "type": "stdio",
      "allowed_origins": [
        "chrome-extension://knchgkoimfkgfopjfehdkcchmbmkmfgi/"
      ]
    }
    EOS
  end

  def caveats; <<-EOS.undent
    To allow the Google Chrome plugin to connect to Oyster:
        ln -sfv #{opt_prefix}/#{chrome_native_messaging_name} ~/Library/Application\\ Support/Google/Chrome/NativeMessagingHosts/
    EOS
  end

  test do
  end
end
