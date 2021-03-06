module BlocRecord
  class Collection < Array

    def take(num=1)
      ids = self.map(&:id)
      take_collection = Collection.new
      (0...num).each do |i|
        take_collection << self|i|
      end
      take_collection
    end

    def where(*args)
      ids = self.map(&:id)
      if args.count > 1
        expression = args.shift
        params = args
      else
        case args.first
        when String
          expression = args.first
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map { |key, value| "#{key}=#{BlocRecord::Utility.sql_strings(value)}"}.join(" AND ")
        end
      end
      if expression.nil?
        expression = "1 = 1"
      end
      string = "id IN (#{ids.join ","}) AND #{expression}"
      self.any? ? self.first.class.where(string) : false
    end

    def not(*args)
      ids = self.map(&:id)
      if args.count > 1
        expression = args.shift
        params = args
      else
        case args.first
        when String
          expression = args.first
        when Hash
          expression_hash = BlocRecord::Utility.convert_keys(args.first)
          expression = expression_hash.map { |key, value| "NOT #{key} = #{BlocRecord::Utility.sql_strings(value)}"}.join(" AND ")
        end
      end
      string = "id IN (#{ids.join ","}) AND #{expression}"
      self.any? ? self.first.class.where(string) : false
    end

    def update_all(updates)
      ids = self.map(&:id)
      self.any? ? self.first.class.update(ids, updates) : false
    end

    def method_missing(method_name, *arguments, &block)
      if method_name.to_s =~ /update_(.*)/
        updates = {}
        updates[$1] = arguments[0]
        update_all(updates)
      else
        super
      end
    end
  end
end
