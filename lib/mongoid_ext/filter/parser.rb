module MongoidExt
  module Filter
    class Parser
      def initialize(stemmer)
        @stemmer = stemmer
      end

      def parse(query)
        query, quotes = parse_quoted_text(query)
        query, ops = parse_operators(query)
        query.gsub!(/\s+/, ' ')
        query.gsub!(/\?|\!|\:|\)|\(/, "")

        words = Set.new(query.downcase.split(/\s+/))

        stemmed = stem(words)
        tokens = words + stemmed

        {:query => query,
         :words => words,
         :stemmed => stemmed,
         :operators => ops,
         :tokens => tokens,
         :quotes => quotes}
      end

      private
      def parse_quoted_text(query)
        quotes = []
        loop do
          m = query.match(/"([^"]+"|-)/)
          if m
            query = $` + $'
            quotes << m[1].gsub('"', "")
          else
            break
          end
        end

        [query, quotes]
      end

      def parse_operators(query)
        ops = {}

        loop do
          m = query.match(/(is|lang|not|by|score):(\S+)/)
          if m
            query = $` + $'
            (ops[m[1]] ||= []) << m[2]
          else
            break
          end
        end
        [query, ops]
      end

      def stem(words)
        tokens = []
        if @stemmer
          words.each do |word|
            stem = @stemmer.stem(word)
            tokens << stem if word.size > 2 && !words.include?(stem)
          end
        end

        tokens
      end
    end
  end
end
