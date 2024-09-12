module Screengrab
  class ReportsGenerator
    require 'erb'

    def html_path
      if Screengrab.config[:html_template]
        Screengrab.config[:html_template]
      else
        File.join(Screengrab::ROOT, "lib", "screengrab/page.html.erb")
      end
    end

    def generate
      UI.message("Generating HTML Report")

      screens_path = Screengrab.config[:output_directory]

      @data_by_language = {}
      @data_by_screen = {}

      Dir[File.join(screens_path, "*")].sort.each do |language_folder|
        language = File.basename(language_folder)
        Dir[File.join(language_folder, 'images', '*', '*.png')].sort.each do |screenshot|
          file_name = File.basename(screenshot)
          device_type_folder = File.basename(File.dirname(screenshot))
          
          device_name = case device_type_folder
                        when 'phoneScreenshots'
                          'Phone'
                        when 'sevenInchScreenshots'
                          '7-inch Tablet'
                        when 'tenInchScreenshots'
                          '10-inch Tablet'
                        else
                          next  # Skip unknown device types
                        end

          @data_by_language[language] ||= {}
          @data_by_language[language][device_name] ||= []

          screen_name = file_name.sub('.png', '')
          @data_by_screen[screen_name] ||= {}
          @data_by_screen[screen_name][device_name] ||= {}

          resulting_path = File.join('.', language, 'images', device_type_folder, file_name)
          @data_by_language[language][device_name] << resulting_path
          @data_by_screen[screen_name][device_name][language] = resulting_path
        end
      end

      html = ERB.new(File.read(html_path)).result(binding)

      export_path = "#{screens_path}/screenshots.html"
      File.write(export_path, html)

      export_path = File.expand_path(export_path)
      UI.success("Successfully created HTML file with an overview of all the screenshots: '#{export_path}'")
      system("open '#{export_path}'") unless Screengrab.config[:skip_open_summary]
    end

    def available_devices
      {
        'phone' => 'Phone',
        'sevenInch' => '7-inch Tablet',
        'tenInch' => '10-inch Tablet'
      }
    end
  end
end