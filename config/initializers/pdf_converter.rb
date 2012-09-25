# Wisepdf::Configuration.configure do |config|
#   config.wkhtmltopdf = "/usr/bin/wkhtmltopdf"
# end
require 'rbconfig'

bin = Gem::Specification.find_by_name("wkhtmltopdf-binary").bin_file("wkhtmltopdf").chomp

if RbConfig::CONFIG['host_os'] =~ /linux/
  bin << (RbConfig::CONFIG['host_cpu'] == 'x86_64' ? '_linux_x64' : '_linux_386')
elsif RbConfig::CONFIG['host_os'] =~ /darwin/
  bin << '_darwin_386'
else
  raise "Invalid platform. Must be running linux or intel-based Mac OS."
end

WickedPdf.config = {
  #:wkhtmltopdf => '/usr/local/bin/wkhtmltopdf',
  #:layout => "pdf.html",
  :exe_path => bin.chomp
}
# `cd \"#{Rails.root}\" && bundle exec which wkhtmltopdf`
