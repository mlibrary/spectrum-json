module Spectrum
  module Response
    class Specialists
      def initialize(args)
        @data = args
      end

      def spectrum
        merge(hlb_specialists, le_specialists)
      end

      def merge(left, right)
        [*left, *right]
      end

      def hlb_specialists
        [
          {
            name: 'Scott Dennis',
            url: 'https://www.lib.umich.edu/users/sdenn',
            job_title: 'Librarian for Philosophy, General Reference, and Core Electronic Resources',
            picture: 'https://www.lib.umich.edu/sites/default/files/pictures/picture-205-1471625361.jpg',
            department: 'Arts & Humanities',
            email: 'sdenn@umich.edu',
            phone: '734-647-6484',
            office: [
              '209 Hatcher North',
              'Ann Arbor, MI 48109-1190',
            ]
          }
        ]
      end

      def le_specialists
        [
          {
            name: 'Dave Carter',
            url: 'https://www.lib.umich.edu/users/superman',
            job_title: 'Video Game Archivist & Reference Librarian',
            picture: 'https://www.lib.umich.edu/sites/default/files/pictures/picture-141-1375893456.jpg',
            department: 'Connected Scholarship',
            email: 'superman@umich.edu',
            phone: '734-615-7158',
            office: [
              '2216 LSA',
              'Ann Arbor, MI 48109-0320',
            ]
          }
        ]
      end
    end
  end
end
