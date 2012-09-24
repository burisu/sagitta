# Wisepdf::Configuration.configure do |config|
#   config.wkhtmltopdf = "/usr/bin/wkhtmltopdf"
# end

WickedPdf.config = {
  #:wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
  #:layout => "pdf.html",
  :wkhtmltopdf => '/usr/bin/wkhtmltopdf'
}
