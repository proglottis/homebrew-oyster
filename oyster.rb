require "formula"

class Oyster < Formula
  homepage "https://github.com/proglottis/oyster"
  url "https://github.com/proglottis/oyster/archive/v0.2.3.zip"
  sha256 "c4dcb64ee11a1b9111ab9bf36edc672e2304583d356be5fbb6f8416677932c0b"

  depends_on "go" => :build

  def install
    ENV["GOBIN"] = bin
    ENV["GOPATH"] = buildpath
    mkdir_p buildpath/"src/github.com/proglottis"
    ln_s buildpath, buildpath/"src/github.com/proglottis/oyster"

    system "go", "get", "github.com/proglottis/oyster/cmd/oyster", "github.com/proglottis/oyster/cmd/oyster_chrome"
    system "go", "install", "github.com/proglottis/oyster/cmd/oyster", "github.com/proglottis/oyster/cmd/oyster_chrome"

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
