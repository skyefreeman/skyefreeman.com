module LinksHelper
  def ensure_https_prefix(url)
    return nil if url.nil?

    url_string = url.to_s.strip

    if url_string.blank?
      return nil
    end

    if url_string.start_with?("https://")
      url_string
    elsif url_string.start_with?("http://")
      url_string.sub(/\Ahttp:\/\//, "https://")
    else
      "https://#{url_string}"
    end
  end
end
