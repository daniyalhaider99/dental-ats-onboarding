module CvParsing
  module TextExtraction
    class Doc < Base
      SOFFICE_CANDIDATES = [
        ENV["SOFFICE_BIN"],
        "soffice",
        "libreoffice",
        "/Applications/LibreOffice.app/Contents/MacOS/soffice"
      ].compact.freeze

      private

      def extract(file)
        binary = soffice_binary
        raise ExtractionToolMissingError, "LibreOffice is not available to read .doc files" if binary.nil?

        Dir.mktmpdir("cv-doc") do |dir|
          converted = convert_to_docx(binary, file.path, dir)
          Docx.new(document).send(:extract, File.open(converted))
        end
      end

      def convert_to_docx(binary, source, output_dir)
        _out, err, status = Open3.capture3(
          binary, "--headless", "--convert-to", "docx", "--outdir", output_dir, source
        )

        converted = Dir[File.join(output_dir, "*.docx")].first
        unless status.success? && converted
          raise EmptyExtractionError, "LibreOffice failed to convert the .doc file: #{err.strip}"
        end

        converted
      end

      def soffice_binary
        SOFFICE_CANDIDATES.filter_map { |candidate| resolve_executable(candidate) }.first
      end

      def resolve_executable(candidate)
        return candidate if File.absolute_path?(candidate) && executable_file?(candidate)
        return nil if candidate.include?(File::SEPARATOR)

        ENV.fetch("PATH", "").split(File::PATH_SEPARATOR).filter_map do |dir|
          path = File.join(dir, candidate)
          path if executable_file?(path)
        end.first
      end

      def executable_file?(path)
        File.file?(path) && File.executable?(path)
      end
    end
  end
end
