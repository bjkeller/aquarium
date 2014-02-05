module Lang

  class Scope 

    attr_reader :stack;

    def initialize(opts={})
      o = {
        base: {}
      }.merge opts
      @stack = [o[:base]]
    end

    def set_stack stack
      @stack = stack
    end

    def set symbol, value
      @stack.last[symbol] = value
    end

    def set_base_symbol symbol, value
      @stack.first[symbol] = value
    end

    def push 
      @stack.push( {} )
    end

    def pop
      @stack.pop
    end

    def get symbol
      i = @stack.length - 1
      while @stack[i][symbol] == nil && i >= 0
        i -= 1
      end
      return @stack[i][symbol]
    end

    def collapse
      result = {}
      @stack.reverse.each do |h|
        result = h.merge result
      end
      return result
    end

    def substitute str
      begin
        str % collapse
      rescue Exception => e
        raise "Unkown symbol in text. " + e.message.sub('key','%')
      end
    end

    def symbol_subs
      syms = {}
      collapse.each do |k,v|
        syms[k] = "(get :#{k})"
      end
      syms
    end

    def evaluate str
      begin 
        expr = str % symbol_subs 
      rescue Exception => e
        raise "Unknown symbol in expression. " + e.message.sub('key','%')
      end
      begin
        result = eval(expr)
      rescue Exception => e
        raise "Could not evaluate #{str} => #{expr}. " + e.message
      end
      result
    end

    def to_s
      s = ""
      indent = "  "
      @stack.reverse.each do |table| 
        table.each do |key,value|
          s += indent + key.to_s + ': '
          if value.kind_of?(Array)
            s += "\n"
            value.each do |el|
              s += indent + indent + el.to_s + "<br />"
            end
          else
            s += value.to_s + "<br />"
          end
        end
        indent += "  "
      end
      return s
    end



    ############################################################################
    # array functions callable from plankton

    def length a

      if a.class == Array
        a.length
      else
        raise "Attempted to take length of non-array #{a}"
      end

    end

    def append a, x

      if a.class == Array
        b = a.dup
        b.push x
        b
      else
        raise "Attempted to take append #{x} to non-array #{a}"
      end

    end

    def concat a, b

      if a.class == Array && b.class == Array
        x = a.dup
        y = b.dup
        x.concat y
        x
      else
        raise "Attempted to take concat #{a} and #{b}, which are not both arrays."
      end

    end

    def unique a # returns an array that represents the same set, but with no repeats
      if a.class == Array
        a.uniq
      else
        raise "Attempted to apply uniqie to #{a}, which is not an array."
      end
    end

    ############################################################################
    # collection functions callable from plankton

    def collection spec

      if spec.class == Hash

        s = {
          name: "Unknown", 
          description: "No description provided", 
          object_type: "Generic Collection", 
          part_object_type: "Generic Part",
          rows: 1, 
          columns: 1, 
          project: "Unknown",
          location: "Bench" }.merge spec

        collection_ot = ObjectType.find_by_name(s[:object_type])
        part_ot = ObjectType.find_by_name(s[:part_object_type])

        if !collection_ot
          raise "Could not find object type #{s[:object_type]} when attempt to make new collection."
        end

        if !part_ot
          raise "Could not find object type #{s[:part_object_type]} when attempt to make new collection."
        end

        c = Collection.new
        c.name = s[:name]
        c.object_type_id = part_ot.id
        c.rows = s[:rows]
        c.columns = s[:columns]
        c.project = s[:project]
        c.description = s[:description]
        c.save

        i = Item.new
        i.object_type_id = collection_ot.id
        i.location = s[:location]
        i.quantity = 1
        i.inuse = 1
        i.collection_id = c.id
        i.save

        { id: i.id, name: i.object_type.name, data: "" }

      else
        raise "Invalid argument to collection. Expecting a hash with fields name, part_type, rows, cols, and project."
      end

    end

  end

end
